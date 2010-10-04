Ext.ns("Talho");

Talho.RequestRoles = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    var item_list = [
      {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:400}, items:[
        {xtype: 'textfield', fieldLabel: 'Last name', name: 'profile[last_name]', maxLength: '46', allowBlank: false},
        {xtype: 'textfield', fieldLabel: 'First name', name: 'profile[first_name]', maxLength: '46', allowBlank: false},
        {xtype: 'textfield', fieldLabel: 'Preferred name to be displayed', name: 'profile[preferred_name]', maxLength: '46', allowBlank: true},
        {xtype: 'textarea', fieldLabel: 'Job description', name: 'profile[job_desc]', height: 150, enableKeyEvents: true,
          listeners:{'keyup': function(ta){Ext.get('message_length').update(ta.getValue().length.toString());}}},
        {xtype: 'textfield', fieldLabel: 'Job title', name: 'profile[job_title]', maxLength: '46', allowBlank: false},
        {xtype: 'textfield', fieldLabel: 'Email address', name: 'profile[email]', maxLength: '46', allowBlank: false},
        {xtype: 'textfield', fieldLabel: 'Office fax', name: 'profile[office_fax]', maxLength: '46', allowBlank: true},
        {xtype: 'textfield', fieldLabel: 'Office phone', name: 'profile[office_phone]', maxLength: '46', allowBlank: true},
        {xtype: 'textfield', fieldLabel: 'Home phone', name: 'profile[home_phone]', maxLength: '46', allowBlank: true},
        {xtype: 'textfield', fieldLabel: 'Mobile phone', name: 'profile[mobile_phone]', maxLength: '46', allowBlank: true},
        {xtype: 'textfield', fieldLabel: 'Password', name: 'profile[password]', maxLength: '46', allowBlank: false},
        {xtype: 'textfield', fieldLabel: 'Confirm password', name: 'profile[pw_confirm]', maxLength: '46', allowBlank: false},
        {xtype: 'combo', fieldLabel: 'Preferred language', name: 'profile[language]', store: ['English', 'Spanish'], editable: false, value: 'English', triggerAction: 'all'}
      ]}
    ];
    var url = config.url + ".json";
    var method = "PUT";

    Talho.RequestRoles.superclass.constructor.call(this, config, 400, item_list, url, method);
  }
});

Talho.RequestRoles.initialize = function(config){
  var o = new Talho.RequestRoles(config);
  return o.getPanel();
};
