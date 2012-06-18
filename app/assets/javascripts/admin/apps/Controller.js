//= require ext_extensions/VerticalTabPanel/Ext.ux.tot2ivn.VrTabPanel
//= require_tree ./view
//= require_self

Ext.ns("Talho.Admin.Apps")

Talho.Admin.Apps.Controller = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    Ext.apply(this, config);
    
    var index = new Talho.Admin.Apps.view.Index({});
    var new_app = new Talho.Admin.Apps.view.New({
      listeners: {
        scope: this,
        'cancel': this._new_app_cancel,
        'save': this._new_app_save
      }
    });
    var layout = new Ext.create({
      xtype: 'vrtabpanel',
      title: "Manage Apps",
      id: "manage_apps",
      closable: true,
      activeTab: 0,
      items: [
        index,
        new_app
      ]
    });
    
    this.getPanel = function(){
      return layout;
    };
  },
  
  _new_app_cancel: function(){
    this.getPanel().setActiveTab(0);
  },
  
  _new_app_save: function(name, id){
    var layout = this.getPanel();
    // Open a show app tab with the newly created app.
    layout.add(new Talho.Admin.Apps.view.Show({id: 'app-' + id, appId: id, title: 'App Details: ' + name}));
    layout.setActiveTab(layout.items.length - 1);
  },
  
  _detail_change: function(id, name, val){
    // make an update call to the server
  }
});

Talho.ScriptManager.reg("Talho.Admin.Apps", Talho.Admin.Apps.Controller, function(config){
  var cont = new Talho.Admin.Apps.Controller(config);
  return cont.getPanel();
});
