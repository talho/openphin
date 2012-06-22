//= require ext_extensions/PillPanel

Ext.ns("Talho.Admin.Apps.view");

Talho.Admin.Apps.view.Show = Ext.extend(Ext.ux.PillPanel, {
  closable: true,
  title: 'App Details',
  constructor: function(){
    Talho.Admin.Apps.view.Show.superclass.constructor.apply(this, arguments);
    
    this.addEvents('change', 'loadcomplete');
  },
  
  initComponent: function(){
    // Set up items
    this.items = [
      new Talho.Admin.Apps.view.Details({ownerCt: this, listeners: {scope: this, 'change': this._field_change} }),
      new Talho.Admin.Apps.view.Roles({ownerCt: this, listeners: {scope: this, 'change': this._field_change} }),
      new Talho.Admin.Apps.view.Assets({ownerCt: this, listeners: {scope: this, 'change': this._field_change} }),
      new Talho.Admin.Apps.view.About({ownerCt: this, listeners: {scope: this, 'change': this._field_change} })
    ];
    
    Talho.Admin.Apps.view.Show.superclass.initComponent.apply(this, arguments);
    
    // Load the app
    Ext.Ajax.request({
      url: '/admin/app/' + this.appId,
      method: 'GET',
      success: this._load_success,
      scope: this
    });
  },
  
  _load_success: function(resp){
    var data = Ext.decode(resp.responseText);
    this.fireEvent('loadcomplete', data);
  },
  
  _field_change: function(name, val){
    this.fireEvent('change', this.appId, name, val);
  }
});