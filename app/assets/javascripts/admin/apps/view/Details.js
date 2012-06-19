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
      {xtype: 'textfield', itemId: 'name', fieldLabel: 'App Name', listeners: {scope: this, 'change': this.field_change}},
      {xtype: 'textfield', fieldLabel: 'Domains (Comma Separated)', listeners: {scope: this, 'change': this.field_change}},
      {xtype: 'textfield', fieldLabel: 'Help Email', listeners: {scope: this, 'change': this.field_change}},
      {xtype: 'combo', fieldLabel: 'Root Jurisdiction', listeners: {scope: this, 'change': this.field_change}},
      {xtype: 'textarea', fieldLabel: 'Sign-in text (raw HTML)', height: 400, width: 500, listeners: {scope: this, 'change': this.field_change}},
    ]};
    
    Talho.Admin.Apps.view.Details.superclass.initComponent.apply(this, arguments);
    
    this.ownerCt.on('loadcomplete', this.load_data, this);
  },
  
  load_data: function(data){
    this.getComponent('form').getComponent('name').setValue(data.name)
  }
});
