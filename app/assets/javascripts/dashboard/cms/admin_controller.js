//= require ext_extensions/xActionColumn
//= require ext_extensions/PhinHtmlEditor
//= require ./portlet
//= require_tree ./views
//= require_self

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
          'open': this.showOpenDashboardWindow,
          'delete': this.deleteDashboard,
          'permissions': this.showPermissionsWindow
        }
      })
    });
    
    this.loadDashboard(this.dashboard_id);
  },
  
  loadDashboard: function(dash_id){
    this.dashboard_id = dash_id;
    
    this.portal.showLoadMask();
    
    // get current dashboard
    Ext.Ajax.request({
      url: '/dashboard/' + dash_id + '/edit.json',
      method: 'GET',
      scope: this,
      success: function(resp){
        var data = Ext.decode(resp.responseText),
            dashboard = data.dashboard;
            
        if(data.success === false){
          this.clearDashboard();
          return;
        }
        
        this.portal.loadPortlets(dashboard, true);
        this.portal.toggleAdminBorder();
        this.loadAudience(dashboard);
        this.portal.getTopToolbar().enableEditCurrent();
      },
      failure: function(){
        this.clearDashboard();
      },
      callback: function(){
        this.portal.hideLoadMask();
      }
    });
  },
  
  loadAudience: function(data){
    this.audience_config = data.dashboard_audiences;
    this.application_default = data.application_default;
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
    
    if(this.superadmin){
      params['application_default'] = this.application_default;
    }
    
    if(this.audience_config){
      var daa = [];
      Ext.each(this.audience_config, function(ac){
        if(ac.role === 1 || ac.role === 6){
          var cfg = {role: ac.role};
          if(ac.id){ cfg.id = ac.id; }
          if(ac.audience_attributes) { cfg.audience_attributes = ac.audience_attributes; }
          daa.push(cfg);
        }
      });
      params['dashboard_audiences_attributes'] = daa;
    }
    
    this.portal.showSaveMask();
    
    Ext.Ajax.request({
      url: '/dashboard/' + this.dashboard_id + '.json',
      method: 'PUT',
      params: {
        dashboards: Ext.encode(params)
      },
      scope: this,
      success: function(){
        
      },
      callback: function(){
        this.portal.hideSaveMask();
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
    
    this.portal.showSaveMask();
    
    Ext.Ajax.request({
      url: '/dashboard.json',
      method: 'POST',
      params: params,
      scope: this,
      success: function(resp){
        var data = Ext.decode(resp.responseText);
        this.loadDashboard(data.id);
      },
      failure: function(){
        this.clearDashboard();
      },
      callback: function(){
        this.portal.hideSaveMask();
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
  },
  
  showPermissionsWindow: function(){
    var win = new Talho.Dashboard.CMS.Views.ManagePermissionsWindow({
      audience_config: this.audience_config,
      application_default: this.application_default,
      superadmin: this.superadmin,
      listeners: {
        scope: this,
        'save': function(audience_results){
          var set_audience_ids = function(r, ids){
            var v;
            Ext.each(this.audience_config, function(ac){
              if(ac.role === r){
                v = ac;
                return false;
              }
            });
            if(v){
              v.audience_attributes = ids;
            }
            else{
              this.audience_config.push({role: r, audience_attributes: ids});
            }
          }
          
          set_audience_ids.call(this, 6, audience_results.editors);
          set_audience_ids.call(this, 1, audience_results.viewers);
          
          this.application_default = audience_results.application_default;
        }
      }
    });
    
    win.show();
  },
  
  deleteDashboard: function(){
    Ext.Msg.confirm("Delete Dashboard", "Are you sure you want to delete this dashboard? This action cannot be undone", function(btn){
      if(btn === 'yes'){
        this.portal.showSaveMask();
        Ext.Ajax.request({
          url: '/dashboard/' + this.dashboard_id + '.json',
          method: 'DELETE',
          scope: this,
          success: function(){
            this.clearDashboard();
          },
          failure: function(response){
            var data = Ext.decode(response.responseText);
            Ext.Msg.alert("Error", data.msg);
          },
          callback: function(){
            this.portal.hideSaveMask();
          }
        })
      }
    }, this);
  },
  
  clearDashboard: function(){
    this.dashboard_id = null;
    this.portal.removeAll();
    this.portal.getTopToolbar().disableEditCurrent();
  }
});

Talho.ScriptManager.reg('Talho.Dashboard.CMS.Admin', Talho.Dashboard.CMS.AdminController, function(config){
  var ctrl = new Talho.Dashboard.CMS.AdminController(config);
  return ctrl.portal;
});


