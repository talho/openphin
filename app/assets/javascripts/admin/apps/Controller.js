//= require_tree ./view
//= require_self

Ext.ns("Talho.Admin.Apps")

Talho.Admin.Apps.Controller = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    Ext.apply(this, config);
    
    var layout = new Talho.Admin.Apps.view.Layout({});
    
    this.getPanel = function(){
      return layout;
    };
  }
});

Talho.ScriptManager.reg("Talho.Admin.Apps", Talho.Admin.Apps.Controller, function(config){
  var cont = new Talho.Admin.Apps.Controller(config);
  return cont.getPanel();
});
