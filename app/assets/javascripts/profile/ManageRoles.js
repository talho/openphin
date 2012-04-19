Ext.ns("Talho");

Talho.ManageRoles = Ext.extend(Talho.ProfileBase, {
  constructor: function(config){
    this.roles_control = new Talho.ux.RolesControl(config.url + ".json", this);

    this.infobox = new Ext.Container({
      layout: 'column',
      width: 600,
      cls: 'infobox',
      items: [
        {xtype: 'box', cls:'infobox-inner', width: 50, html:'<img src="/images/info_icon.png">'},
        {xtype: 'container', cls:'infobox-inner', items:[
          {xtype: 'box', html: 'Roles determine your permissions and which alerts you receive.'},
          {xtype: 'box', html: "Most roles will require an administrator's approval. "},
          {xtype: 'box', html: 'When you are satisfied with the list, click "Apply Changes"'}
        ]}
      ]
    });

    this.form_config = {
      load_url: config.url + "/edit.json",
      form_width: 600,
      item_list: [
        {xtype: 'container', items: [
          {xtype: 'container', html: 'My Roles', cls: 'roles-label'},
          {xtype: 'spacer', height: '10'},
          this.infobox,
          {xtype: 'spacer', height: '10'},
          this.roles_control
        ]}
      ]
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
