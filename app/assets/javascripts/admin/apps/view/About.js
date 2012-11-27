//= require ./Helper

Ext.ns('Talho.Admin.Apps.view');

Talho.Admin.Apps.view.About = Ext.extend(Talho.Admin.Apps.view.Helper, {
  title: 'About',
  padding: '10px 100px',
  autoScroll: true,
  constructor: function(){
    Talho.Admin.Apps.view.About.superclass.constructor.apply(this, arguments);
  },
  initComponent: function(){
    this.items = {xtype: 'form', bodyCssClass: 't_boot', itemId: 'form', border: false, labelWidth: 200, items: [
      {xtype: 'box', html: '<fieldset><legend>About Page</legend></fieldset>'},
      {xtype: 'textfield', itemId: 'info_path', name: 'app[info_path]', fieldLabel: 'App Info Path', listeners: {scope: this, 'change': this.field_change}},
      {xtype: 'textfield', itemId: 'about_label', name: 'app[about_label]', fieldLabel: 'About Page Label', listeners: {scope: this, 'change': this.field_change}},
      {xtype: 'textarea', itemId: 'about_text', name: 'app[about_text]', fieldLabel: 'About Page HTML (raw)', height: 400, width: 500, listeners: {scope: this, 'change': this.field_change}}
    ]};
    
    Talho.Admin.Apps.view.About.superclass.initComponent.apply(this, arguments);
  }
});
