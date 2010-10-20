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
        fields: [{name:'id'}, {name:'role_id'}, {name:'jurisdiction_id'}, {name:'rname'}, {name:'jname'},
                 {name:'type'}, {name:'state'}]
      }),
      //writer: new Ext.data.JsonWriter({encode: true, writeAllFields: true})
    });

    this.jurisdictions_store = new Ext.data.JsonStore({
      url: '/audiences/jurisdictions_flat?ns=nonforeign', autoLoad: true, autoSave: false,
      fields: [{name: 'name'}, {name: 'id'}, {name: 'leaf'}, {name: 'level'}],
    });
    this.roles_store = new Ext.data.JsonStore({
      url: '/audiences/roles', autoLoad: true, autoSave: false,
      fields: [{name: 'name', mapping: 'role.name'}, {name: 'id', mapping: 'role.id'}],
    });

    var template = new Ext.XTemplate(
      '<ul class="roles">',
      '<tpl for=".">',
        '<li class="role-item ' + '<tpl if="state==' + "'pending'" + '">role-pending</tpl>' + '">',
          '<p><span class="role-title">{jname}</span>&nbsp;&nbsp;&nbsp;{rname}<br>&nbsp;',
            '<tpl if="state==' + "'pending'" + '"><small><i>waiting for approval</i></small></tpl>',
            '<tpl if="state==' + "'new'" + '"><small><i>needs to be saved</i></small></tpl>',
          '</p>',
        '</li>',
      '</tpl>',
      '</ul>'
    );

    var item_list = [
      {xtype: 'panel', layout: 'form', frame: true, title: 'Roles', labelAlign: 'top', defaults:{width:560}, items:[
        {xtype: 'container', layout: 'hbox', items:[
          {xtype: 'button', text: 'Add role', handler: this.add_role, scope: this, width:'auto'},
          {xtype: 'button', text: 'Remove role', handler: this.remove_role, scope: this, width:'auto'}
        ]},
        {xtype: 'spacer', height: '10'},
        {xtype: 'dataview', name: 'user[role_desc]', store: store, tpl: template, emptyText: 'No roles to display',
          multiSelect: false, singleSelect: true, itemSelector: 'li.role-item', selectedClass: 'device-selected'
        }
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
    this.getPanel().addListener("beforeclose", function(p){
      Ext.Msg.confirm("Save Is Needed",
        "Changes need to be saved.  Press 'Yes' to close and abandon your changes.",
        function(id){  if (id == "yes") p.destroy(); });
      return false;
    });
  },

  add_role: function(){
    var template = new Ext.XTemplate(
      '<tpl for="."><div ext:qtip="{name}" class="x-combo-list-item">',
        '<tpl if="!leaf"><b></tpl>',
          '<tpl if="level &gt; 0">&nbsp;&nbsp;</tpl>',
          '<tpl if="level &gt; 1">&nbsp;&nbsp;</tpl>',
          '<tpl if="level &gt; 2">&nbsp;&nbsp;</tpl>',
          '<tpl if="level &gt; 3">&nbsp;&nbsp;</tpl>',
          '<tpl if="level &gt; 4">&nbsp;&nbsp;</tpl>',
          '<tpl if="level &gt; 5">&nbsp;&nbsp;</tpl>',
          '{name}',
        '<tpl if="!leaf"></b></tpl>',
      '</div></tpl>'
    );

    var win = new Ext.Window({
      title: "Add Role",
      layout: 'hbox', layoutConfig: {defaultMargins:'10',pack:'center'},
      width: 600,
      items: [
        {xtype: 'container', layout: 'form', labelAlign: 'top', items: [
          {xtype: 'combo', fieldLabel: 'Jurisdiction', name: 'rq[jurisdiction]', editable: false, triggerAction: 'all',
            store: this.jurisdictions_store, mode: 'local', tpl: template, displayField: 'name'}
        ]},
        {xtype: 'container', layout: 'form', labelAlign: 'top', items: [
          {xtype: 'combo', fieldLabel: 'Role', name: 'rq[role]', editable: false, triggerAction: 'all',
            store: this.roles_store, mode: 'local', displayField: 'name'}
        ]}
      ]
    });
    win.addButton({xtype: 'button', text: 'Add', handler: function(){ this.add_cb(win); }, scope: this, width:'auto'});
    win.addButton({xtype: 'button', text: 'Cancel', handler: function(){ win.close(); }, scope: this, width:'auto'});
    win.show();
  },
  add_cb: function(win){
    var jcombo = win.find("name", "rq[jurisdiction]")[0];
    var rcombo = win.find("name", "rq[role]")[0];
    var jname = jcombo.getValue();
    var rname = rcombo.getValue();
    var j_idx = jcombo.getStore().findExact("name", jname);
    var r_idx = rcombo.getStore().findExact("name", rname);
    var j_id = jcombo.getStore().getAt(j_idx).data.id;
    var r_id = rcombo.getStore().getAt(r_idx).data.id;
    var store = this.getPanel().find("name", "user[role_desc]")[0].getStore();
    var jr = new store.recordType({id:-1, role_id:r_id, jurisdiction_id:j_id, rname:rname, jname:jname, state:'new'});
    store.add(jr);
    win.close();
    this.getPanel().doLayout();
  },
  remove_role: function(){
    var dv = this.getPanel().find("name", "user[role_desc]")[0];
    var store = dv.getStore();
    jQuery.each(dv.getSelectedRecords(), function(i,e){ e.data.state = "deleted"; });
    store.filterBy(function(e){ return e.data.state!="deleted"; });
  },

  save: function(){
    var saveButton = this.getPanel().find("name", "save_button")[0];
    if (saveButton.disabled) return;
    saveButton.disable();
    this.getPanel().loadMask.show();
    var store = this.getPanel().find("name", "user[role_desc]")[0].getStore();
    store.clearFilter();
    var rq = jQuery.map(store.getRange(), function(e,i){ return e.data; });
    store.filterBy(function(e){ return e.data.state!="deleted"; });
    Ext.Ajax.request({ url: this.form_config.save_url, method: "PUT", params: {"user[rq]": Ext.encode(rq)},
      success: this.save_success_cb, failure: this.save_err_cb, scope: this });
  },
  save_success_cb: function(response, opts) {
    this.getPanel().find("name", "save_button")[0].enable();
    var json = Ext.decode(response.responseText);
    if (json.type != "rollback")
      this.load_form_values();
    else
      this.getPanel().loadMask.hide();
    this.show_message(json);
  },
  save_err_cb: function(response, opts) {
    this.getPanel().find("name", "save_button")[0].enable();
    this.show_ajax_error(response);
  }
});

Talho.ManageRoles.initialize = function(config){
  var o = new Talho.ManageRoles(config);
  return o.getPanel();
};

Talho.ScriptManager.reg('Talho.ManageRoles', Talho.ManageRoles, Talho.ManageRoles.initialize);
