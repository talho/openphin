//= require ext_extensions/PillPanel

Ext.ns("Talho.Admin.Apps.view");

Talho.Admin.Apps.view.Show = Ext.extend(Ext.ux.PillPanel, {
  closable: true,
  title: 'App Details',
  constructor: function(){
    Talho.Admin.Apps.view.Show.superclass.constructor.apply(this, arguments);
    
    this.addEvents('change');
  },
  
  initComponent: function(){
    // Set up items
    this.items = [
      new Talho.Admin.Apps.view.Details({listeners: {scope: this, 'change': this._field_change} }),
      new Talho.Admin.Apps.view.Roles({listeners: {scope: this, 'change': this._field_change} }),
      new Talho.Admin.Apps.view.Assets({listeners: {scope: this, 'change': this._field_change} }),
      new Talho.Admin.Apps.view.About({listeners: {scope: this, 'change': this._field_change} })
    ];
    
    Talho.Admin.Apps.view.Show.superclass.initComponent.apply(this, arguments);
    
    // Load the component
  },
  
  _field_change: function(name, val){
    this.fireEvent('change', this.appId, name, val);
  }
});