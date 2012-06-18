//= require ./Helper

Ext.ns('Talho.Admin.Apps.view');

Talho.Admin.Apps.view.Assets = Ext.extend(Talho.Admin.Apps.view.Helper, {
  title: 'Assets',
  padding: '10px 100px',
  constructor: function(){
    Talho.Admin.Apps.view.Assets.superclass.constructor.apply(this, arguments);
  },
  initComponent: function(){
    this.items = {xtype: 'form', bodyCssClass: 't_boot', itemId: 'form', border: false, labelWidth: 200, items: [
      {xtype: 'box', html: '<fieldset><legend>App Assets</legend></fieldset>'},
      {xtype: 'textfield', fieldLabel: 'Logo (for login page)', listeners: {scope: this, 'change': this.field_change}},
      {xtype: 'textfield', fieldLabel: 'Tiny Logo (for dashboard)', listeners: {scope: this, 'change': this.field_change}}
    ]};
    
    Talho.Admin.Apps.view.Assets.superclass.initComponent.apply(this, arguments);
  }
});
