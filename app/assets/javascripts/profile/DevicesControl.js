Ext.ns("Talho.ux");

Talho.ux.DevicesControl = Ext.extend(Ext.Panel, {
  constructor: function(save_url, ancestor){
    this.save_url = save_url;
    this.ancestor = ancestor;
    this.device_types = [
      ['Device::EmailDevice',      'E-mail'],
      ['Device::PhoneDevice',      'Phone'],
      ['Device::SmsDevice',        'SMS'],
      ['Device::FaxDevice',        'Fax'],
      ['Device::BlackberryDevice', 'Blackberry PIN']
    ];

    Talho.ux.DevicesControl.superclass.constructor.call(this);
  },

  initComponent: function(){
    this.layout = 'form';
    this.cls = 'devices-control',
    this.frame = false;
    this.labelAlign = 'top';
    this.padding = 10;
    this.defaults = {boxMinWidth:400};
    this.items = [
      this._createStoreAndDataView(),
      {xtype: 'spacer', height: '10'},
      {xtype: 'container', layout: 'hbox', layoutConfig:{defaultMargins:'0 10 0 4'}, items:[
        {xtype: 'button', text: 'Add device', handler: this.add_device, scope: this, width:'auto'}
      ]}
    ];

    Talho.ux.DevicesControl.superclass.initComponent.call(this);
  },

  add_device: function(){
    var win = new Ext.Window({
      title: "Add Device",
      layout: 'column',
      padding: '10',
      width: 450,
      items: [
        {xtype: 'container', layout: 'form', labelAlign: 'top', columnWidth: 0.5, items: [
          {xtype: 'textfield', fieldLabel: 'Address / Number', name: 'dev[value]', maxLength: '46', allowBlank: false, anchor: '100%'}
        ]},
        {xtype: 'container', layout: 'form', width: 10, items: [ {xtype: 'spacer', height: 10} ]},
        {xtype: 'container', layout: 'form', labelAlign: 'top', columnWidth: 0.5, items: [
          {xtype: 'combo', fieldLabel: 'Device type', name: 'dev[type]', editable: false, value: 'Device::EmailDevice', anchor: '100%',
            triggerAction: 'all', store: this.device_types}
        ]}
      ]
    });
    win.addButton({xtype: 'button', text: 'Add', handler: function(){ this.add_cb(win); }, scope: this, width:'auto'});
    win.addButton({xtype: 'button', text: 'Cancel', handler: function(){ win.close(); }, scope: this, width:'auto'});
    win.show();
  },
  add_cb: function(win){
    var rbclass = win.find("name", "dev[type]")[0].getValue();
    var type = "";
    jQuery.each(this.device_types, function(i,e){ if (e[0] == rbclass) type = e[1]; });
    var val = win.find("name", "dev[value]")[0].getValue();
    var device = new this.store.recordType({id: -1, type:type, rbclass:rbclass, value:val, state:'new'});
    this.store.add(device);
    win.close();
    this.ancestor.getPanel().doLayout();
  },

  // AJAX load and save methods
  load_data: function(json){ this.store.loadData(json); },
  grab_data: function(){
    this.store.clearFilter();
    var devices = jQuery.map(this.store.getRange(), function(e,i){ return e.data; });
    this.store.filterBy(function(e){ return e.get("state")!="deleted"; });
    return Ext.encode(devices);
  },
  save_data: function(){ this.ancestor.save_json(this.save_url, {"user[devices]": this.grab_data()}); },
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
        fields: [{name:'id'}, {name:'type'}, {name:'rbclass'}, {name:'value'}, {name: 'state'}]
      })
    });

    var template = new Ext.XTemplate(
      '<ul class="devices">',
      '<tpl for=".">',
        '<li class="device-item">',
          '<!--[if IE]><div class="IEonly"><![endif]-->',
          '<span class="device-title">{value}</span>&nbsp;&nbsp;&nbsp;{type}<br>',
          '<tpl if="state==' + "'new'" + '"><small><i>needs to be saved</i></small></tpl>',
          '<a id="{id}" class="profile-destroy">Del {value}</a>',
          '<!--[if IE]></div><![endif]-->',
        '</li>',
      '</tpl>',
      '</ul>'
    );

    this.dv = new Ext.DataView(
      {name: 'user[devices]', store: this.store, tpl: template, emptyText: 'No devices to display', deferEmptyText: false,
        multiSelect: false, singleSelect: false, itemSelector: 'li.device-item', selectedClass: 'device-selected'}
    );
    this.dv.addListener('click', this._destroy_handler, this);
  
    return this.dv;
  },

  _destroy_handler: function(dv,index,node,e){
    var elem = Ext.get(e.getTarget());
    if (elem.hasClass("profile-destroy")) {
      this.store.getAt(index).set("state", "deleted");
      this.store.filterBy(function(e){ return e.get("state")!="deleted"; });
    }
  }
});
