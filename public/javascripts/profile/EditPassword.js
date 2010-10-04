Ext.ns("Talho");

Talho.EditPassword = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    var item_list = [
      {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:400}, items:[
        {xtype: 'textfield', inputType: 'password', fieldLabel: 'Password', name: 'profile[password]', maxLength: '46', allowBlank: false},
        {xtype: 'textfield', inputType: 'password', fieldLabel: 'Confirm password', name: 'profile[pw_confirm]', maxLength: '46', allowBlank: false}
      ]}
    ];
    var url = config.url + ".json";
    var method = "PUT";

    Talho.EditPassword.superclass.constructor.call(this, config, 400, item_list, url, method);
  }
});

Talho.EditPassword.initialize = function(config){
  var o = new Talho.EditPassword(config);
  return o.getPanel();
};
