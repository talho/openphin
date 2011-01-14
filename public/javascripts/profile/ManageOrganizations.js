Ext.ns("Talho");

Talho.ManageOrganizations = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    this.orgs_control = new Talho.ux.OrganizationsControl(config.url + ".json", this);
    this.form_config = {
      load_url: config.url + "/edit.json",
      form_width: 422,
      item_list: [
        {xtype: 'container', items: [
          {xtype: 'container', html: 'Organizations', cls: 'orgs-label'},
          {xtype: 'spacer', height: '10'},
          this.orgs_control
        ]}
      ]
    };

    Talho.ManageOrganizations.superclass.constructor.call(this, config);

    this.getPanel().doLayout();
  },

  load_data: function(json){ this.orgs_control.load_data(json.extra.org_desc); },
  save_data: function(){ this.orgs_control.save_data(); },
  is_dirty: function(){ return this.orgs_control.is_dirty(); }
});

Talho.ManageOrganizations.initialize = function(config){
  var o = new Talho.ManageOrganizations(config);
  return o.getPanel();
};

Talho.ScriptManager.reg('Talho.ManageOrganizations', Talho.ManageOrganizations, Talho.ManageOrganizations.initialize);
