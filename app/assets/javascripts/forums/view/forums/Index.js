Ext.ns("Talho.Forums.view.Forums");

Talho.Forums.view.Forums.Index = Ext.extend(Ext.Panel, {
  layout: 'fit',
  height: 400,
  constructor: function(){
    this.addEvents('showtopic', 'editforum');
    Talho.Forums.view.Forums.Index.superclass.constructor.apply(this, arguments);
  },
  initComponent: function(){
    if (!this.items){
      this.items = [];
    }
    
    this.buttons = this.buttons || ['->'];
    this.buttons.push({xtype: 'button', id: 'newForumButton', text: 'New Forum', handler: function(){ this.fireEvent('newforum');}, scope: this},
      {xtype: 'button', text: 'Refresh', handler: function(){ this.fireEvent('reload');}, scope: this });
        
    
    var store = new Ext.data.JsonStore({
        url: '/forums.json',
        root: 'forums',
        restful: true,
        idProperty: 'id',
        fields: ['name', {name:'hidden_at', type: 'date'}, {name:'created_at', type:'date', dateFormat: 'Y-m-d\\Th:i:sP'}, {name:'updated_at', type:'date', dateFormat: 'Y-m-d\\Th:i:sP'},
                'lock_version', 'id', {name: 'is_moderator', type: 'boolean'}, {name: 'is_super_admin', type: 'boolean'}, {name: 'is_forum_admin', type: 'boolean'}, 'threads'],
        baseParams: {per_page: 20},
        autoLoad: {params: {start: 0}}               
    });
    
    this.items.push({xtype: 'grid', itemId: 'grid', header: false, border: true, 
      store: store,
      columns: [
        {header: 'Name', cls: 'forum-name', dataIndex: 'name', id: 'name'},
        {header: 'Topics', cls: 'forum-topic-count', dataIndex: 'threads', align: 'center'},
        {xtype: 'actioncolumn', align: 'center', width: 30, iconCls: 'edit_forum',
         icon: '/assets/images/pencil.png', 
         getClass: function (v,meta,record) { 
           if (record.get('is_super_admin') || record.get('is_forum_admin')) { 
            return 'x-action-col-cell'} else { 
            Ext.ComponentMgr.get('newForumButton').addClass('x-hide-display'); return 'x-hide-display';} }, 
         handler: function (grid,i) { 
           this.fireEvent('editforum', grid.getStore().getAt(i).get('id')) }, 
           scope: this, tooltip: 'Edit'},
       {xtype: 'actioncolumn', align: 'center',
         icon: '/assets/images/pencil.png', 
         getClass: function (v,meta,record) { 
           if (record.get('is_super_admin') || record.get('is_forum_admin')) { 
            return 'x-action-col-cell'} else { 
            Ext.ComponentMgr.get('newForumButton').addClass('x-hide-display'); return 'x-hide-display';} }, 
         handler: function (grid,i) { 
           this.fireEvent('manageforum', grid.getStore().getAt(i).get('id')) }, 
           scope: this, tooltip: 'Manage Forum'}             
      ],
      loadMask: true,      
      autoExpandColumn: 'name',
      listeners: {
        scope: this,
        'rowclick': function(grid,i,e) { 
          var target = e.getTarget(null, null, true);
                
          if (target.hasClass('x-action-col-icon')) {
              return;
          }
          var store = grid.getStore();
          this.fireEvent('showtopics',store.getAt(i).get('id'), store.getAt(i).get('name'));
        }
      }
    });
    
    Talho.Forums.view.Forums.Index.superclass.initComponent.apply(this, arguments);
  },
  reload: function () {    
    this.getComponent('grid').getStore().load();
  },
  border: false,
  title: 'Forums',
  header: false
});
