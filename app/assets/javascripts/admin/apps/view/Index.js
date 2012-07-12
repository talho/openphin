//= require ext_extensions/xActionColumn

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
      {xtype: 'grid', itemId: 'grid', cls: 'app-grid', store: new Ext.data.JsonStore({
        fields: ['name', 'id', 'domains'],
        url: '/admin/app',
        restful: true,
        autoDestroy: true,
        autoLoad: true
      }), columns: [
        {id: 'name', dataIndex: 'name', header: "Name"},
        {id: 'domains', dataIndex: 'domains', header: "Domains"},
        {xtype: 'xactioncolumn', icon: '/assets/images/cross-circle.png', iconCls: 'app-delete-icon', handler: this.deleteApp, scope: this }
      ], autoExpandColumn: 'domains', loadMask: true, height: 400, width: 500, listeners: {
        scope: this,
        'rowclick': this._row_click
      }}
    ]
    Talho.Admin.Apps.view.Index.superclass.initComponent.apply(this, arguments);
  },
  
  _row_click: function(g, r, e){
    var tar = e.getTarget('.x-action-col-icon', 10, true);
    if(!tar){
      var rec = g.getStore().getAt(r);
      this.fireEvent('appselect', rec.get('name'), rec.get('id'));
    }
  },
  
  deleteApp: function(g, r){
    var app = g.getStore().getAt(r);
    Ext.Msg.confirm('Delete App', 'Are you sure you want to delete the app "' + app.get('name') + '"?', function(btn){
      if(btn == 'yes'){
        Ext.Ajax.request({
          url: '/admin/app/' + app.get('id'),
          method: 'DELETE',
          success: this.refreshGrid,
          scope: this
        });
      }
    }, this )
  },
  
  refreshGrid: function(){
    this.getComponent('grid').getStore().load();
  }
});
