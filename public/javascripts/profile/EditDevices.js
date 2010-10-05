Ext.ns("Talho");

Talho.EditDevices = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    var store = new Ext.data.Store({
      autoDestroy: true,
      //url: 'plants.xml', // load remote data using HTTP
      listeners: {scope: this, 'add': {fn: function(){ this.getPanel().doLayout(); }, delay: 10}},
      reader: new Ext.data.XmlReader({
        record: 'device', // records will have a 'device' tag
        fields: [{name: 'type', type: 'string'}, {name: 'value', type: 'string'}]
          // use an Array of field definition objects to implicitly create a Record constructor
          // the 'name' below matches the tag name to read, except 'availDate'
          // which is mapped to the tag 'availability'
      }),
      //sortInfo: {field:'type', direction:'ASC'}
    });

    var template = new Ext.XTemplate(
      '<ul class="devices">',
      '<tpl for=".">',
        '<li class="device-item">',
          '<p><span class="title minor">{value}</span>&nbsp;&nbsp;&nbsp;{type}</p>',
          //'<a class="destroy">Delete</a>',
        '</li>',
      '</tpl>',
      '</ul>'
    );

    var item_list = [
      {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:400}, items:[
        {xtype: 'container', layout: 'hbox', items:[
          {xtype: 'button', text: 'Add device', handler: this.add_device, scope: this, width:'auto'},
          {xtype: 'button', text: 'Remove device', handler: this.remove_device, scope: this, width:'auto'}
        ]},
        {xtype: 'spacer', height: '10'},
        {xtype: 'dataview', name: 'user[devices]', store: store, tpl: template, emptyText: 'No devices to display',
          height: 250, autoHeight: false, autoScroll: true,
          multiSelect: false, singleSelect: true, itemSelector: 'li.device-item', selectedClass: 'device-selected',
          //overClass: 'x-view-over',
          //plugins: [new Ext.DataView.DragSelector()],
        },
        {xtype: 'spacer', height: '15'}
      ]}
    ];
    this.form_config = {
      load_url: config.url + "/edit.json",
      form_width: 400,
      item_list: item_list,
      save_url: config.url + ".json",
      save_method: "PUT"
    };

    Talho.EditDevices.superclass.constructor.call(this, config);

    // Override the setValue() method where necessary
    this.getPanel().find("name", "user[devices]")[0].setValue = function(val){
      var store = this.getStore();
      var devices = jQuery.map(val, function(e,i){ var toks=e.split(":"); return new store.recordType({type:toks[0],value:toks[1]}); });
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
        {xtype: 'textfield', name: 'dev[value]', maxLength: '46', allowBlank: false},
        {xtype: 'combo', name: 'dev[type]', editable: false, value: 'E-mail', triggerAction: 'all',
         store: ['E-mail','Phone','SMS','Fax','Blackberry PIN']}
      ]
    });
    win.addButton({xtype: 'button', text: 'Add', handler: function(){ this.add_cb(win); }, scope: this, width:'auto'});
    win.addButton({xtype: 'button', text: 'Cancel', handler: function(){ win.close(); }, scope: this, width:'auto'});
    win.show();
  },
  add_cb: function(win){
    var type = win.find("name", "dev[type]")[0].getValue();
    var val = win.find("name", "dev[value]")[0].getValue();
    var store = this.getPanel().find("name", "user[devices]")[0].getStore();
    store.add(new store.recordType({type:type,value:val}));
    win.close();
  },
  remove_device: function(){
    var dv = this.getPanel().find("name", "user[devices]")[0];
    var store = dv.getStore();
    store.remove(dv.getSelectedRecords());
  },

  save: function(){
    var store = this.getPanel().find("name", "user[devices]")[0].getStore();
    alert(store.getRange()[0].data.toSource());
  }
});

Talho.EditDevices.initialize = function(config){
  var o = new Talho.EditDevices(config);
  return o.getPanel();
};
