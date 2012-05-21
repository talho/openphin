Ext.ns("Talho.Forums.view.Topics");

Talho.Forums.view.Topics.Index = Ext.extend(Ext.Panel, {
  layout : 'fit',
  height : 400,
  constructor : function() {
    this.addEvents('edittopic');
    this.on('activate', this.reload, this);
    
    Talho.Forums.view.Topics.Index.superclass.constructor.apply(this, arguments);
  },
  initComponent : function() {
    if (!this.forumName)
    {
      this.forumName = 'Forum:'; 
    }
    else
    {
      this.setTitle('Forum: ' + this.forumName);
    }
    if(!this.items) {
      this.items = [];
    }
  
    var leadIconConfig = [
        {icon: '/assets/yellow_thumbtack.png', iconCls: 'topic_pinned', tooltip: 'Pinned', showField: 'sticky'},
        {icon: '/assets/resources/images/default/grid/hmenu-lock.png', iconCls: 'topic_closed', tooltip: 'Closed', showField: 'locked'}
    ];
    
    this.items.push({xtype: 'grid', itemId: 'grid', header: false, border: true, 
      store: new Ext.data.JsonStore({
        url: '/forums/' + this.forumId + '/topics.json',
        root: 'topics',
        restful: true,
        idProperty: 'comment_id',        
        fields:  ['forum_id', 'comment_id', 'id', {name: 'sticky', type:'boolean'}, 'locked_at', 'locked',
                'name', 'content', 'poster_id', 'hidden_at', 'poster_name', 'created_at', 'updated_at',
                'lock_version', {name:'is_moderator', type:'boolean'}, {name:'is_forum_admin', type:'boolean'}, {name:'is_super_admin', type:'boolean'},
                {name:'is_user_owned', type:'boolean'},'id', 'posts', 'user_avatar'],
        autoLoad: true
      }),
      columns: [
        {xtype: 'xactioncolumn', items: leadIconConfig, vertical: true, sortable: false},                      
        {id: 'name_column', header: 'Name', sortable: true, dataIndex: 'name', sortable: false},
        {header: 'Replies', sortable: true, dataIndex: 'posts', width: 55, sortable: false},
        {xtype: 'templatecolumn', header: 'Poster', sortable: true, dataIndex: 'poster_name', id: 'poster', width: 100, tpl: '<span class="inlineLink">{poster_name}</span>', sortable: false},
        {header: 'Created At', sortable: true, dataIndex: 'created_at', renderer: Ext.util.Format.dateRenderer('n/j/Y h:i:s A'), width: 135, sortable: false},
        {header: 'Last Updated', sortable: true, dataIndex: 'updated_at', renderer: Ext.util.Format.dateRenderer('n/j/Y h:i:s A'), width: 135, sortable: false},
        {xtype: 'actioncolumn', align: 'center', width: 30, sortable: false,
         icon: '/assets/images/pencil.png',
         iconCls: 'edit_topic',
         getClass: function (v,meta,record) { 
           if (record.get('is_super_admin') || record.get('is_forum_admin') || record.get('is_moderator') || record.get('is_user_owned')) {
            return 'x-action-col-cell'} else { 
            Ext.ComponentMgr.get('newSubforumButton').addClass('x-hide-display'); return 'x-hide-display';} }, 
         handler: function (grid,i) { 
           this.fireEvent('edittopic', this.forumId ,grid.getStore().getAt(i).get('id')) }, 
           scope: this, tooltip: 'Edit Topic'},
         {xtype: 'actioncolumn', align: 'center', width: 30, sortable: false,
           icon: '/assets/resources/images/default/layout/collapse.gif',
           iconCls: 'move_topic',
           getClass: function (v,meta,record) { 
             if (record.get('is_super_admin') || record.get('is_forum_admin') || record.get('is_moderator')) { 
              return 'x-action-col-cell'} else { 
                return 'x-hide-display';} }, 
           handler: function (grid,i) {
              var store = grid.getStore();
              var record = store.getAt(i);
              this.fireEvent('movetopic',record.get('forum_id'),record.get('id'),this.forumName,record.get('name'));
             }, 
             scope: this, tooltip: 'Move Topic'},
         {xtype: 'actioncolumn', align: 'center', width: 30, sortable: false,
           icon: '/assets/images/cross-circle.png',
           iconCls: 'delete_topic',
           getClass: function (v,meta,record) { 
             if (record.get('is_super_admin') || record.get('is_forum_admin') || record.get('is_moderator')) { 
              return 'x-action-col-cell'} else { 
                return 'x-hide-display';} }, 
           handler: function(grid, row){
              var store = grid.getStore();
              var row = store.getAt(row);
              Ext.Msg.confirm("Delete Record", 'Are you sure you wish to delete the topic "' + row.get("name") + '"', function(btn){
              if(btn === 'yes'){
                  store.removeAt(row)
                  this.fireEvent('deletetopic', row.get('forum_id'), row.get('id') );
                }
              }, this);
            },
          scope: this, tooltip: 'Delete Topic'},
      ],
      loadMask: true,
      autoExpandColumn: 'name_column',
      listeners: {
        scope: this,        
        'rowclick': function(grid, i, e) {
          var target = e.getTarget(null, null, true);                  
          var row = grid.getStore().getAt(i);
          
          if (target.hasClass('x-action-col-icon')) {
              return;
          }
          
          if (target.hasClass('inlineLink'))
          {
            Application.fireEvent('opentab', {title: 'Profile: ' + row.get('poster_name'), user_id: row.get('poster_id'), id: 'user_profile_for_' + row.get('poster_id'), initializer: 'Talho.ShowProfile'});
            return;
          }
          
          this.fireEvent('showtopic', this.forumId, row.get('id'), row.get('name'));
        },
        scope: this,
      }
    });

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
    this.getComponent('grid').getStore().load();
  },
  border : false,  
  header : false
}); 