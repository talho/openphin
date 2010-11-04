Ext.ns("Talho");

Talho.ManageRoles = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    this.form_config = {
      load_url: config.url + "/edit.json",
      form_width: 600,
      item_list: null,
      save_url: config.url + ".json",
      save_method: "PUT"
    };
    this.roles_control = new Talho.RolesControl(config, this);
    this.form_config.item_list = this.roles_control.item_list;

    Talho.ManageRoles.superclass.constructor.call(this, config);

    this.getPanel().doLayout();
    this.getPanel().addListener("beforeclose", function(p){
      Ext.Msg.confirm("Save Is Needed",
        "Changes need to be saved.  Press 'Yes' to close and abandon your changes.",
        function(id){  if (id == "yes") p.destroy(); });
      return false;
    });
  },

  load_data: function(json){ this.roles_control.load_data(json.extra.role_desc); },
  save_data: function(){ this.roles_control.save_data(); }
});

Talho.ManageRoles.initialize = function(config){
  var o = new Talho.ManageRoles(config);
  return o.getPanel();
};

Talho.ScriptManager.reg('Talho.ManageRoles', Talho.ManageRoles, Talho.ManageRoles.initialize);
