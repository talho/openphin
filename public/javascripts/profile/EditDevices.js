Ext.ns("Talho");

Talho.EditDevices = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    var store = new Ext.data.Store({
      autoDestroy: true, // destroy the store if the grid is destroyed
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
      '<h2>Devices</h2>',
      '<ul class="devices">',
      '<tpl for=".">',
        '<li class="device-item">',
          '<p><span class="title minor">{value}</span>&nbsp;&nbsp;&nbsp;{type}</p>',
        '</li>',
      '</tpl>',
      '</ul>'
    );

    var ttt = this;
    var item_list = [
      {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:400}, items:[
        {xtype: 'dataview', name: 'user[devices]',
          store: store,
          tpl: template,
          autoHeight: true,
          multiSelect: true,
          //overClass: 'x-view-over',
          itemSelector: 'li.device-item',
          selectedClass: 'device-selected',
          emptyText: 'No devices to display',
          //plugins: [new Ext.DataView.DragSelector()],
        }
      ]}
    ];
    var url = config.url + ".json";
    var method = "PUT";

    Talho.EditDevices.superclass.constructor.call(this, config, 400, item_list, url, method);

    // Override the setValue() method where necessary
    this.getPanel().find("name", "user[devices]")[0].setValue = function(val){
      var store = this.getStore();
      var devices = jQuery.map(val, function(e,i){ var toks=e.split(":"); return new store.recordType({type: toks[0], value: toks[1]}); });
      store.add(devices);
    };

    this.getPanel().doLayout();
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
