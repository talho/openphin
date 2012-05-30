Ext.ns("Talho.Forums.view.Topics");

Talho.Forums.view.Topics.Index = Ext.extend(Ext.Panel, {
  autoHeight: true,
  constructor : function() {
    this.addEvents('edittopic');
    this.on('activate', this.reload, this);
    this.on('reload', this.reload, this);
    
    Talho.Forums.view.Topics.Index.superclass.constructor.apply(this, arguments);
  },
  initComponent : function() {
    this.setTitle('Forum: ' + this.forumName);
        
    var forumStore = new Ext.data.JsonStore({
        url: String.format('/forums/{0}.json',this.forumId),
        restful: true,
        root: 'subforums',          
        fields: ['name', {name:'hidden_at', type: 'date'}, {name:'created_at', type:'date', dateFormat: 'Y-m-d\\Th:i:sP'}, {name:'updated_at', type:'date', dateFormat: 'Y-m-d\\Th:i:sP'},
                'lock_version', 'id', {name: 'is_moderator', type: 'boolean'}, {name: 'is_super_admin', type: 'boolean'}, {name: 'is_forum_admin', type: 'boolean'}, 'threads', 'subforums'],                
    });      
        
    var forumTpl = new Ext.XTemplate(      
      '<div class="forum-wrap" forumid="{id}">',
        '<div class="forum-left" forumid="{id}"><table>',
          '<tr>',
            '<td><span class="forum-title" forum_name="{name}" forumid="{id}">{name}</span></td>',
          '</tr>',
          '<tr>',
            '<td>',
              '<tpl if="this.canEdit(values)">',
                '<span class="forum-edit forum-actions" forum_name="{name}" forumid="{id}">&laquo;Edit</span>',
              '</tpl>',
              '<tpl if="this.canManage(values)">',
                '<span class="forum-manage forum-actions" forum_name="{name}" forumid="{id}" alt="Manage Forum">&laquo;Manage</span>',
              '</tpl>',
            '<td>',
          '</tr>',
        '</table></div>',        
        '<div class="forum-reply-count">{threads}</div>',
        '<div class="forum-clear"></div>' ,       
      '</div>',
      {
        canEdit: function(values){
          return (this.isAdmin(values) || values.is_owner);
        },
        canManage: function(values){
          return this.isAdmin(values);
        },
        isAdmin: function (values){
          if (values.is_super_admin || values.is_forum_admin)
          {
            return true;
          }
          return false;
        }
      }
    );
    
     var forumIndexTpl = new Ext.XTemplate(
      '<div class="forum-header">',
        '<span class="forum-header-title">Subforums</span>',
        '<span class="forum-header-threads">Threads</span>',
      '</div>',
      '<div class="forum-divider">&nbsp;</div>',
      '<ul class="forum-list" forumid="{id}">',
        '<tpl for=".">',
          '<li class="forum-index-selector" forumid="{id}">',      
            '{[ this.renderForum(values) ]}',                
          '</li>',          
        '</tpl>',
      '</ul>',
      {
        renderForum: function(values){
          return forumTpl.apply(values); 
        }        
      }
    );
    
    var forumIndexView = new Ext.DataView({
      store: forumStore,
      tpl: forumIndexTpl,
      id: 'forumsIndex',
      autoHeight: true,
      listeners: {
        'click': { 
          fn:  function(div, index, node, e) {
            if (node.classList.contains('forum-edit')) {            
              this.fireEvent('editforum', parseInt(node.attributes['forumid'].value), null);        
            }
            else if (node.classList.contains('forum-manage')) {
              this.fireEvent('manageforum', parseInt(node.attributes['forumid'].value));
            }
            else if (node.attributes['forumid']) {
              var forumId = node.attributes['forumid'].value;
              var forumName = Ext.DomQuery.selectValue(".forum-title[forumId=" + forumId + "]");
              this.fireEvent('showtopics', parseInt(forumId), forumName);
            }
        },
        scope: this }
      }
    });
    
    var topicStore = new Ext.data.JsonStore({
        url: String.format('/forums/{0}/topics.json',this.forumId),
        restful: true,
        root: 'topics',        
        fields: ['forum_id', 'comment_id', 'id', {name: 'sticky', type:'boolean'}, 'locked_at', 'locked',
                'name', 'content', 'poster_id', 'hidden_at', 'poster_name', 'created_at', 'updated_at',
                'lock_version', {name:'is_moderator', type:'boolean'}, {name: 'is_forum_admin', type: 'boolean'}, 
                {name: 'is_user_owned', type: 'boolean'}, {name:'is_super_admin', type:'boolean'}, 'id', 'posts', 'user_avatar'],                
    });
            
    var topicTpl = new Ext.XTemplate(
      '<div class="forum-topic-wrap">',
        '<div class="forum-left" forumid="{id}"><table>',
          '<tr>',
            '<td>',              
              '<span class="forum-title forum-topic-title" topic_name="{name}" topicid="{id}">',
              '<tpl if="this.stickied(values)">',
                'Sticky: ',
              '</tpl>',
              '{name}',
              '<tpl if="this.locked(values)">',
                ' <img src="/assets/resources/images/default/grid/hmenu-lock.png" alt="Locked" />',
              '</tpl>',
              '</span>',
            '</td>',
          '</tr>',
          '<tr>',
            '<td>',
              '<tpl if="this.canEdit(values)">',
                '<span class="forum-topic-edit forum-actions" topic_name="{name}" topicid="{id}">&laquo;Edit</span>',
              '</tpl>',
              '<tpl if="this.canMove(values)">',
                '<span class="forum-topic-move forum-actions" topic_name="{name}" topicid="{id}" alt="Manage Forum">&laquo;Move</span>',
              '</tpl>',
              '<tpl if="this.canDelete(values)">',
                '<span class="forum-topic-delete forum-actions" topic_name="{name}" topicid="{id}" alt="Manage Forum">&laquo;Delete</span>',
              '</tpl>',
            '<td>',
          '</tr>',
        '</table></div>',
        '<div class="forum-reply-count">{posts}</div>',
        '<div class="forum-clear"></div>' ,
      '</div>',
      {
        stickied: function (values) {
          return values.sticky;
        },        
        locked: function (values) {
          return values.locked;
        },
        canEdit: function (values) {
          return this.isAdmin(values) || values.is_moderator || values.is_user_owned;
        },
        canMove: function (values) {
          return this.isAdmin(values) || values.is_moderator;
        },
        canDelete: function (values) {
          return this.isAdmin(values) || values.is_moderator;
        },
        isAdmin: function (values){
          if (values.is_super_admin || values.is_forum_admin)
          {
            return true;
          }
          else
          {
            Ext.getCmp('newSubforumButton').addClass('x-hide-display');
            return false;
          }
        }   
      }
    );
    
    var topicIndexTpl = new Ext.XTemplate(
      '<div class="forum-header">',
        '{[this.setUpCounter()]}',
        '<span class="forum-header-title">Topics</span>',
        '<span class="forum-header-threads">Replies</span>',
      '</div>',
      '<div class="forum-divider">&nbsp;</div>',
      '<ul class="forum-list">',
        '<tpl for=".">',
          '<li class="forum-index-selector forum-topic-row-{[this.getCurrentCount()]}" topicId="{id}">',      
            '{[ this.renderTopic(values) ]}',                
          '</li>',          
        '</tpl>',
      '</ul>',
      {
        renderTopic: function(values){
          return topicTpl.apply(values); 
        },
        getCurrentCount: function () {
          this.counter++;
          return this.counter;
        },
        setUpCounter: function () {
          this.counter = 0;
          return "";
        }
      }
    );
    
    var topicIndexView = new Ext.DataView({
      id: 'topicsIndex',
      store: topicStore,
      tpl: topicIndexTpl,
      emptyText: 'Click the "New Topic" button to make a topic',
      listeners: {
        'click': { 
          fn:  function(div, index, node, e) {
            if (node.classList.contains('forum-topic-edit')) {            
              this.fireEvent('edittopic', this.forumId, parseInt(node.attributes['topicid'].value));        
            }
            else if (node.classList.contains('forum-topic-move')) {
              this.fireEvent('movetopic', this.forumId, parseInt(node.attributes['topicid'].value), this.forumName, node.attributes['topic_name'].value);  
            }
            else if (node.classList.contains('forum-topic-delete')) {
              Ext.Msg.confirm("Delete Topic", 'Are you sure you wish to delete the topic?', function(btn){
                    if(btn === 'yes'){                        
                        this.fireEvent('deletetopic', this.forumId, parseInt(node.attributes['topicid'].value));
                        this.fireEvent('reload');
                    }
              }, this);              
            }
            else if (node.attributes['topicid']) {
              var topicId = node.attributes['topicId'].value;
              var topicName = Ext.DomQuery.selectValue(".forum-title[topicId=" + topicId + "]");
              this.fireEvent('showtopic', this.forumId, parseInt(topicId), topicName);
            }
        },
        scope: this }
      }
    });
    
    topicStore.load();    
    forumStore.load({
      callback: function () {
        if (this.getCount() == 0)
        {
          Ext.getCmp('forumsIndex').addClass('x-hide-display');
        }
      }
    });
    
    this.stores = [forumStore, topicStore];    
    this.items = [forumIndexView, topicIndexView];
    
    this.buttons = this.buttons || ['->'];    
    this.buttons.push(
      {xtype: 'button', text: 'New Subforum', id: 'newSubforumButton', handler: function() {this.fireEvent('newsubforum', null, this.forumId)}, scope: this},
      {xtype : 'button', text: 'New Topic', handler: function() {this.fireEvent('newtopic', this.forumId)}, scope: this},{
      xtype : 'button',
      text : 'Refresh',
      handler : function() {
        this.fireEvent('reload');
      },
      scope : this
    });

    Talho.Forums.view.Topics.Index.superclass.initComponent.apply(this, arguments);
  },
  reload : function() {
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