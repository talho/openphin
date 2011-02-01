Ext.ns("Talho.ux");

Talho.ux.OrganizationsControl = Ext.extend(Ext.Panel, {
  constructor: function(save_url, ancestor){
    this.save_url = save_url;
    this.ancestor = ancestor;

    Talho.ux.OrganizationsControl.superclass.constructor.call(this);
  },

  initComponent: function(){
    this.layout = 'form';
    this.cls = 'orgs-control',
    this.frame = false;
    this.labelAlign = 'top';
    this.padding = 10;
    this.defaults = {boxMinWidth:400};
    this.items = [
      this._createStoreAndDataView(),
      {xtype: 'spacer', height: '10'},
      {xtype: 'container', layout: 'hbox', layoutConfig:{defaultMargins:'0 10 0 4'}, items:[
        {xtype: 'button', text: 'Add organization', handler: this.add_organization, scope: this, width:'auto'}
      ]}
    ];

    Talho.ux.OrganizationsControl.superclass.initComponent.call(this);

    this.addListener('afterrender', this._loadOrganizations, this);
  },

  add_organization: function(){
    var template = new Ext.XTemplate('<tpl for="."><div class="x-combo-list-item">{name} - {desc}</div></tpl>');

    var win = new Ext.Window({
      title: "Add Organization",
      layout: 'form',
      labelAlign: 'top',
      padding: '10',
      width: 600, height: 250,
      items: [
        {xtype: 'container', layout: 'hbox', anchor: '100%', items: [
          {xtype: 'container', layout: 'form', labelAlign: 'top', flex: 1, items: [
            {xtype: 'combo', fieldLabel: 'Organization', name: 'rq[org]', editable: false, triggerAction: 'all',
              anchor: '100%', store: this.organizations_store, mode: 'local', tpl: template, displayField: 'name',
              listeners: {select: function(combo,record,index){ win.find("name", "rq[desc]")[0].setValue(record.get("long_desc")); }}}
          ]}
        ]},
        {xtype: 'textarea', fieldLabel: 'Organization Description', name: 'rq[desc]', anchor: '100% -50', readOnly: true, html: ''}
      ]
    });
    win.addButton({xtype: 'button', text: 'Add', handler: function(){ this.add_cb(win); }, scope: this, width:'auto'});
    win.addButton({xtype: 'button', text: 'Cancel', handler: function(){ win.close(); }, scope: this, width:'auto'});
    win.show();
  },
  add_cb: function(win){
    var combo = win.find("name", "rq[org]")[0];
    var name = combo.getValue();
    var o_idx = combo.getStore().findExact("name", name);
    var o_id = combo.getStore().getAt(o_idx).data.id;
    var store = this.store;
    store.add(new store.recordType({id:-1, org_id:o_id, name:name, state:'new'}));
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
  save_data: function(){ this.ancestor.save_json(this.save_url, {"user[orgs]": this.grab_data()}); },
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
        fields: [{name:'id'}, {name:'org_id'}, {name:'name'}, {name:'desc'}, {name:'type'}, {name:'state'}]
      })
    });

    var template = new Ext.XTemplate(
      '<ul class="orgs">',
      '<tpl for=".">',
        '<li class="org-item ' + '<tpl if="state==' + "'pending'" + '">org-pending</tpl>' + '">',
          '<p><span class="org-title">{name}</span>&nbsp;&nbsp;&nbsp;{desc}<a id="{id}" class="destroy">Del {name}</a>',
            '<tpl if="state==' + "'pending'" + '"><br>&nbsp;<small><i>waiting for approval</i></small></tpl>',
            '<tpl if="state==' + "'new'" + '"><br>&nbsp;<small><i>needs to be saved</i></small></tpl>',
          '</p>',
        '</li>',
      '</tpl>',
      '</ul>'
    );

    this.dv = new Ext.DataView(
      {name: 'user[org_desc]', store: this.store, tpl: template, emptyText: 'No organizations to display', deferEmptyText: false,
        multiSelect: false, singleSelect: false, itemSelector: 'li.org-item', selectedClass: 'device-selected'}
    );
    this.dv.addListener('click', this._destroy_handler, this);

    return this.dv;
  },

  _loadOrganizations: function(){
    this.organizations_store = new Ext.data.JsonStore({
      url: '/organizations.json', autoLoad: true, autoSave: false,
      root: 'organizations',
      fields: [{name: 'name'}, {name: 'id'}, {name: 'desc'}, {name: 'long_desc'}]
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
