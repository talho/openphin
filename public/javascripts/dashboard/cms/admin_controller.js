Ext.ns('Talho.Dashboard.CMS');

Talho.Dashboard.CMS.AdminController = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    Ext.apply(this, config);
    
    this.portal = new Talho.Dashboard.CMS.Views.AdminPortal({
      title: 'Edit Dashboards',
      closable: true
    });
    
    this.loadDashboard(this.dashboard_id);
  },
  
  loadDashboard: function(dash_id){
    // get current dashboard
    Ext.Ajax.request({
      url: '/dashboard/' + dash_id + '/edit.json',
      method: 'GET',
      scope: this,
      success: function(resp){
        var data = Ext.decode(resp.responseText).dashboard;
        this.portal.loadPortlets(data);
        this.portal.toggleAdminBorder();
      }
    });
  }
  
});

Talho.ScriptManager.reg('Talho.Dashboard.CMS.Admin', Talho.Dashboard.CMS.AdminController, function(config){
  var ctrl = new Talho.Dashboard.CMS.AdminController(config);
  return ctrl.portal;
});


