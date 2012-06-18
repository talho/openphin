
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
    this.items = {xtype: 'form', bodyCssClass: 't_boot', itemId: 'form', border: false, labelWidth: 200, items: [
      {xtype: 'box', html: '<fieldset><legend>New App</legend></fieldset>'},
      {xtype: 'textfield', fieldLabel: 'App Name'},
      {xtype: 'textfield', fieldLabel: 'Domains (Comma Separated)'},
      {xtype: 'textfield', fieldLabel: 'Help Email'},
      {xtype: 'combo', fieldLabel: 'Root Jurisdiction'}
    ], buttons: [
      {text: 'Save', handler: this._save_clicked, scope: this},
      {text: 'Cancel', handler: function(){this.getComponent('form').getForm().reset(); this.fireEvent('cancel');}, scope: this}
    ]};
    
    Talho.Admin.Apps.view.New.superclass.initComponent.apply(this, arguments);
  },
  
  _save_clicked: function(){
    // submit the form
    this._save_success(1);
  },
  
  _save_success: function(result){
    // get the id
    var name = 'asdf';
    var id = result;
    
    this.getComponent('form').getForm().reset()
    this.fireEvent('save', name, id);
  }
});
