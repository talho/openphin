Ext.ns("Talho");

Talho.EditDevices = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    var item_list = [
      {xtype: 'container', layout: 'form', labelAlign: 'top', defaults:{width:400}, items:[
        {xtype: 'container', label: 'Devices', name: 'user[devices]', html: '<p id="foobar">foobar</p>'},
      ]}
    ];
    var url = config.url + ".json";
    var method = "PUT";

    Talho.EditDevices.superclass.constructor.call(this, config, item_list);

    // Override the setValue() method where necessary
    this.getPanel().find("name", "user[devices]")[0].setValue = function(val){
      $("#foobar").html(val.join("<br>"));
    };
  }
});

Talho.EditDevices.initialize = function(config){
  var o = new Talho.EditDevices(config);
  return o.getPanel();
};
