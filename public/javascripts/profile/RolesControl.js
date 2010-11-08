Ext.ns("Talho.ux");

Talho.ux.RolesControl = Ext.extend(Ext.Panel, {
  constructor: function(save_url, ancestor){
    this.save_url = save_url;
    this.ancestor = ancestor;
    this._loadJurisdictionsAndRoles();

    Talho.ux.RolesControl.superclass.constructor.call(this);
  },

  initComponent: function(){
    this.layout = 'form';
    this.frame = true;
    this.title = 'Roles';
    this.labelAlign = 'top';
    this.padding = 10;
    this.defaults = {boxMinWidth:400};
    this.items = [
      {xtype: 'container', layout: 'hbox', items:[
        {xtype: 'button', text: 'Add role', handler: this.add_role, scope: this, width:'auto'},
        {xtype: 'button', text: 'Remove role', handler: this.remove_role, scope: this, width:'auto'}
      ]},
      {xtype: 'spacer', height: '10'},
      this._createStoreAndDataView()
    ];

    Talho.ux.RolesControl.superclass.initComponent.call(this);
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
      layout: 'form',
      labelAlign: 'top',
      padding: '10',
      width: 600, height: 250,
      items: [
        {xtype: 'container', layout: 'hbox', anchor: '100%', items: [
          {xtype: 'container', layout: 'form', labelAlign: 'top', flex: 0.4, items: [
            {xtype: 'combo', fieldLabel: 'Jurisdiction', name: 'rq[jurisdiction]', editable: false, triggerAction: 'all',
              anchor: '100%', store: this.jurisdictions_store, mode: 'local', tpl: template, displayField: 'name'}
          ]},
          {xtype: 'container', layout: 'form', labelAlign: 'top', flex: 0.6, margins: '0 0 0 10', items: [
            {xtype: 'combo', fieldLabel: 'Role', name: 'rq[role]', editable: false, triggerAction: 'all',
              anchor: '100%', store: this.roles_store, mode: 'local', displayField: 'name'}
          ]}
        ]},
        {xtype: 'textarea', fieldLabel: 'Role Description', anchor: '100% -50',
          html: 'Role description per CDC bureaucratic explanation process'}
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
    var store = this.store;
    var jr = new store.recordType({id:-1, role_id:r_id, jurisdiction_id:j_id, rname:rname, jname:jname, state:'new'});
    store.add(jr);
    win.close();
    this.ancestor.getPanel().doLayout();
  },
  remove_role: function(){
    jQuery.each(this.dv.getSelectedRecords(), function(i,e){ e.data.state = "deleted"; });
    this.store.filterBy(function(e){ return e.data.state!="deleted"; });
  },

  // AJAX load and save methods
  load_data: function(json){
    var store = this.store;
    var entries = jQuery.map(json, function(e,i){ return new store.recordType(e); });
    store.removeAll();
    store.add(entries);
  },
  grab_data: function(){
    this.store.clearFilter();
    var rq = jQuery.map(this.store.getRange(), function(e,i){ return e.data; });
    this.store.filterBy(function(e){ return e.data.state!="deleted"; });
    return Ext.encode(rq);
  },
  save_data: function(){
    this.ancestor.save_json(this.save_url, {"user[rq]": grab_data()});
  },

  // Methods for private use
  _createStoreAndDataView: function(){
    this.store = new Ext.data.Store({
      autoDestroy: true,
      autoLoad: false,
      autoSave: false,
      listeners: {scope: this, 'add': {fn: function(){ this.ancestor.getPanel().doLayout(); }, delay: 100}},
      reader: new Ext.data.JsonReader({
        root: "extra.role_desc",
        fields: [{name:'id'}, {name:'role_id'}, {name:'jurisdiction_id'}, {name:'rname'}, {name:'jname'},
                 {name:'type'}, {name:'state'}]
      }),
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

    this.dv = new Ext.DataView(
      {name: 'user[role_desc]', store: this.store, tpl: template, emptyText: 'No roles to display',
        multiSelect: false, singleSelect: true, itemSelector: 'li.role-item', selectedClass: 'device-selected'}
    );

    return this.dv;
  },

  _loadJurisdictionsAndRoles: function(){
    this.jurisdictions_store = new Ext.data.JsonStore({
      url: '/audiences/jurisdictions_flat?ns=nonforeign', autoLoad: true, autoSave: false,
      fields: [{name: 'name'}, {name: 'id'}, {name: 'leaf'}, {name: 'level'}]
    });
    this.roles_store = new Ext.data.JsonStore({
      url: '/audiences/roles', autoLoad: true, autoSave: false,
      fields: [{name: 'name', mapping: 'role.name'}, {name: 'id', mapping: 'role.id'}]
    });
  }
});
