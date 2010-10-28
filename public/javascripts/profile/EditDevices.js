Ext.ns("Talho");

Talho.EditDevices = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    var store = new Ext.data.Store({
      autoDestroy: true,
      autoLoad: false,
      autoSave: false,
      url: config.url + "/edit.json",
      listeners: {scope: this, 'add': {fn: function(){ this.getPanel().doLayout(); }, delay: 10}},
      reader: new Ext.data.JsonReader({
        root: "extra.devices",
        fields: [{name:'id'}, {name:'type'}, {name:'rbclass'}, {name:'value'}]
      }),
      //writer: new Ext.data.JsonWriter({encode: true, writeAllFields: true})
    });

    var template = new Ext.XTemplate(
      '<ul class="devices">',
      '<tpl for=".">',
        '<li class="device-item">',
          '<p><span class="device-title">{value}</span>&nbsp;&nbsp;&nbsp;{type}<br>',
            '<tpl if="state==' + "'new'" + '"><small><i>needs to be saved</i></small></tpl>',
          '</p>',
        '</li>',
      '</tpl>',
      '</ul>'
    );

    var item_list = [
      {xtype: 'panel', layout: 'form', frame: true, title: 'Devices', labelAlign: 'top', defaults:{width:400}, items:[
        {xtype: 'container', layout: 'hbox', items:[
          {xtype: 'button', text: 'Add device', handler: this.add_device, scope: this, width:'auto'},
          {xtype: 'button', text: 'Remove device', handler: this.remove_device, scope: this, width:'auto'}
        ]},
        {xtype: 'spacer', height: '10'},
        {xtype: 'dataview', name: 'user[devices]', store: store, tpl: template, emptyText: 'No devices to display',
          multiSelect: false, singleSelect: true, itemSelector: 'li.device-item', selectedClass: 'device-selected',
          //overClass: 'x-view-over',
          //plugins: [new Ext.DataView.DragSelector()],
        }
      ]}
    ];
    this.form_config = {
      load_url: config.url + "/edit.json",
      form_width: 440,
      item_list: item_list,
      save_url: config.url + ".json",
      save_method: "PUT"
    };

    this.device_types = [
      ['Device::EmailDevice',      'E-mail'],
      ['Device::PhoneDevice',      'Phone'],
      ['Device::SMSDevice',        'SMS'],
      ['Device::FaxDevice',        'Fax'],
      ['Device::BlackberryDevice', 'Blackberry PIN']
    ];

    Talho.EditDevices.superclass.constructor.call(this, config);

    // Override the setValue() method where necessary
    this.getPanel().find("name", "user[devices]")[0].setValue = function(val){
      var store = this.getStore();
      var devices = jQuery.map(val, function(e,i){ return new store.recordType(e); });
      store.removeAll();
      store.add(devices);
    };

    this.getPanel().doLayout();
  },

  add_device: function(){
    var win = new Ext.Window({
      title: "Add Device",
      layout: 'hbox', layoutConfig: {defaultMargins:'10',pack:'center'},
      width: 450,
      items: [
        {xtype: 'container', layout: 'form', labelAlign: 'top', items: [
          {xtype: 'textfield', fieldLabel: 'Device info', name: 'dev[value]', maxLength: '46', allowBlank: false}
        ]},
        {xtype: 'container', layout: 'form', labelAlign: 'top', items: [
          {xtype: 'combo', fieldLabel: 'Device type', name: 'dev[type]', editable: false, value: 'Device::EmailDevice', triggerAction: 'all',
            store: this.device_types}
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
    var store = this.getPanel().find("name", "user[devices]")[0].getStore();
    var device = new store.recordType({id: -1, type:type, rbclass:rbclass, value:val, state:'new'});
    store.add(device);
    win.close();
    this.getPanel().doLayout();
  },
  remove_device: function(){
    var dv = this.getPanel().find("name", "user[devices]")[0];
    var store = dv.getStore();
    jQuery.each(dv.getSelectedRecords(), function(i,e){ e.data.state = "deleted"; });
    store.filterBy(function(e){ return e.data.state!="deleted"; });
  },

  save: function(){
    var saveButton = this.getPanel().find("name", "save_button")[0];
    if (saveButton.disabled) return;
    saveButton.disable();
    this.getPanel().loadMask.show();
    var store = this.getPanel().find("name", "user[devices]")[0].getStore();
    store.clearFilter();
    var devices = jQuery.map(store.getRange(), function(e,i){ return e.data; });
    store.filterBy(function(e){ return e.data.state!="deleted"; });
    Ext.Ajax.request({ url: this.form_config.save_url, method: "PUT", params: {"user[devices]": Ext.encode(devices)},
      success: this.save_success_cb, failure: this.save_err_cb, scope: this });
  },
  save_success_cb: function(response, opts) {
    this.getPanel().find("name", "save_button")[0].enable();
    this.load_form_values();
    this.show_message(Ext.decode(response.responseText));
  },
  save_err_cb: function(response, opts) {
    this.getPanel().find("name", "save_button")[0].enable();
    this.show_ajax_error(response);
  }
});

Talho.EditDevices.initialize = function(config){
  var o = new Talho.EditDevices(config);
  return o.getPanel();
};

Talho.ScriptManager.reg('Talho.EditDevices', Talho.EditDevices, Talho.EditDevices.initialize);
