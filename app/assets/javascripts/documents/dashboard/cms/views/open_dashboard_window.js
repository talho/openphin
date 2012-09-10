Ext.ns('Talho.Dashboard.CMS.Views');

Talho.Dashboard.CMS.Views.OpenDashboardWindow = Ext.extend(Ext.Window, {
  width: 250,
  height: 250,
  layout: 'fit',
  title: 'Open Dashboard',
  modal: true,
  cls: 'cms-open-dash-window',
  initComponent: function(){
    this.items = [
      {xtype: 'grid', itemId: 'grid', store: new Ext.data.JsonStore({
          url: '/dashboard.json',
          baseParams: {for_admin: true},
          restful: true,
          fields: ['name', 'id'],
          autoLoad: true,
          root: 'dashboards'
        }),
        hideHeaders: true,
        columns: [{dataIndex: 'name', id: 'name'}],
        autoExpandColumn: 'name',
        loadMask: true,
        sm: new Ext.grid.RowSelectionModel({singleSelect: true})
      }
    ];
    
    this.buttons = [
      {text: 'Open', scope: this, handler: this.openDashboard },
      {text: 'Cancel', scope: this, handler: function(){this.close();}}
    ]
    
    Talho.Dashboard.CMS.Views.NewDashboardWindow.superclass.initComponent.call(this);
  },
  
  openDashboard: function(){
    var grid = this.getComponent('grid'),
        sm = grid.getSelectionModel(),
        rc = sm.getSelected();
    if(rc){
      this.fireEvent('open', rc.get('id'));
      this.close();
    }
  }
});
