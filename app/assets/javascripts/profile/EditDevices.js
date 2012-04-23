Ext.ns("Talho");

Talho.EditDevices = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    this.devices_control = new Talho.ux.DevicesControl(config.url + ".json", this);

    this.infobox = new Ext.Container({
      layout: 'column',
      width: 600,
      cls: 'infobox',
      items: [
        {xtype: 'box', cls:'infobox-inner', width: 50, html:'<img src="/assets/info_icon.png">'},
        {xtype: 'container', cls:'infobox-inner', items:[
          {xtype: 'box', html: 'Devices in this list will receive TxPhin Alerts.'},
          {xtype: 'box', html: 'When you are satisfied with the list, click "Apply Changes"'}
        ]}
      ]
    });

    this.form_config = {
      load_url: config.url + "/edit.json",
      form_width: 600,
      item_list: [
        {xtype: 'container', items: [
          {xtype: 'container', html: 'My Alerting Devices', cls: 'devices-label'},
          {xtype: 'spacer', height: '10'},
          this.infobox,
          {xtype: 'spacer', height: '10'},
          this.devices_control
        ]}
      ]
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
