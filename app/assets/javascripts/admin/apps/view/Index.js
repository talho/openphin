
Ext.ns('Talho.Admin.Apps.view')

Talho.Admin.Apps.view.Index = Ext.extend(Ext.Panel, {
  title: 'App List',
  padding: '50px 100px',
  constructor: function(){
    Talho.Admin.Apps.view.Index.superclass.constructor.apply(this, arguments);
  },
  
  initComponent: function(){
    // add grid
    this.items = [
      {xtype: 'box', cls: 't_boot', html: '<fieldset><legend>Apps</legend></fieldset>'},
      {xtype: 'grid', store: new Ext.data.JsonStore({
        fields: ['name'],
        data: [{name: 'phin'}]
      }), columns: [
        {dataIndex: 'name', header: "Name"}
      ], height: 400, width: 500}
    ]
    Talho.Admin.Apps.view.Index.superclass.initComponent.apply(this, arguments);
  }
});
