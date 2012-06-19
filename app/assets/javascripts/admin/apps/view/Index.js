
Ext.ns('Talho.Admin.Apps.view')

Talho.Admin.Apps.view.Index = Ext.extend(Ext.Panel, {
  title: 'App List',
  padding: '50px 100px',
  constructor: function(){
    Talho.Admin.Apps.view.Index.superclass.constructor.apply(this, arguments);
    
    this.addEvents('appselect')
  },
  
  initComponent: function(){
    // add grid
    this.items = [
      {xtype: 'box', cls: 't_boot', html: '<fieldset><legend>Apps</legend></fieldset>'},
      {xtype: 'grid', store: new Ext.data.JsonStore({
        fields: ['name', 'id', 'domains'],
        url: '/admin/app',
        restful: true,
        autoLoad: true
      }), columns: [
        {id: 'name', dataIndex: 'name', header: "Name"},
        {id: 'domains', dataIndex: 'domains', header: "Domains"}
      ], autoExpandColumn: 'domains', loadMask: true, height: 400, width: 500, listeners: {
        scope: this,
        'rowclick': this._row_click
      }}
    ]
    Talho.Admin.Apps.view.Index.superclass.initComponent.apply(this, arguments);
  },
  
  _row_click: function(g, r, e){
    var rec = g.getStore().getAt(r);
    this.fireEvent('appselect', rec.get('name'), rec.get('id'));
  }
});
