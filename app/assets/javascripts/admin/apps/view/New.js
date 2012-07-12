
Ext.ns('Talho.Admin.Apps.view');

Talho.Admin.Apps.view.New = Ext.extend(Ext.Panel, {
  title: 'New App',
  layout: 'fit',
  padding: '50px 100px',
  constructor: function(){
    Talho.Admin.Apps.view.New.superclass.constructor.apply(this, arguments);
    this.addEvents('save', 'cancel');
  },
  
  initComponent: function(){
    // Add form with required information for the app
    this.items = {xtype: 'form', bodyCssClass: 't_boot', itemId: 'form', border: false, labelWidth: 200, 
      url: '/admin/app',
      method: 'POST',
      items: [
        {xtype: 'box', html: '<fieldset><legend>New App</legend></fieldset>'},
        {xtype: 'textfield', itemId: 'name', name: 'app[name]', fieldLabel: 'App Name'},
        {xtype: 'textfield', itemId: 'domains', name: 'app[domains]', fieldLabel: 'Domains (Comma Separated)'}
    ], buttons: [
      {text: 'Save', handler: this._save_clicked, scope: this},
      {text: 'Cancel', handler: function(){this.getComponent('form').getForm().reset(); this.fireEvent('cancel');}, scope: this}
    ]};
    
    Talho.Admin.Apps.view.New.superclass.initComponent.apply(this, arguments);
  },
  
  _save_clicked: function(){
    this.getComponent('form').getForm().submit({
      success: this._save_success,
      scope: this
    });
  },
  
  _save_success: function(form, a){
    // get the id
    var name = a.result.name,
        id = a.result.id;
    
    this.getComponent('form').getForm().reset()
    this.fireEvent('save', name, id);
  }
});
