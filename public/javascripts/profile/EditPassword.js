Ext.ns("Talho");

Talho.EditPassword = Ext.extend(Talho.ProfileBase, {
  mode: 'new',

  constructor: function(config){
    var item_list = [
      {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:400}, items:[
        {xtype: 'textfield', fieldLabel: 'Password', name: 'profile[password]', maxLength: '46', allowBlank: false},
        {xtype: 'textfield', fieldLabel: 'Confirm password', name: 'profile[pw_confirm]', maxLength: '46', allowBlank: false}
      ]}
    ];

    Talho.EditPassword.superclass.constructor.call(this, config, item_list);

    switch(this.mode) {
      case 'new': break;
      case 'update': break;
      case 'cancel': break;
    }
  }
});

Talho.EditPassword.initialize = function(config){
  var o = new Talho.EditPassword(config);
  return o.getPanel();
};
