Ext.ns("Talho.ux");

Talho.ux.RolesControl = Ext.extend(Ext.Panel, {
  constructor: function(save_url, ancestor){
    this.save_url = save_url;
    this.ancestor = ancestor;

    Talho.ux.RolesControl.superclass.constructor.call(this);
  },

  initComponent: function(){
    this.layout = 'form';
    this.cls = 'roles-control',
    this.frame = false;
    this.labelAlign = 'top';
    this.padding = 10;
    this.defaults = {boxMinWidth:400};
    this.items = [
      this._createStoreAndDataView(),
      {xtype: 'spacer', height: '10'},
      {xtype: 'container', layout: 'hbox', layoutConfig:{defaultMargins:'0 10 0 4'}, items:[
        {xtype: 'button', text: 'Add role', handler: this.add_role, scope: this, width:'auto'}
      ]}
    ];

    Talho.ux.RolesControl.superclass.initComponent.call(this);

    this.addListener('afterrender', this._loadJurisdictionsAndRoles, this);
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
        {xtype: 'textarea', fieldLabel: 'Role Description', anchor: '100% -50', readOnly: true,
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

  // AJAX load and save methods
  load_data: function(json){ this.store.loadData(json); },
  grab_data: function(){
    this.store.clearFilter();
    var rq = jQuery.map(this.store.getRange(), function(e,i){ return e.data; });
    this.store.filterBy(function(e){ return e.get("state")!="deleted"; });
    return Ext.encode(rq);
  },
  save_data: function(){ this.ancestor.save_json(this.save_url, {"user[rq]": this.grab_data()}); },
  is_dirty: function(){ return this.store.getModifiedRecords().length > 0; },

  // Methods for private use
  _createStoreAndDataView: function(){
    this.store = new Ext.data.Store({
      autoDestroy: true,
      autoLoad: false,
      autoSave: false,
      pruneModifiedRecords: true,
      listeners: {
        scope: this,
        'load': {fn: function(){ this.ancestor.getPanel().doLayout(); }, delay: 10},
        'add': {fn: function(){ this.ancestor.getPanel().doLayout(); }, delay: 10}
      },
      reader: new Ext.data.JsonReader({
        fields: [{name:'id'}, {name:'role_id'}, {name:'jurisdiction_id'}, {name:'rname'}, {name:'jname'},
                 {name:'type'}, {name:'state'}]
      })
    });

    var template = new Ext.XTemplate(
      '<ul class="roles">',
      '<tpl for=".">',
        '<li class="role-item ' + '<tpl if="state==' + "'pending'" + '">role-pending</tpl>' + '">',
          '<p><span class="role-title">{jname}</span>&nbsp;&nbsp;&nbsp;{rname}<a id="{id}" class="destroy">Del</a>',
            '<tpl if="state==' + "'pending'" + '"><br>&nbsp;<small><i>waiting for approval</i></small></tpl>',
            '<tpl if="state==' + "'new'" + '"><br>&nbsp;<small><i>needs to be saved</i></small></tpl>',
          '</p>',
        '</li>',
      '</tpl>',
      '</ul>'
    );

    this.dv = new Ext.DataView(
      {name: 'user[role_desc]', store: this.store, tpl: template, emptyText: 'No roles to display', deferEmptyText: false,
        multiSelect: false, singleSelect: false, itemSelector: 'li.role-item', selectedClass: 'device-selected',
        listeners: {scope: this, 'selectionchange': function(dv,s){ this.find("name", "remove_btn")[0].setDisabled(s.length == 0); }}}
    );
    this.dv.addListener('click', this._destroy_handler, this);

    return this.dv;
  },

  _loadJurisdictionsAndRoles: function(){
    this.jurisdictions_store = new Ext.data.JsonStore({
      url: '/audiences/jurisdictions_flat?ns=nonforeign', autoLoad: true, autoSave: false,
      fields: [{name: 'name'}, {name: 'id'}, {name: 'leaf'}, {name: 'level'}]
    });
    this.roles_store = new Ext.data.JsonStore({
      url: '/audiences/roles', autoLoad: true, autoSave: false,
      fields: [{name: 'name'}, {name: 'id'}]
    });
  },

  _destroy_handler: function(dv,index,node,e){
    var elem = Ext.get(e.getTarget());
    if (elem.hasClass("destroy")) {
      this.store.getAt(index).set("state", "deleted");
      this.store.filterBy(function(e){ return e.get("state")!="deleted"; });
    }
  }
});
