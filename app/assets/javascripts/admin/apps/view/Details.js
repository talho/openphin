//= require ./Helper

Ext.ns('Talho.Admin.Apps.view');

Talho.Admin.Apps.view.Details = Ext.extend(Talho.Admin.Apps.view.Helper, {
  title: 'Details',
  padding: '10px 100px',
  constructor: function(){
    Talho.Admin.Apps.view.Details.superclass.constructor.apply(this, arguments);
  },
  initComponent: function(){
    this.items = {xtype: 'form', bodyCssClass: 't_boot', itemId: 'form', border: false, labelWidth: 200, items: [
      {xtype: 'box', html: '<fieldset><legend>App Details</legend></fieldset>'},
      {xtype: 'textfield', fieldLabel: 'App Name', listeners: {scope: this, 'change': this.field_change}},
      {xtype: 'textfield', fieldLabel: 'Domains (Comma Separated)', listeners: {scope: this, 'change': this.field_change}},
      {xtype: 'textfield', fieldLabel: 'Help Email', listeners: {scope: this, 'change': this.field_change}},
      {xtype: 'combo', fieldLabel: 'Root Jurisdiction', listeners: {scope: this, 'change': this.field_change}}
    ]};
    
    Talho.Admin.Apps.view.Details.superclass.initComponent.apply(this, arguments);
  }
});
