Ext.ns("Talho");

Talho.AddUser = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    var jurisdictions_store = new Ext.data.JsonStore({
      url: '/admin_user_batch/admin_jurisdictions', autoLoad: true, autoSave: false,
      fields: [{name: 'name', mapping: 'name'}]
    });
    this.roles_control = new Talho.ux.RolesControl(config.url + ".json", this);
    this.devices_control = new Talho.ux.DevicesControl(config.url + ".json", this);
    this.orgs_control = new Talho.ux.OrganizationsControl(config.url + ".json", this);
    var item_list = [
      {xtype: 'panel', layout: 'column', width: 850,  border: true, bodyStyle: 'background-color: white;',
        defaults: {bodyStyle:'background-color: white;', border: false, layout: 'form', xtype: 'container'}, items: [
      // Left column
        { columnWidth: 1, defaults: {anchor: '100%', border: false}, items: [
          {xtype: 'panel', layout: 'column', bodyStyle:'background-color: white;', defaults: {layout: 'form', labelAlign: 'top', border: false, xtype: 'panel'}, items: [
            {columnwidth: 0.5, bodyStyle:'padding-right: 20px; background-color: white;', defaults: {anchor: '100%'}, items: [
              {xtype: 'textfield', fieldLabel: 'First name', name: 'user[first_name]', maxLength: '46', allowBlank: false, tabIndex: 1},
              {xtype: 'textfield', fieldLabel: 'Display name', name: 'user[display_name]', maxLength: '46', allowBlank: true, tabIndex: 3},
              {xtype: 'textfield', inputType: 'password', fieldLabel: 'Password', name: 'user[password]', itemId: 'initialPass', maxLength: '46', allowBlank: false, vtype: 'password', tabIndex: 5},
              {xtype: 'textfield', fieldLabel: 'Job title', name: 'user[title]', maxLength: '46', allowBlank: true, tabIndex: 7},
              {xtype: 'textfield', fieldLabel: 'Office phone', name: 'user[phone]', maxLength: '46', allowBlank: true, vtype: 'phone', tabIndex: 9},
              {xtype: 'textfield', fieldLabel: 'Home phone', name: 'user[home_phone]', maxLength: '46', allowBlank: true, tabIndex: 11}
            ]},
            {columnwidth: 0.5, bodyStyle: 'background-color: white;' ,defaults: {anchor: '100%'}, items: [
              {xtype: 'textfield', fieldLabel: 'Last name', name: 'user[last_name]', maxLength: '46', allowBlank: false, tabIndex: 2},
              {xtype: 'textfield', fieldLabel: 'Email address', name: 'user[email]', maxLength: '46', allowBlank: false, vtype: 'email', tabIndex: 4},
              {xtype: 'textfield', inputType: 'password', fieldLabel: 'Confirm password', name: 'user[password_confirmation]', maxLength: '46', allowBlank: false, initialPassword: 'initialPass', vtype: 'password', tabIndex: 6},
              {xtype: 'textfield', fieldLabel: 'Employer', name: 'user[employer]', maxLength: '46', allowBlank: true, tabIndex: 8},
              {xtype: 'textfield', fieldLabel: 'Office fax', name: 'user[fax]', maxLength: '46', allowBlank: true, tabIndex: 10},
              {xtype: 'textfield', fieldLabel: 'Mobile phone', name: 'user[mobile_phone]', maxLength: '46', allowBlank: true, tabIndex: 12}
            ]}
          ]},
          {xtype: 'combo', fieldLabel: 'Language', name: 'user[preferred_language]', editable: false, triggerAction: 'all', store: ['English', 'Spanish'], value: 'English', tabIndex: 13}
        ]},
      //Right column
        { width: 420, defaults: {anchor: '100%'}, items: [
          {xtype: 'container', layout: 'form', layoutConfig: {cls:'overflow-visible'}, labelAlign: 'top', defaults:{width:420}, items:[
            {xtype: 'combo', fieldLabel: 'Home Jurisdiction', name: 'user[jurisdiction]', editable: false, triggerAction: 'all', allowBlank: false,
              store: jurisdictions_store, mode: 'local', displayField: 'name', labelStyle: 'white-space:nowrap;', tabIndex: 14},
            {xtype: 'container', style: {'padding-top': '10px'}, html: 'Roles:'},
            this.roles_control,
            {xtype: 'container', style: {'padding-top': '10px'}, html: 'Alerting Devices:'},
            this.devices_control,
            {xtype: 'container', style: {'padding-top': '10px'}, html: 'Organizations:'},
            this.orgs_control
          ]}
        ]}
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
