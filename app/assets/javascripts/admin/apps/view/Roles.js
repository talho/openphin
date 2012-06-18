//= require ./Helper

Ext.ns('Talho.Admin.Apps.view');

Talho.Admin.Apps.view.Roles = Ext.extend(Talho.Admin.Apps.view.Helper, {
  title: 'Roles',
  padding: '10px 100px',
  constructor: function(){
    Talho.Admin.Apps.view.Roles.superclass.constructor.apply(this, arguments);
  },
  initComponent: function(){
    this.items = [
      {xtype: 'box', cls: 't_boot', html: '<fieldset><legend>Roles</legend></fieldset>'}
    ];
    
    Talho.Admin.Apps.view.Roles.superclass.initComponent.apply(this, arguments);
  }
});
