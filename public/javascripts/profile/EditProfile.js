Ext.ns("Talho");

Talho.EditProfile = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    this.devices_store = new Ext.data.Store({
      listeners: {scope: this, 'load': {fn: function(){ this.getPanel().doLayout(); }, delay: 10}},
      reader: new Ext.data.JsonReader({
        fields: [{name:'id'}, {name:'type'}, {name:'rbclass'}, {name:'value'}, {name: 'state'}]
      })
    });
    var devices_tpl = new Ext.XTemplate(
      '<ul>',
      '<tpl for=".">',
        '<li>{value} ({type})</li>',
      '</tpl>',
      '</ul>'
    );

    this.roles_store = new Ext.data.Store({
      listeners: {scope: this, 'load': {fn: function(){ this.getPanel().doLayout(); }, delay: 10}},
      reader: new Ext.data.JsonReader({
        fields: [{name:'id'}, {name:'role_id'}, {name:'jurisdiction_id'}, {name:'rname'}, {name:'jname'},
                 {name:'type'}, {name:'state'}]
      })
    });
    var roles_tpl = new Ext.XTemplate(
      '<ul>',
      '<tpl for=".">',
        '<li>',
            '<tpl if="state==' + "'pending'" + '"><i></tpl>',
            '{rname} in {jname}',
            '<tpl if="state==' + "'pending'" + '"></i></tpl>',
        '</li>',
      '</tpl>',
      '</ul>'
    );

    this.orgs_store = new Ext.data.Store({
      listeners: {scope: this, 'load': {fn: function(){ this.getPanel().doLayout(); }, delay: 10}},
      reader: new Ext.data.JsonReader({
        fields: [{name:'id'}, {name:'org_id'}, {name:'name'}, {name:'type'}, {name:'state'}]
      })
    });
    var orgs_tpl = new Ext.XTemplate(
      '<ul>',
      '<tpl for=".">',
        '<li>',
            '<tpl if="state==' + "'pending'" + '"><i></tpl>',
            '{name}',
            '<tpl if="state==' + "'pending'" + '"></i></tpl>',
        '</li>',
      '</tpl>',
      '</ul>'
    );

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
        {xtype: 'textfield', fieldLabel: 'Email address', name: 'user[email]', maxLength: '46', allowBlank: false},
        {xtype: 'container', layout: 'hbox', labelAlign: 'top', items:[
          {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Job title', name: 'user[title]', maxLength: '46', allowBlank: true}
          ]},
          {xtype: 'container', layout: 'form', labelAlign: 'top', margins: '0 0 0 10', defaults:{width:195}, items:[
            {xtype: 'textfield', fieldLabel: 'Employer', name: 'user[employer]', maxLength: '46', allowBlank: true}
          ]}
        ]},
        {xtype: 'textarea', fieldLabel: 'Job description', name: 'user[description]', height: 150, enableKeyEvents: true,
          listeners:{'keyup': function(ta){Ext.get('message_length').update(ta.getValue().length.toString());}}},
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
        {xtype: 'container', name: 'user[current_photo]', html: '<img id=current_photo src="images/missing.jpg">'},
        {xtype: 'spacer', height: '10'},
        {xtype: 'textfield', inputType: 'file', fieldLabel: 'Picture to upload', name: 'user[photo]', maxLength: '1024', width: 'auto'},
        {xtype: 'checkbox', boxLabel: 'Make this profile public?', fieldLabel: 'Privacy setting', name: 'user[public]', inputValue: true},
        {xtype: 'spacer', height: '10'},
        {xtype: 'container', layout: 'hbox', labelAlign: 'top', items:[
          {xtype: 'container', html: '<b>Devices</b>&nbsp;'},
          new Ext.Button({text: 'edit', handler: function(){ this.manage_user_devices(); }, scope: this})
        ]},
        new Ext.DataView({name: 'user[devices]', store: this.devices_store, tpl: devices_tpl, emptyText: 'No devices', deferEmptyText: false}),
        {xtype: 'spacer', height: '10'},
        {xtype: 'container', layout: 'hbox', labelAlign: 'top', items:[
          {xtype: 'container', html: '<b>Roles</b>&nbsp;'},
          new Ext.Button({text: 'edit', handler: function(){ this.manage_user_roles(); }, scope: this})
        ]},
        new Ext.DataView({name: 'user[role_desc]', store: this.roles_store, tpl: roles_tpl, emptyText: 'No roles', deferEmptyText: false}),
        {xtype: 'spacer', height: '10'},
        {xtype: 'container', layout: 'hbox', labelAlign: 'top', items:[
          {xtype: 'container', html: '<b>Organizations</b>&nbsp;'},
          new Ext.Button({text: 'edit', handler: function(){ this.manage_organizations(); }, scope: this})
        ]},
        new Ext.DataView({name: 'user[org_desc]', store: this.orgs_store, tpl: orgs_tpl, emptyText: 'No organizations', deferEmptyText: false}),
        {xtype: 'hidden', name: '_method', value: 'PUT'},
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
    this.getPanel().find("name", "user[current_photo]")[0].setValue = function(val){ Ext.getDom("current_photo").src = val; };
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
    this.getPanel().getForm().fileUpload = true;
    this.getPanel().getForm().submit();
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
  },

  // popup windows
  manage_user_devices: function(){
    var devices_control = new Talho.ux.DevicesControl(this.form_config.save_url, this);
    devices_control.load_data(Ext.pluck(this.devices_store.getRange(), "data"));
    var win = new Ext.Window({title: "Manage Devices", layout: 'form', autoScroll: true, padding: '10', width: 440,
      items: [devices_control]});
    win.addButton({xtype: 'button', text: 'Save', handler: function(){ devices_control.save_data(); win.close(); }, scope: this, width:'auto'});
    win.addButton({xtype: 'button', text: 'Cancel', handler: function(){ win.close(); }, scope: this, width:'auto'});
    win.show();
  },
  manage_user_roles: function(){
    var roles_control = new Talho.ux.RolesControl(this.form_config.save_url, this);
    roles_control.load_data(Ext.pluck(this.roles_store.getRange(), "data"));
    var win = new Ext.Window({title: "Manage Roles", layout: 'form', autoScroll: true, padding: '10', width: 440,
      items: [roles_control]});
    win.addButton({xtype: 'button', text: 'Save', handler: function(){ roles_control.save_data(); win.close(); }, scope: this, width:'auto'});
    win.addButton({xtype: 'button', text: 'Cancel', handler: function(){ win.close(); }, scope: this, width:'auto'});
    win.show();
  },
  manage_organizations: function(){
    var orgs_control = new Talho.ux.OrganizationsControl(this.form_config.save_url, this);
    orgs_control.load_data(Ext.pluck(this.orgs_store.getRange(), "data"));
    var win = new Ext.Window({title: "Manage Organizations", layout: 'form', autoScroll: true, padding: '10', width: 440,
      items: [orgs_control]});
    win.addButton({xtype: 'button', text: 'Save', handler: function(){ orgs_control.save_data(); win.close(); }, scope: this, width:'auto'});
    win.addButton({xtype: 'button', text: 'Cancel', handler: function(){ win.close(); }, scope: this, width:'auto'});
    win.show();
  }
});

Talho.EditProfile.initialize = function(config){
  var o = new Talho.EditProfile(config);
  return o.getPanel();
};

Talho.ScriptManager.reg('Talho.EditProfile', Talho.EditProfile, Talho.EditProfile.initialize);
