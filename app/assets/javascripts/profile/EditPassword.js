Ext.ns("Talho");

Talho.EditPassword = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    var item_list = [
      {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:400}, items:[
        {xtype: 'textfield', inputType: 'password', fieldLabel: 'Password', name: 'user[password]', maxLength: '46', allowBlank: false, itemId: 'initialPass', vtype: 'password'},
        {xtype: 'textfield', inputType: 'password', fieldLabel: 'Confirm password', name: 'user[password_confirmation]', maxLength: '46', allowBlank: false, initialPassword: 'initialPass', vtype: 'password'}
      ]}
    ];
    this.form_config = {
      form_width: 400,
      item_list: item_list,
      save_url: config.url + ".json",
      save_method: "PUT"
    };

    Talho.EditPassword.superclass.constructor.call(this, config);
  },

  save_data: function(){ this.getPanel().getForm().submit(); }
});

Talho.EditPassword.initialize = function(config){
  var o = new Talho.EditPassword(config);
  return o.getPanel();
};

Talho.ScriptManager.reg('Talho.EditPassword', Talho.EditPassword, Talho.EditPassword.initialize);
