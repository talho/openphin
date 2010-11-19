Ext.ns("Talho");

Talho.EditDevices = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    this.devices_control = new Talho.ux.DevicesControl(config.url + ".json", this);
    this.form_config = {
      load_url: config.url + "/edit.json",
      form_width: 440,
      item_list: [this.devices_control],
      save_url: config.url + ".json",
      save_method: "PUT"
    };

    Talho.EditDevices.superclass.constructor.call(this, config);

    this.getPanel().doLayout();
  },

  load_data: function(json){ this.devices_control.load_data(json.extra.devices); },
  save_data: function(){ this.devices_control.save_data(); },
  is_dirty: function(){ return this.devices_control.is_dirty(); }
});

Talho.EditDevices.initialize = function(config){
  var o = new Talho.EditDevices(config);
  return o.getPanel();
};

Talho.ScriptManager.reg('Talho.EditDevices', Talho.EditDevices, Talho.EditDevices.initialize);
