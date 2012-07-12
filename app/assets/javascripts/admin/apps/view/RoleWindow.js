//= require ext_extensions/SubmitFalse

Ext.ns('Talho.Admin.Apps.view');

Talho.Admin.Apps.view.RoleWindow = Ext.extend(Ext.Window, {
  width: 500,
  modal: true,
  constructor: function(){
    Talho.Admin.Apps.view.RoleWindow.superclass.constructor.apply(this, arguments);
    this.addEvents('save');
  },
  
  initComponent: function(){
    this.setTitle(this.state == 'new' ? 'New Role' : 'Edit Role');
    
    var form_opts = {};
    if(this.state == 'new'){
      form_opts = {
        url: '/admin/roles',
        method: 'POST',
        baseParams: {'role[app_id]': this.appId}
      }
    }
    else{
      form_opts = {
        url: '/admin/roles/' + this.role.get('id'),
        method: 'PUT'
      }
    }
    
    this.items = Ext.apply({ xtype: 'form', itemId: 'form', padding: '10', items: [
      {xtype: 'textfield', itemId: 'name', name: 'role[name]', anchor: '100%', fieldLabel: 'Name'},
      {xtype: 'checkbox', itemId: 'public', name: 'role[public]', boxLabel: 'Public', plugins: ['checkboxsubmitfalse']},
      {xtype: 'checkbox', itemId: 'user_role', name: 'role[user_role]', boxLabel: 'User selectable', plugins: ['checkboxsubmitfalse']},
      {xtype: 'checkbox', itemId: 'alerter', name: 'role[alerter]', boxLabel: 'Able to send alerts', plugins: ['checkboxsubmitfalse']},
      {xtype: 'textarea', itemId: 'description', name: 'role[description]', fieldLabel: 'Description', anchor: '100%', height: 100}
    ]}, form_opts);
    
    this.buttons = [
      {text: 'Save', handler: function(){this.getComponent('form').getForm().submit({
        success: this.save_complete,
        scope: this
      });}, scope: this},
      {text: 'Cancel', handler: function(){this.close();}, scope: this}
    ]
    
    Talho.Admin.Apps.view.RoleWindow.superclass.initComponent.apply(this, arguments);
    
    if(this.state == 'edit'){
      var form = this.getComponent('form');
      this.role.fields.each(function(f){
        var field = form.getComponent(f.name);
        if(field){
          field.setValue(this.role.get(f.name));
        }
      }, this);
    }
  },
  
  save_complete: function(){
    this.fireEvent('save');
    this.close();
  }
});
