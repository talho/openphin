Ext.ns("Talho");

Talho.EditProfile = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    var item_list = [
      {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:400}, items:[
        {xtype: 'container', layout: 'hbox', labelAlign: 'top', items:[
          {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'First name', name: 'profile[first_name]', maxLength: '46', allowBlank: false}
          ]},
          {xtype: 'container', layout: 'form', labelAlign: 'top', margins: '0 0 0 10', defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Last name', name: 'profile[last_name]', maxLength: '46', allowBlank: false}
          ]}
        ]},
        {xtype: 'textfield', fieldLabel: 'Display name', name: 'profile[display_name]', maxLength: '46', allowBlank: true},
        {xtype: 'container', layout: 'hbox', labelAlign: 'top', items:[
          {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Job title', name: 'profile[title]', maxLength: '46', allowBlank: false}
          ]},
          {xtype: 'container', layout: 'form', labelAlign: 'top', margins: '0 0 0 10', defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Employer', name: 'profile[employer]', maxLength: '46', allowBlank: false}
          ]}
        ]},
        {xtype: 'textarea', fieldLabel: 'Job description', name: 'profile[description]', height: 150, enableKeyEvents: true,
          listeners:{'keyup': function(ta){Ext.get('message_length').update(ta.getValue().length.toString());}}},
        {xtype: 'textfield', fieldLabel: 'Email address', name: 'profile[email]', maxLength: '46', allowBlank: false},
        {xtype: 'container', layout: 'hbox', labelAlign: 'top', items:[
          {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Office phone', name: 'profile[phone]', maxLength: '46', allowBlank: true}
          ]},
          {xtype: 'container', layout: 'form', labelAlign: 'top', margins: '0 0 0 10', defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Office fax', name: 'profile[fax]', maxLength: '46', allowBlank: true}
          ]}
        ]},
        {xtype: 'container', layout: 'hbox', labelAlign: 'top', items:[
          {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Home phone', name: 'profile[home_phone]', maxLength: '46', allowBlank: true}
          ]},
          {xtype: 'container', layout: 'form', labelAlign: 'top', margins: '0 0 0 10', defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Mobile phone', name: 'profile[mobile_phone]', maxLength: '46', allowBlank: true}
          ]}
        ]},
        {xtype: 'combo', fieldLabel: 'Language', name: 'profile[language]', editable: false, triggerAction: 'all',
          store: ['English', 'Spanish'], value: 'English'},
        {xtype: 'textarea', fieldLabel: 'Bio', name: 'profile[bio]', height: 150, enableKeyEvents: true,
          listeners:{'keyup': function(ta){Ext.get('message_length').update(ta.getValue().length.toString());}}},
        {xtype: 'textarea', fieldLabel: 'Credentials', name: 'profile[credentials]', height: 150, enableKeyEvents: true,
          listeners:{'keyup': function(ta){Ext.get('message_length').update(ta.getValue().length.toString());}}},
        {xtype: 'textarea', fieldLabel: 'Experience', name: 'profile[experience]', height: 150, enableKeyEvents: true,
          listeners:{'keyup': function(ta){Ext.get('message_length').update(ta.getValue().length.toString());}}}
      ]},
      {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:200}, items:[
        {xtype: 'container', name: 'profile[photo]', html: '<img id=photo src="images/missing.jpg" width=200 height=200>'},
        {xtype: 'textfield', inputType: 'file', fieldLabel: 'Picture to upload', name: 'profile[name]', maxLength: '15'},
        {xtype: 'checkbox', boxLabel: 'Make this profile public?', fieldLabel: 'Privacy setting', name: 'profile[public]'},
      ]}
    ];
    var url = config.url;
    var method = "PUT";

    Talho.EditProfile.superclass.constructor.call(this, config, item_list, url, method);

    // Override the setValue() method where necessary
    this.getPanel().find("name", "profile[photo]")[0].setValue = function(val){ Ext.getDom("photo").src = val; };
  },
});

Talho.EditProfile.initialize = function(config){
  var o = new Talho.EditProfile(config);
  return o.getPanel();
};
