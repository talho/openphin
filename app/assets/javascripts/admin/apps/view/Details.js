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
      {xtype: 'textfield', itemId: 'name', name: 'app[name]', fieldLabel: 'App Name', listeners: {scope: this, 'change': this.field_change}},
      {xtype: 'textfield', itemId: 'title', name: 'app[title]', fieldLabel: 'App Title', listeners: {scope: this, 'change': this.field_change}},
      {xtype: 'textfield', itemId: 'domains', name: 'app[domains]', fieldLabel: 'Domains (Comma Separated)', listeners: {scope: this, 'change': this.field_change}},
      {xtype: 'checkbox', itemId: 'is_default', name: 'app[is_default]', boxLabel: 'Is the default app', listeners: {scope: this, 'check': this.field_change} },
      {xtype: 'textfield', itemId: 'new_user_path', name: 'app[new_user_path]', fieldLabel: 'New User Path (when redefined)', listeners: {scope: this, 'change': this.field_change}},
      {xtype: 'textfield', itemId: 'help_email', name: 'app[help_email]', fieldLabel: 'Help Email', listeners: {scope: this, 'change': this.field_change}},
      {xtype: 'combo', itemId: 'root_jurisdiction_id', name: 'app[root_jurisdiction_id]', editable: true, forceSelection: true, valueNotFoundText: '', fieldLabel: 'Root Jurisdiction', 
        displayField: 'name', valueField: 'id', listeners: {scope: this, 'change': this.field_change}, mode: 'local', typeAhead: true, store: new Ext.data.JsonStore({
        fields: ['name', 'id'],
        root: 'jurisdictions',
        restful: true,
        url: '/jurisdictions.json',
        baseParams: {admin_mode: 1},
        autoLoad: true,
        listeners: {
          scope: this,
          'load': this._jurisdiction_load
        }
      })},
      {xtype: 'textarea', itemId: 'login_text', name: 'app[login_text]', fieldLabel: 'Login text (raw HTML)', height: 400, width: 500, listeners: {scope: this, 'change': this.field_change}},
    ]};
    
    Talho.Admin.Apps.view.Details.superclass.initComponent.apply(this, arguments);
  },
  
  _jurisdiction_load: function(){
    if(this.data && this.data.root_jurisdiction_id){
      this.getComponent('form').getComponent('root_jurisdiction_id').setValue(this.data.root_jurisdiction_id);
    }
  }
});
