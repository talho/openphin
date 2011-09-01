Ext.ns('Talho.Dashboard.CMS');

Talho.Dashboard.CMS.AdminController = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    Ext.apply(this, config);
    
    this.portal = new Talho.Dashboard.CMS.Views.AdminPortal({
      title: 'Edit Dashboards',
      closable: true,
      tbar: new Talho.Dashboard.CMS.Views.AdminToolbar({
        listeners: {
          scope: this,
          'showcolumnslider': this.showColumnSlider,
          'columnchange': this.changeNumColumns,
          'togglepreview': this.togglePreview,
          'addportlet': this.addPortlet,
          'save': this.saveDashboard,
          'new': this.showNewDashboardWindow,
          'open': this.showOpenDashboardWindow
        }
      })
    });
    
    this.loadDashboard(this.dashboard_id);
  },
  
  loadDashboard: function(dash_id){
    this.dashboard_id = dash_id;
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
  },
  
  showColumnSlider: function(){
    this.portal.getTopToolbar().showColumnSlider(this.portal.columnCount);
  },
  
  changeNumColumns: function(num){
    this.portal.changeNumColumns(num);
  },
  
  togglePreview: function(){
    this.portal.toggleAdminBorder();
  },
  
  addPortlet: function(portlet_type){
    this.portal.addPortlet(portlet_type);
  },
  
  saveDashboard: function(){
    var params = {
      columns: this.portal.columnCount,
      config: this.portal.getConfig()
    };
    
    Ext.Ajax.request({
      url: '/dashboard/' + this.dashboard_id + '.json',
      method: 'PUT',
      params: {
        dashboards: Ext.encode(params)
      },
      scope: this,
      success: function(){
        
      }
    });
  },
  
  showNewDashboardWindow: function(){
    var win = new Talho.Dashboard.CMS.Views.NewDashboardWindow({
      listeners: {
        scope: this,
        'new': this.newDashboard
      }
    });
    
    win.show();
  },
  
  newDashboard: function(name){
    var params = {
      'dashboard[name]': name
    };
    
    Ext.Ajax.request({
      url: '/dashboard.json',
      method: 'POST',
      params: params,
      scope: this,
      success: function(resp){
        var data = Ext.decode(resp.responseText);
        this.loadDashboard(data.id);
      }
    });
  },
  
  showOpenDashboardWindow: function(){
    var win = new Talho.Dashboard.CMS.Views.OpenDashboardWindow({
      listeners: {
        scope: this,
        'open': this.loadDashboard
      }
    });
    
    win.show();
  }
});

Talho.ScriptManager.reg('Talho.Dashboard.CMS.Admin', Talho.Dashboard.CMS.AdminController, function(config){
  var ctrl = new Talho.Dashboard.CMS.AdminController(config);
  return ctrl.portal;
});


