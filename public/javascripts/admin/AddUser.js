Ext.ns("Talho");

Talho.AddUser = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    var jurisdictions_store = new Ext.data.JsonStore({
      url: '/admin_user_batch/admin_jurisdictions', autoLoad: true, autoSave: false,
      fields: [{name: 'name', mapping: 'jurisdiction.name'}]
    });
    this.roles_control = new Talho.ux.RolesControl(config.url + ".json", this);
    this.devices_control = new Talho.ux.DevicesControl(config.url + ".json", this);
    this.orgs_control = new Talho.ux.OrganizationsControl(config.url + ".json", this);
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
        {xtype: 'textfield', fieldLabel: 'Email address', name: 'user[email]', maxLength: '46', allowBlank: false, vtype: 'email'},
        {xtype: 'container', layout: 'hbox', labelAlign: 'top', items:[
          {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:195}, items:[
            {xtype: 'textfield', inputType: 'password', fieldLabel: 'Password', name: 'user[password]', id: 'initialPass', maxLength: '46', allowBlank: false, vtype: 'password'}
          ]},
          {xtype: 'container', layout: 'form', labelAlign: 'top', margins: '0 0 0 10', defaults:{width:195}, items:[
            {xtype: 'textfield', inputType: 'password', fieldLabel: 'Confirm password', name: 'user[password_confirmation]', maxLength: '46', allowBlank: false, initialPassword: 'initialPass', vtype: 'password'}
          ]}
        ]},
        {xtype: 'container', layout: 'hbox', labelAlign: 'top', items:[
          {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Job title', name: 'user[title]', maxLength: '46', allowBlank: true}
          ]},
          {xtype: 'container', layout: 'form', labelAlign: 'top', margins: '0 0 0 10', defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Employer', name: 'user[employer]', maxLength: '46', allowBlank: true}
          ]}
        ]},
        {xtype: 'container', layout: 'hbox', labelAlign: 'top', items:[
          {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Office phone', name: 'user[phone]', maxLength: '46', allowBlank: true, vtype: 'phone'}
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
          store: ['English', 'Spanish'], value: 'English'}
      ]},
      {xtype: 'container', layout: 'form', layoutConfig: {cls:'overflow-visible'}, labelAlign: 'top', defaults:{width:440},
        margins: '0 0 0 10', items:[
        {xtype: 'combo', fieldLabel: 'Home Jurisdiction', name: 'user[jurisdiction]', editable: false, triggerAction: 'all', allowBlank: false,
          store: jurisdictions_store, mode: 'local', displayField: 'name', labelStyle: 'white-space:nowrap;padding:0 20px 0 0'},
        {xtype: 'spacer', height: '10'},
        {xtype: 'container', html: 'Roles:'}, this.roles_control,
        {xtype: 'spacer', height: '10'},
        {xtype: 'container', html: 'Alerting Devices:'}, this.devices_control,
        {xtype: 'spacer', height: '10'},
        {xtype: 'container', html: 'Organizations:'},  this.orgs_control
      ]}
    ];
    this.form_config = {
      form_width: 850,
      item_list: item_list,
      save_url: "/admin_users.json",
      save_method: "POST"
    };

    Talho.AddUser.superclass.constructor.call(this, config);

    this.getPanel().doLayout();
  },

  load_data: function(json){ },
  save_data: function(){
    var options = {};
    options.params = {};
    options.params["user[new_devices]"] = this.devices_control.grab_data();
    options.params["user[new_roles]"] = this.roles_control.grab_data();
    options.params["user[new_orgs]"] = this.orgs_control.grab_data();
    this.getPanel().getForm().submit(options);
  },
  is_dirty: function(p){
    return p.getForm().isDirty() || this.devices_control.is_dirty() || this.roles_control.is_dirty() || this.orgs_control.is_dirty();
  }
});

Talho.AddUser.initialize = function(config){
  var o = new Talho.AddUser(config);
  return o.getPanel();
};

Talho.ScriptManager.reg('Talho.AddUser', Talho.AddUser, Talho.AddUser.initialize);
