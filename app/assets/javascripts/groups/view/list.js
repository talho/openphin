
Ext.ns('Talho.Groups.View')

Talho.Groups.View.List = Ext.extend(Ext.Container, {
  layout:'hbox', 
  layoutConfig: { padding: '30 30 30 30', pack: 'center' }, 
  autoScroll: true,
  
  initComponent: function(){
    this.addEvents('newgroup', 'groupdetail');
    
    var store = new Ext.data.JsonStore({ restful: true, url: '/admin/groups.json', root: 'groups', idProperty: 'id', remoteSort: 'true',
      totalProperty: 'count', per_page: 10, paramNames:{
          limit: 'per_page'
      },
      listeners:{
          scope: this,
          'beforeload': this.store_before_load,
          'beforesave': this.store_before_save,
          'save': this.store_save
      },
      fields:['name', 'scope', {name: "owner", mapping: "owner.display_name"}, {name: "owner_id", mapping: "owner.id"}, {name: 'owner_path', mapping: 'owner.profile_path'}, 'group_path'],
      autoSave: false, autoLoad: false,
      writer: new Ext.data.JsonWriter({
          encode: false
      })
    });
    
    var rowActions = new Ext.ux.grid.xActionColumn({
     items: [
       {icon: '/assets/images/page_edit.png', tooltip: 'Edit Group', iconCls: 'editBtn', handler: this.editBtn_click, scope: this},
       {xtype: 'spacer', width: 10},
       {icon: '/assets/cross-circle.png', tooltip: 'Delete Group', iconCls: 'removeBtn', handler: this.removeBtn_click, scope: this}
     ]
    });
    
    this.group_list = new Ext.grid.GridPanel({ store: store, border: true, width: 600, cls: 'groupList', height: 400,
      columns: [ {header: 'Name', id: 'name_column', dataIndex: 'name'},
        {header: 'Owner', dataIndex: 'owner'},
        {header: 'Scope', dataIndex: 'scope'},
        rowActions
      ], sm: false, autoExpandColumn: 'name_column', loadMask: true,
      listeners:{
        scope: this,
        'cellclick': this.grid_cellClick
      },
      buttons: [{xtype:'button', text:'Create New Group', handler: this.showNewGroup, scope: this}],
      bbar: new Ext.PagingToolbar({
        store: store,       // grid and PagingToolbar using same store
        pageSize: store.per_page
      })
    });

    this.infobox = new Ext.Container({ layout: 'column', width: 600, cls: 'infobox',
      items: [ {xtype: 'box', cls:'infobox-inner', width: 50, html:'<img src="/assets/info_icon.png">'},
        {xtype: 'container', cls:'infobox-inner', items:[
          {xtype: 'box', html: 'Click on a group to view details.'},
          {xtype: 'box', html: 'To Edit or Delete a group, use the icons on the right.'}
        ]}
      ]
    });

    this.contentWrapper = new Ext.Container({ items:[
        this.infobox,
        {xtype: 'spacer', height: '10'},
        this.group_list
      ]
    });

    this.items = [ this.contentWrapper ];
    this.on('show', function(){ this.group_list.getStore().load(); }, this);
    this.on('afterrender', function(){ if(this.group_list.loadMask.show) this.group_list.loadMask.show(); }, this, {delay: 1});
    
    Talho.Groups.View.List.superclass.initComponent.apply(this, arguments);
  },
  
  store_before_load: function(store, options){
    if(!options.params){
      options.params = {};
    }
    options.params['page'] = ((options.params.start || 0) / store.per_page) + 1;

    return true;
  },
  
  store_before_save: function(){
    if(!Ext.isBoolean(this.group_list.loadMask))
    {
      this.group_list.loadMask.msg = "Saving...";
      this.group_list.loadMask.show();
    }
    return true;
  },
  
  store_save: function(store){
    if(!Ext.isBoolean(this.group_list.loadMask))
    {
      this.group_list.loadMask.hide();
      this.group_list.loadMask.msg = "Loading...";
    }
    store.load();
  },
  
  editBtn_click: function(grid, row){
    var record = grid.getStore().getAt(row);
    this.fireEvent('newgroup', record.id);
  },
  
  removeBtn_click: function(grid, row, action, index, colIndex){
    var store = grid.getStore();
    var record = store.getAt(row);
    Ext.Msg.confirm('Confirm Deletion', "Are you sure you wish to delete " + record.get('name') + "?", function(btn){
      if(btn === "yes"){
        store.remove(record);
        store.save();
      }
    }, this);
  },
  
  grid_cellClick: function(grid, row, column, e){
    var fieldName = grid.getColumnModel().getDataIndex(column); // Get field name
    var record = grid.getStore().getAt(row);  // Get the Record
    if(fieldName === 'name')
    {
      this.fireEvent('groupdetail', record.id);
    }
    else if(fieldName === 'owner')
    {
      Application.fireEvent('opentab', {title: 'User Profile - ' + record.get('owner'), url: record.get('owner_path'), id: 'user_profile_for_' + record.get('owner_id') });
    }
  },
  
  showNewGroup: function(){
    this.fireEvent('newgroup');
  }
});        

        
