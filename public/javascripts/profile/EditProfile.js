Ext.ns("Talho");

Talho.EditProfile = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    var item_list = [
      {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:400}, items:[
        {xtype: 'container', layout: 'hbox', labelAlign: 'top', items:[
          {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'First name', name: 'user[first_name]', maxLength: '46', allowBlank: false}
          ]},
          {xtype: 'container', layout: 'form', labelAlign: 'top', margins: '0 0 0 10', defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Last name', name: 'user[last_name]', maxLength: '46', allowBlank: false}
          ]}
        ]},
        {xtype: 'textfield', fieldLabel: 'Display name', name: 'user[display_name]', maxLength: '46', allowBlank: true},
        {xtype: 'container', layout: 'hbox', labelAlign: 'top', items:[
          {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Job title', name: 'user[title]', maxLength: '46', allowBlank: false}
          ]},
          {xtype: 'container', layout: 'form', labelAlign: 'top', margins: '0 0 0 10', defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Employer', name: 'user[employer]', maxLength: '46', allowBlank: false}
          ]}
        ]},
        {xtype: 'textarea', fieldLabel: 'Job description', name: 'user[description]', height: 150, enableKeyEvents: true,
          listeners:{'keyup': function(ta){Ext.get('message_length').update(ta.getValue().length.toString());}}},
        {xtype: 'textfield', fieldLabel: 'Email address', name: 'user[email]', maxLength: '46', allowBlank: false},
        {xtype: 'container', layout: 'hbox', labelAlign: 'top', items:[
          {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Office phone', name: 'user[phone]', maxLength: '46', allowBlank: true}
          ]},
          {xtype: 'container', layout: 'form', labelAlign: 'top', margins: '0 0 0 10', defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Office fax', name: 'user[fax]', maxLength: '46', allowBlank: true}
          ]}
        ]},
        {xtype: 'container', layout: 'hbox', labelAlign: 'top', items:[
          {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Home phone', name: 'user[home_phone]', maxLength: '46', allowBlank: true}
          ]},
          {xtype: 'container', layout: 'form', labelAlign: 'top', margins: '0 0 0 10', defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Mobile phone', name: 'user[mobile_phone]', maxLength: '46', allowBlank: true}
          ]}
        ]},
        {xtype: 'combo', fieldLabel: 'Language', name: 'user[preferred_language]', editable: false, triggerAction: 'all',
          store: ['English', 'Spanish'], value: 'English'},
        {xtype: 'textarea', fieldLabel: 'Bio', name: 'user[bio]', height: 150, enableKeyEvents: true,
          listeners:{'keyup': function(ta){Ext.get('message_length').update(ta.getValue().length.toString());}}},
        {xtype: 'textarea', fieldLabel: 'Credentials', name: 'user[credentials]', height: 150, enableKeyEvents: true,
          listeners:{'keyup': function(ta){Ext.get('message_length').update(ta.getValue().length.toString());}}},
        {xtype: 'textarea', fieldLabel: 'Experience', name: 'user[experience]', height: 150, enableKeyEvents: true,
          listeners:{'keyup': function(ta){Ext.get('message_length').update(ta.getValue().length.toString());}}}
      ]},
      {xtype: 'container', layout: 'form', layoutConfig: {cls:'overflow-visible'}, labelAlign: 'top', defaults:{width:300},
        margins: '0 0 0 10', items:[
        {xtype: 'container', name: 'user[photo]', html: '<img id=photo src="images/missing.jpg" width=200 height=200>'},
        {xtype: 'spacer', height: '10'},
        {xtype: 'textfield', inputType: 'file', fieldLabel: 'Picture to upload', name: 'user[name]', maxLength: '15', width: 'auto'},
        {xtype: 'checkbox', boxLabel: 'Make this profile public?', fieldLabel: 'Privacy setting', name: 'user[public]', inputValue: true},
        {xtype: 'hidden', name: 'user[lock_version]', value: ''}
      ]}
    ];
    this.form_config = {
      load_url: config.url + "/edit.json",
      form_width: 700,
      item_list: item_list,
      save_url: config.url + ".json",
      save_method: "PUT"
    };

    Talho.EditProfile.superclass.constructor.call(this, config);

    // Override the setValue() method where necessary
    this.getPanel().find("name", "user[photo]")[0].setValue = function(val){ Ext.getDom("photo").src = val; };
  },
});

Talho.EditProfile.initialize = function(config){
  var o = new Talho.EditProfile(config);
  return o.getPanel();
};

Talho.ScriptManager.reg('Talho.EditProfile', Talho.EditProfile, Talho.EditProfile.initialize);
