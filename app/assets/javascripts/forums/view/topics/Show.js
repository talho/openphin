Ext.ns("Talho.Forums.view.Topics");

Talho.Forums.view.Topics.Show = Ext.extend(Ext.Panel, {
  layout : 'fit',
  height : 400,
  constructor : function() {      
    Talho.Forums.view.Topics.Show.superclass.constructor.apply(this, arguments);
  },
  initComponent : function() {
    if (!this.topicName)
    {
      this.topicName = 'Topic:';
    }
    else
    {
      this.setTitle('Topic: '+ this.topicName);
    }
    if(!this.items) {
      this.items = [];
    }
    var store = new Ext.data.JsonStore({
        url: String.format('/forums/{0}/topics/{1}.json',this.forumId,this.topicId),
        root: 'comments',
        autoLoad: true,
        restful: true,
        idProperty: 'id',
        fields: ['id', 'content', 'formatted_content', 'poster_name', 'user_id', 'user_avatar', 'created_at', 'forum_id',
                'updated_at', {name: 'is_moderator', type: 'boolean'}, {name: 'is_super_admin', type: 'boolean'}, {name: 'is_forum_admin', type: 'boolean'}, 'comment_id'] 
    });
    
    var person_column_template = '<div class="topic-user-column"><div class="topic-user-name">{poster_name}</div>' +
      '<div class="topic-user-picture"><img src="{user_avatar}" /></div></div>';
    var content_column_template = '<div class="topic-content-column"><table><tr><td colspan="2">{formatted_content}<td></tr>' +
      '<tr><td>Created at {created_at:date("Y-m-d g:i a")}</td><td>Updated at {updated_at:date("Y-m-d g:i a")}</td></tr></table></div>';
    var iconConfig = [
      {icon: '/assets/images/pencil.png', iconCls: 'edit_topic', tooltip: 'Edit Topic', handler: function(grid, i){var row = grid.getStore().getAt(i); this.fireEvent('editcomment',row.get('forum_id') ,row.get('id'));}, scope: this },      
      {icon: '/assets/images/cross-circle.png', iconCls: 'delete_topic', tooltip: 'Delete Topic', scope: this, 
      handler: function(grid, row){
          var store = grid.getStore();
          var row = store.getAt(row);
          Ext.Msg.confirm("Delete Record", 'Are you sure you wish to delete the comment?', function(btn){
              if(btn === 'yes'){
                  store.removeAt(row)
                  this.fireEvent('deletetopic', row.get('forum_id'), row.get('id') )
              }
          }, this);
      }}      
    ];
    
    
    this.items.push({xtype: 'grid', itemId: 'grid', cls: 'topic-list-grid', header: false, border: true, 
      store: store,
      columns: [
        {xtype: 'templatecolumn', dataindex: 'poster_name', header: 'Poster', tpl: person_column_template},
        {xtype: 'templatecolumn', dataindex: 'formatted_content', header: 'Content', id: 'formatted_content',  tpl: content_column_template},
        {xtype: 'actioncolumn', align: 'center', items: [{
          icon: '/assets/images/pencil.png', iconCls: 'quote_topic', tooltip: 'Quote Topic', scope: this, handler: function (grid, i) {
            var row = grid.getStore().getAt(i); this.fireEvent('quotecomment',row.get('forum_id') ,row.get('id'));  
          } 
        }]},        
        {xtype: 'actioncolumn', align: 'center', width: 30, items: iconConfig,
         getClass: function (v,meta,record) { 
           if (record.get('is_super_admin') || record.get('is_forum_admin') || record.get('is_moderator') || record.get('is_user_owned')) { 
            return 'x-action-col-cell'} 
          else { 
            return 'x-hide-display';} }
        }        
      ],
      autoExpandColumn: 'formatted_content',
      loadMask: true 
    });
    
    this.buttons = this.buttons || ['->'];
    this.buttons.push(
    {xtype : 'button', text: 'Reply', handler: function() {this.fireEvent('newcomment', this.forumId, this.topicId)}, scope: this},
    {xtype : 'button', text : 'Refresh', handler : function() { this.fireEvent('reload'); }, scope : this }
    );

    Talho.Forums.view.Topics.Show.superclass.initComponent.apply(this, arguments);
  },
  reload : function() {
    this.getComponent('grid').getStore().load();
  },
  mask : function() {
    this.getComponent('grid').loadMask.show();
  },
  unmask : function() {
    this.getComponent('grid').loadMask.hide();
  },
  border : false,  
  header : false
}); 