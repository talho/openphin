Ext.ns("Talho");

Talho.EditProfile = Ext.extend(Talho.ProfileBase, {
  mode: 'new',

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
        {xtype: 'combo', fieldLabel: 'Preferred language', name: 'profile[language]', store: ['English', 'Spanish'], editable: false, value: 'English', triggerAction: 'all'}

/*
        {xtype: 'container', layout: 'hbox', items:[
          {xtype: 'button', text: 'Save', handler: function(){ this.getPanel().getForm().submit(); }, scope: this, width:'auto'},
          {xtype: 'button', text: 'Save & Close', handler: function(){ this.getPanel().getForm().submit(); this.close_panel(); }, scope: this, width:'auto'},
          {xtype: 'button', text: 'Cancel', handler: function(){ this.close_panel(); }, scope: this, width:'auto'}
        */
      ]}
         /*,
                {xtype: 'container', layout: 'rt_form', labelAlign: 'top', defaults:{width:200}, items:[
                    {xtype: 'textfield', fieldLabel: 'name', name: 'profile[name]', maxLength: '15', allowBlank: false},
                ]}*/
    ];

    Talho.EditProfile.superclass.constructor.call(this, config, item_list);

    switch(this.mode) {
      case 'new': break;
      case 'update': break;
      case 'cancel': break;
    }
  }
});

Talho.EditProfile.initialize = function(config){
  var o = new Talho.EditProfile(config);
  return o.getPanel();
};
