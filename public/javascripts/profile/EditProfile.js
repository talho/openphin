Ext.ns("Talho");

Talho.EditProfile = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    var user_id = config.user_id;
    this.devices_control = new Talho.ux.DevicesControl(config.url + ".json", this);
    this.roles_control = new Talho.ux.RolesControl(config.url + ".json", this);
    this.orgs_control = new Talho.ux.OrganizationsControl(config.url + ".json", this);

    var item_list = [
      {xtype: 'container', layout: 'form', labelAlign: 'top', width: 400, defaults:{width:400}, items:[
        {xtype: 'container', layout: 'hbox', labelAlign: 'top', items:[
          {xtype: 'container', layout: 'form', labelAlign: 'top', width: 195, defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'First name', name: 'user[first_name]', maxLength: '46', allowBlank: false}
          ]},
          {xtype: 'container', layout: 'form', labelAlign: 'top', margins: '0 0 0 10', width: 195, defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Last name', name: 'user[last_name]', maxLength: '46', allowBlank: false}
          ]}
        ]},
        {xtype: 'textfield', fieldLabel: 'Display name', name: 'user[display_name]', maxLength: '46', allowBlank: true},
        {xtype: 'textfield', fieldLabel: 'Email address', name: 'user[email]', maxLength: '46', allowBlank: false, vtype: 'email'},
        {xtype: 'combo', fieldLabel: 'Language', name: 'user[preferred_language]', hiddenName: 'user[preferred_language]', editable: false, triggerAction: 'all',
          store: ['English', 'Spanish'], value: 'English'},
        {xtype: 'combo', fieldLabel: 'Dashboard', name: 'user[dashboard_id]', hiddenName: 'user[dashboard_id]', editable: false, triggerAction: 'all', mode: 'local',
          store: new Ext.data.JsonStore({
            url: '/dashboard.json',
            restful: true,
            baseParams: {user_id: user_id},
            root: 'dashboards',
            fields: ['id', 'name'],
            autoLoad: true
          }), displayField: 'name', valueField: 'id'},
        {xtype: 'checkbox', boxLabel: 'Make this profile public?', fieldLabel: 'Privacy setting', name: 'user[public]', inputValue: true,
          cls:'checkbox-left-margin'},
        {xtype: 'spacer', height: '10'},
          {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:400}, items:[
          {xtype: 'textfield', inputType: 'password', fieldLabel: 'Password', name: 'user[password]', maxLength: '46', allowBlank: true, itemId: 'initialPass', vtype: 'password'},
          {xtype: 'textfield', inputType: 'password', fieldLabel: 'Confirm password', name: 'user[password_confirmation]', maxLength: '46', allowBlank: true, initialPassword: 'initialPass', vtype: 'password'}
        ]},
        {xtype: 'spacer', height: '10'},
        {xtype: 'container', html: 'Alerting Devices:'}, this.devices_control,
        {xtype: 'spacer', height: '10'},
        {xtype: 'container', html: 'Roles:'}, this.roles_control,
        {xtype: 'spacer', height: '10'},
        {xtype: 'container', html: 'Organizations:'},  this.orgs_control,
        {xtype: 'hidden', name: '_method', value: 'PUT'},
        {xtype: 'hidden', name: 'user[lock_version]', value: ''}
      ]},
      {xtype: 'container', layout: 'form', layoutConfig: {cls:'overflow-visible'}, labelAlign: 'top', width: 400, defaults:{width:400},
        margins: '0 0 0 10', items:[
        {xtype: 'container', name: 'user[current_photo]', html: '<img id=current_photo' + user_id + ' src="images/missing.jpg">'},
        {xtype: 'spacer', height: '10'},
        {xtype: 'textfield', inputType: 'file', fieldLabel: 'Picture to upload', name: 'user[photo]', maxLength: '1024', width: 'auto'},
        {xtype: 'container', layout: 'hbox', labelAlign: 'top', items:[
          {xtype: 'container', layout: 'form', labelAlign: 'top', width: 195, defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Office phone', name: 'user[phone]', maxLength: '46', allowBlank: true, vtype: 'phone'}
          ]},
          {xtype: 'container', layout: 'form', labelAlign: 'top', margins: '0 0 0 10', width: 195, defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Office fax', name: 'user[fax]', maxLength: '46', allowBlank: true, vtype: 'phone'}
          ]}
        ]},
        {xtype: 'container', layout: 'hbox', labelAlign: 'top', items:[
          {xtype: 'container', layout: 'form', labelAlign: 'top', width: 195, defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Home phone', name: 'user[home_phone]', maxLength: '46', allowBlank: true, vtype: 'phone'}
          ]},
          {xtype: 'container', layout: 'form', labelAlign: 'top', margins: '0 0 0 10', width: 195, defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Mobile phone', name: 'user[mobile_phone]', maxLength: '46', allowBlank: true, vtype: 'phone'}
          ]}
        ]},
        {xtype: 'container', layout: 'hbox', labelAlign: 'top', items:[
          {xtype: 'container', layout: 'form', labelAlign: 'top', width: 195, defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Job title', name: 'user[title]', maxLength: '46', allowBlank: true}
          ]},
          {xtype: 'container', layout: 'form', labelAlign: 'top', margins: '0 0 0 10', width: 195, defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Employer', name: 'user[employer]', maxLength: '46', allowBlank: true}
          ]}
        ]},
        {xtype: 'textarea', fieldLabel: 'Job description', name: 'user[description]', height: 50, allowBlank: true},
        {xtype: 'textarea', fieldLabel: 'Bio', name: 'user[bio]', height: 50, allowBlank: true},
        {xtype: 'textarea', fieldLabel: 'Credentials', name: 'user[credentials]', height: 50, allowBlank: true},
        {xtype: 'textarea', fieldLabel: 'Experience', name: 'user[experience]', height: 50, allowBlank: true}
      ]}
    ];
    this.form_config = {
      load_url: config.url + "/edit.json",
      form_width: 810,
      item_list: item_list,
      save_url: config.url + ".json",
      save_method: "PUT"
    };

    Talho.EditProfile.superclass.constructor.call(this, config);

    // Override the setValue() method where necessary
    this.getPanel().find("name", "user[current_photo]")[0].setValue = function(val){ Ext.getDom("current_photo"+user_id).src = val; };
    this.getPanel().find("name", "user[devices]")[0].setValue = function(val){ this.getStore().loadData(val); };
    this.getPanel().find("name", "user[role_desc]")[0].setValue = function(val){ this.getStore().loadData(val); };
    this.getPanel().find("name", "user[org_desc]")[0].setValue = function(val){ this.getStore().loadData(val); };
  },

  load_data: function(json){
    var p = this.getPanel();
    this.set_field_values(p, json.user);
    this.set_field_values(p, json.extra);
    this.getPanel().find("name", "user[photo]")[0].setValue("");  // clear file path on reload
  },
  save_data: function(){
    var options = {};
    options.params = {
      "user[devices]": this.devices_control.grab_data(),
      "user[rq]": this.roles_control.grab_data(),
      "user[orgs]": this.orgs_control.grab_data()
    };
    this.getPanel().getForm().fileUpload = true;
    this.getPanel().getForm().submit(options);
  },
  is_dirty: function(p){
    return p.getForm().isDirty() || this.devices_control.is_dirty() || this.roles_control.is_dirty() || this.orgs_control.is_dirty();
  },

  set_field_values: function(p, obj){
    for (var prop in obj) {
      var elem_list = p.find("name", "user[" + prop + "]");
      if (elem_list.length > 0) {
        elem_list[0].setValue(obj[prop]);
        // the following is necessary for isDirty() on the form to work
        elem_list[0].originalValue = (elem_list[0].getValue) ? elem_list[0].getValue() : obj[prop];
      }
    }
  }
});

Talho.EditProfile.initialize = function(config){
  var o = new Talho.EditProfile(config);
  return o.getPanel();
};

Talho.ScriptManager.reg('Talho.EditProfile', Talho.EditProfile, Talho.EditProfile.initialize);
