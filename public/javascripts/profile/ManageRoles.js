Ext.ns("Talho");

Talho.ManageRoles = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    this.roles_control = new Talho.ux.RolesControl(config.url + ".json", this);
    this.form_config = {
      load_url: config.url + "/edit.json",
      form_width: 440,
      item_list: [this.roles_control]
    };

    Talho.ManageRoles.superclass.constructor.call(this, config);

    this.getPanel().doLayout();
  },

  load_data: function(json){ this.roles_control.load_data(json.extra.role_desc); },
  save_data: function(){ this.roles_control.save_data(); },
  is_dirty: function(){ return this.roles_control.is_dirty(); }
});

Talho.ManageRoles.initialize = function(config){
  var o = new Talho.ManageRoles(config);
  return o.getPanel();
};

Talho.ScriptManager.reg('Talho.ManageRoles', Talho.ManageRoles, Talho.ManageRoles.initialize);
