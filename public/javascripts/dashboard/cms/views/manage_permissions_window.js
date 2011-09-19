Ext.ns('Talho.Dashboard.CMS.Views');

Talho.Dashboard.CMS.Views.ManagePermissionsWindow = Ext.extend(Ext.Window, {
  width: 550,
  height: 500,
  layout: 'border',
  title: 'Permissions',
  modal: true,
  initComponent: function(){
    Ext.applyIf(this, {audience_config: {} });
    
    var audience_panel = new Ext.ux.AudiencePanel({title: 'Viewers', itemId: 'viewers', cls: 'cms-audience-viewers'});
    this.items = [
      {xtype: 'tabpanel', region: 'center', activeItem: 0, itemId: 'tabpanel', items: [
        audience_panel,
        {xtype: 'audiencepanel', title: 'Editors', itemId: 'editors', cls: 'cms-audience-editors', jurisdiction_store: audience_panel.jurisdictionTree.getStore(), group_store: (audience_panel.groupSelectionGrid ? audience_panel.groupSelectionGrid.getStore() : null), role_store: audience_panel.roleSelectionGrid.getStore()}
      ]}
    ];
    
    if(this.superadmin){
      this.items.push({xtype: 'checkbox', boxLabel: 'Make this the application default', itemId: 'application_default', region: 'south', checked: this.application_default});
    }
    
    this.buttons = [
      {text: 'OK', scope: this, handler: this.ok_clicked},
      {text: 'Cancel', scope: this, handler: function(){this.close();} }
    ];
    
    Talho.Dashboard.CMS.Views.ManagePermissionsWindow.superclass.initComponent.call(this);
    
    var aud = this.findAudience(1);
    audience_panel.load(aud.jurisdictions, aud.roles, aud.users, aud.groups);
    aud = this.findAudience(6);
    this.getComponent('tabpanel').getComponent('editors').load(aud.jurisdictions, aud.roles, aud.users, aud.groups);
  },
  
  ok_clicked: function(){
    var tab_panel = this.getComponent('tabpanel'),
        viewers = tab_panel.getComponent('viewers'),
        editors = tab_panel.getComponent('editors'),
        aud = {
          viewers: viewers.getSelectedIds(),
          editors: editors.getSelectedIds()
        };
    
    if(this.superadmin){
      aud['application_default'] = this.getComponent('application_default').getValue();
    }
    
    this.fireEvent('save', aud);
    this.close();
  },
  
  findDashboardAudience: function(role){
    var da;
    Ext.each(this.audience_config, function(ac){
      if(ac.role === role){
        da = ac;
        return false;
      }
    });
    return da;
  },
  
  findAudience: function(role){
    var da = this.findDashboardAudience(role);
    return da ? da.audience : {jurisdictions: [], roles: [], groups: [], users: []};
  }
});
