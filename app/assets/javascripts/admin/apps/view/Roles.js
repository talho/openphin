//= require ./Helper
//= require ext_extensions/xActionColumn
//= require ./RoleWindow

Ext.ns('Talho.Admin.Apps.view');

Talho.Admin.Apps.view.Roles = Ext.extend(Talho.Admin.Apps.view.Helper, {
  title: 'Roles',
  padding: '10px 100px',
  constructor: function(){
    Talho.Admin.Apps.view.Roles.superclass.constructor.apply(this, arguments);
  },
  initComponent: function(){
    this.items = [
      {xtype: 'box', cls: 't_boot', html: '<fieldset><legend>Roles</legend></fieldset>'},
      {xtype: 'grid', itemId: 'grid', height: 400, width: 500, loadMask: true, store: new Ext.data.JsonStore({
        autoDestroy: true,
        url: '/admin/roles',
        restful: true,
        baseParams: { app_id: this.ownerCt.appId },
        fields: ['name', 'id', 'description', 'alerter', 'user_role', 'public']
      }), columns: [
        {header: 'Name', dataIndex: 'name', id: 'name'},
        {header: 'Public', dataIndex: 'public', width: 50},
        {header: 'User Selectable', dataIndex: 'user_role'},
        {xtype: 'xactioncolumn', items: [
          {icon: '/assets/images/pencil.png', handler: this.editRole, scope: this},
          {icon: '/assets/images/cross-circle.png', handler: this.deleteRole, scope: this}
        ]}
      ], autoExpandColumn: 'name',
      buttons: [
        {text: 'New Role', scope: this, handler: this.newRole }
      ]
    }];
    
    
    Talho.Admin.Apps.view.Roles.superclass.initComponent.apply(this, arguments);
    
    if(this.ownerCt){
      this.ownerCt.on('loadcomplete', this.load_roles, this);
    }
  },
  
  load_roles: function(data){
    this.getComponent('grid').getStore().loadData(data.roles);
  },
  
  newRole: function(){
    // Show the new role window
    var win = new Talho.Admin.Apps.view.RoleWindow({
      state: 'new',
      listeners: {
        scope: this,
        'save': this.reloadGrid
      }
    });
    win.show();
  },
  
  editRole: function(g, r){
    var role = g.getStore().getAt(r);
    // Show the edit role window
    var win = new Talho.Admin.Apps.view.RoleWindow({
      state: 'edit',
      role: role,
      listeners: {
        scope: this,
        'save': this.reloadGrid
      }
    });
    win.show();
  },
  
  reloadGrid: function(){
    this.getComponent('grid').getStore().load();
  },
  
  deleteRole: function(g, r){
    var role = g.getStore().getAt(r);
    Ext.Msg.confirm("Delete Role", "Are you sure you would like to delete role " + role.get('name') + "?", function(btn){
      if(btn == 'yes'){
        Ext.Ajax.request({
          url: '/admin/roles/' + role.get('id'),
          method: 'DELETE',
          success: this.reloadGrid,
          scope: this
        });
      }
    }, this);
  }
});
