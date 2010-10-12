Ext.ns("Talho");

Talho.ManageRoles = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    var store = new Ext.data.Store({
      autoDestroy: true,
      autoLoad: false,
      autoSave: false,
      url: config.url + "/edit.json",
      listeners: {scope: this, 'add': {fn: function(){ this.getPanel().doLayout(); }, delay: 10}},
      reader: new Ext.data.JsonReader({
        root: "extra.role_desc",
        fields: [{name:'role_id'}, {name:'jurisdiction_id'}, {name:'rname'}, {name:'jname'}]
      }),
      //writer: new Ext.data.JsonWriter({encode: true, writeAllFields: true})
    });

    /* ROLE
    this.audiencePanel = new Ext.ux.AudiencePanel({showGroups: true, showUsers: false, width: 600, height: 400});
    this.roleGridView = this.audiencePanel.createRolesGrid();
    */

    this.jurisdiction_store = new Ext.data.JsonStore({
      url: '/audiences/jurisdictions_flat',
      idProperty: 'id',
      fields: [{name: 'name', mapping: 'name'}, {name: 'id', mapping: 'id'}],
      autoSave: false
    });
    this.roles_store = new Ext.data.JsonStore({
      url: '/audiences/roles',
      idProperty: 'role.id',
      fields: [{name: 'name', mapping: 'role.name'}, {name: 'id', mapping: 'role.id'}],
      autoSave: false
    });

    var template = new Ext.XTemplate(
      '<ul class="roles">',
      '<tpl for=".">',
        '<li class="role-item">',
          '<p><span class="title minor">{jname}</span>&nbsp;&nbsp;&nbsp;{rname}</p>',
        '</li>',
      '</tpl>',
      '</ul>'
    );

    var item_list = [
      {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:600}, items:[
        {xtype: 'container', layout: 'hbox', items:[
          {xtype: 'button', text: 'Add role', handler: this.add_role, scope: this, width:'auto'},
          {xtype: 'button', text: 'Remove role', handler: this.remove_role, scope: this, width:'auto'}
        ]},
        {xtype: 'spacer', height: '10'},
        {xtype: 'dataview', name: 'user[role_desc]', store: store, tpl: template, emptyText: 'No roles to display',
          height: 250, autoHeight: false, autoScroll: true,
          multiSelect: false, singleSelect: true, itemSelector: 'li.role-item', selectedClass: 'device-selected'
        },
        /*
        {xtype: 'container', layout: 'hbox', labelAlign: 'top', items:[
          {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:195}, items:[
            {xtype: 'combo', fieldLabel: 'Jurisdiction', name: 'req[jurisdiction]', editable: true, triggerAction: 'all',
              store: this.jurisdiction_store, displayField: 'name',
              enableKeyEvents: true,
              listeners: {
                scope: this,
                'keypress': {fn: function(){
                  var cb = this.getPanel().find("name", "req[jurisdiction]")[0];
                  this.jurisdiction_store.filter("name", cb.getValue(), true, false); }, delay: 10}
              }
            }
          ]},
          {xtype: 'container', layout: 'form', labelAlign: 'top', margins: '0 0 0 10', defaults:{width:195}, items:[
            {xtype: 'combo', fieldLabel: 'Role', name: 'req[role]', editable: true, triggerAction: 'all',
              store: this.roles_store, displayField: 'name',
              enableKeyEvents: true,
              listeners: {
                scope: this,
                'keypress': {fn: function(){
                  var cb = this.getPanel().find("name", "req[role]")[0];
                  this.roles_store.filter("name", cb.getValue(), true, false); }, delay: 10}
              }
            }
          ]},
        ]}
        */
        //{xtype: 'container', items: this.roleGridView, defaults:{width:400,height:400}}
      ]}
    ];

    this.form_config = {
      load_url: config.url + "/edit.json",
      form_width: 600,
      item_list: item_list,
      save_url: config.url + ".json",
      save_method: "PUT"
    };

    Talho.ManageRoles.superclass.constructor.call(this, config);

    // Override the setValue() method where necessary
    this.getPanel().find("name", "user[role_desc]")[0].setValue = function(val){
      var store = this.getStore();
      var entries = jQuery.map(val, function(e,i){ return new store.recordType(e); });
      store.removeAll();
      store.add(entries);
    };

    this.getPanel().doLayout();
  },

  add_role: function(){
    var win = new Ext.Window({
      title: "Add Role",
      layout: 'hbox', layoutConfig: {defaultMargins:'10',pack:'center'},
      width: 600,
      items: [
        {xtype: 'combo', fieldLabel: 'Jurisdiction', name: 'rq[jurisdiction]', editable: false, triggerAction: 'all',
          store: this.jurisdiction_store, displayField: 'name'},
        {xtype: 'combo', fieldLabel: 'Role', name: 'rq[role]', editable: false, triggerAction: 'all',
          store: this.roles_store, displayField: 'name'}
      ]
    });
    win.addButton({xtype: 'button', text: 'Add', handler: function(){ this.add_cb(win); }, scope: this, width:'auto'});
    win.addButton({xtype: 'button', text: 'Cancel', handler: function(){ win.close(); }, scope: this, width:'auto'});
    win.show();
  },
  add_cb: function(win){
    var jurisdiction = win.find("name", "rq[jurisdiction]")[0].getValue();
    var role = win.find("name", "rq[role]")[0].getValue();
    alert("Add: " + jurisdiction + " => " + role);
    win.close();
  },
  remove_role: function(){
    var dv = this.getPanel().find("name", "user[role_desc]")[0];
    var store = dv.getStore();
    store.remove(dv.getSelectedRecords());
  },
});

Talho.ManageRoles.initialize = function(config){
  var o = new Talho.ManageRoles(config);
  return o.getPanel();
};

Talho.ScriptManager.reg('Talho.ManageRoles', Talho.ManageRoles, Talho.ManageRoles.initialize);
