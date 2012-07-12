//= require ./portlet
//= require ./views/view_portal
//= require_self

Ext.ns('Talho.Dashboard.CMS');

Talho.Dashboard.CMS.ViewController = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    Ext.apply(this, config);
    
    this.dashboard_id = Application.default_dashboard
    
    // build empty display
    if(this.dashboard_id === undefined){
      this.portal = new Ext.Panel({
        closable: true,
        title: 'Dashboard',
        padding: '10',
        html: '<h3>No dashboard selected</h3>'+
          '<p>You have no default dashboard selected. Please select one in your user profile</p>'
      });
      return;
    }
    
    // build portal
    this.portal = new Talho.Dashboard.CMS.Views.ViewPortal({
      title: 'Dashboard',
      bbar: {
        hidden: true,
        items: []
      }
    });
    
    this.portal.showLoadMask();
    
    // get current dashboard
    Ext.Ajax.request({
      url: '/dashboard/' + this.dashboard_id + '.json',
      method: 'GET',
      scope: this,
      success: function(resp){
        var data = Ext.decode(resp.responseText).dashboard;
        this.portal.loadPortlets(data);
      },
      callback: function(){
        this.portal.hideLoadMask();
      }
    });
    
    Ext.Ajax.request({
      url: '/users/' + Application.current_user + '/is_admin.json',
      method: 'GET',
      scope: this,
      success: this.show_admin_toolbar
    });
  },
  
  show_admin_toolbar: function(resp){
    var data = Ext.decode(resp.responseText);
    this.admin_info = data;
    if(data.admin === true){
      var bbar = this.portal.getBottomToolbar();
      bbar.add({text: 'Edit Dashboards', scope: this, handler: this.show_edit_dashboards});
      bbar.show();
      this.portal.doLayout();
    }
  },
  
  show_edit_dashboards: function(){
    // launch a new tab for the edit dashboard functionality
    Application.fireEvent('opentab', {title: 'Edit Dashboards', initializer: 'Talho.Dashboard.CMS.Admin', dashboard_id: this.dashboard_id, superadmin: this.admin_info.superadmin})
  }
});

Talho.Dashboard.CMS.ViewController.initialize = function(config){
  var vc = new Talho.Dashboard.CMS.ViewController(config);
  return vc.portal;
};
