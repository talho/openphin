Ext.define('Talho.view.Viewport',{
  extend: 'Ext.container.Viewport',
  layout: 'fit',
  requires: [
    'Talho.view.favorites.Bar',
    'Talho.view.application.TabPanel',
    'Talho.view.dashboard.View'
  ],
  initComponent: function(){
    this.items = {
      xtype: 'panel',
      border: false,
      layout: 'fit',
      bbar: Application.bbarConfig,
      dockedItems: [ {xtype: 'toolbar', dock: 'top', items: Application.menuConfig}, 
        { xtype: 'favoritesbar', dock: 'top'}
      ],
      items:{
        xtype: 'applicationtabpanel',
        items: {xtype: 'dashboardview' }
      }
    }
    this.callParent();
  }
});
