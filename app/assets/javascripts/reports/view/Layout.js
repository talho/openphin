
Ext.ns("Talho.Reports.view");

Talho.Reports.view.Layout = Ext.extend(Ext.Panel, {
  layout: 'hbox', 
  title: 'Reports',
  closable: true,
  layoutConfig: {defaultMargins: '5', align: 'stretch'},
  initComponent: function(){
    this.items = [
      new Talho.Reports.view.Index({flex: 1}),
      {xtype: 'box', flex: 1},
      {xtype: 'box', flex: 1}
    ]
    
    Talho.Reports.view.Layout.superclass.initComponent.apply(this, arguments);
  }
});

Ext.reg('talho-reports-layout', Talho.Reports.view.Layout);
