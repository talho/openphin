Ext.ns("Talho.Forums.view.Topics");

Talho.Forums.view.Topics.Show = Ext.extend(Ext.Panel, {
  autoHeight: true,
  constructor : function() {
    this.addEvents('reload');
    this.on('activate', this.reload);
    this.on('reload', this.reload);
    Talho.Forums.view.Topics.Show.superclass.constructor.apply(this, arguments);
  },
  initComponent : function() {
    this.setTitle('Topic: '+ this.topicName);
    
    if(!this.items) {
      this.items = [];
    }
    
    this.buttons = this.buttons || ['->'];
    this.buttons.push(
    {xtype : 'button', text: 'Reply', itemCls: 'Reply', id: 'reply_button', handler: function() {this.fireEvent('newcomment', this.forumId, this.topicId)}, scope: this},
    {xtype : 'button', text : 'Refresh', handler : function() { this.fireEvent('reload'); }, scope : this });
    
    var store = new Ext.data.JsonStore({
        url: String.format('/forums/{0}/topics/{1}.json',this.forumId,this.topicId),
        root: 'comments',
        autoLoad: true,
        restful: true,
        idProperty: 'id',
        fields: ['id', 'content', 'formatted_content', 'poster_name', 'poster_id', 'user_avatar', 
                'created_at', 'updated_at', 'forum_id', 'locked_at',
                {name: 'is_moderator', type: 'boolean'}, {name: 'is_super_admin', type: 'boolean'}, 
                {name: 'is_forum_admin', type: 'boolean'}, {name: 'is_user_owned', type: 'boolean'}, 'comment_id'] 
    });
    
    var commentTpl = new Ext.XTemplate(
      '<div class="forum-topic-comment-wrap">',
        '<div class="forum-topic-comment-left">',              
          '<div class="forum-topic-comment-poster-name" user_id="{poster_id}" user_name="{poster_name}">',
            '{poster_name}',
          '</div>',
          '<div>',              
            '<img class="forum-topic-comment-poster-picture" alt="{poster_name}" src="{user_avatar}" user_id="{poster_id}" user_name="{poster_name}"/>',
          '</div>',
          '<div>',
            '<span class="forum-comment-quote forum-actions" topic_name="{content}" topicid="{id}">&laquo;Quote</span>',
            '<tpl if="this.canEdit(values)">',
              '<span class="forum-comment-edit forum-actions" topic_name="{content}" topicid="{id}">&laquo;Edit</span>',
            '</tpl>',
            '<tpl if="this.canDelete(values)">',
              '<span class="forum-comment-delete forum-actions" topic_name="{content}" topicid="{id}">&laquo;Delete</span>',
            '</tpl>',
          '</div>',
        '</div>',
        '<div class="forum-topic-comment-right">',
          '<div class="forum-topic-comment-upper">',  
            '<div class="topic-comment-time">{[this.displayTime(values)]}</div>',
            '<div>',
              '{content}',
            '</div>',                
          '</div>',          
        '</div>',
        '<div class="forum-clear">&nbsp;</div>',
      '</div>',
      {
        canEdit: function (values) {
          var edit = (values.is_moderator || values.is_forum_admin || values.is_super_admin || values.is_user_owned);
          if (!edit && values.locked_at)
          {
            Ext.getCmp('reply_button').addClass('x-hide-display');
          }
          return edit;
        },
        canDelete: function (values) {
          return ((values.is_moderator || values.is_forum_admin || values.is_super_admin || values.is_user_owned) && values.comment_id) 
        },
        displayTime: function(values) {          
          if (values.created_at == values.updated_at)
          {
            return String.format("Created at {0}",Ext.util.Format.date(values.created_at,'n/d/Y h:i:s A'));
          }
          else{
            return String.format("Updated at {0}",Ext.util.Format.date(values.updated_at,'n/d/Y h:i:s A'));
          }
        }
      }
    );
    
    var commentIndexTpl = new Ext.XTemplate(      
      '<ul class="forum-list">',
        '<tpl for=".">',
          '<li class="forum-index-selector" topicId="{id}">',      
            '{[ this.renderTopic(values) ]}',                
          '</li>',          
        '</tpl>',
      '</ul>',
      {
        renderTopic: function(values){
          return commentTpl.apply(values);        
        }
      }
    );
    
    var indexView = new Ext.DataView({
      id: 'commentsIndex',
      store: store,
      tpl: commentIndexTpl,
      emptyText: "Click reply to respond!",
      listeners: {
        'click': { 
          fn:  function(div, index, node, e) {
            if (node.classList.contains('forum-comment-quote')) {            
              this.fireEvent('quotecomment', this.forumId, parseInt(node.attributes['topicid'].value));        
            }
            else if (node.classList.contains('forum-comment-edit')) {
              this.fireEvent('editcomment', this.forumId, parseInt(node.attributes['topicid'].value));
            }
            else if (node.classList.contains('forum-comment-delete')) {
              Ext.Msg.confirm("Delete Comment", 'Are you sure you wish to delete the topic?', function(btn){
                    if(btn === 'yes'){                        
                        this.fireEvent('deletetopic', this.forumId, parseInt(node.attributes['topicid'].value));
                        this.fireEvent('reload');
                    }
              }, this); 
            }
            else if(node.classList.contains('forum-topic-comment-poster-name') || node.classList.contains('forum-topic-comment-poster-picture')) {
              var user_id = parseInt(node.attributes['user_id'].value);
              var user_name = node.attributes['user_name'].value;
              Application.fireEvent('opentab', {title: 'Profile: ' + user_name, user_id: user_id, id: 'user_profile_for_' + user_id, initializer: 'Talho.ShowProfile'});
            }
        },
        scope: this }
      }
    });
    
    this.stores = [store]
    this.items.push(indexView);

    Talho.Forums.view.Topics.Show.superclass.initComponent.apply(this, arguments);
  },
  reload: function() {
    if (this.activated)
    {         
      for (i=0; i < this.items.getCount(); i++)
      {
        this.items.get(i).getStore().load();
        this.items.get(i).refresh();
      }
    }
    this.activated = true;
  },
  border : false,  
  header : false
}); 