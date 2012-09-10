//= require ./views/Index

Ext.ns('Talho.Dashboard.Apps');

Talho.Dashboard.Apps.Controller = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    var index = new Talho.Dashboard.Apps.view.Index({
      listeners: {
        scope: this,
        'addapp': this.addApp
      }
    });
    
    this.getPanel = function(){
      return index;
    }
  },
  
  addApp: function(app){
    var mask = new Ext.LoadMask(this.getPanel().getEl(), 'Saving');
    mask.show();
    
    Ext.Ajax.request({
      url: '/apps/' + app.get('id') + '.json',
      method: 'PUT',
      scope: this,
      success: function(){
        this.getPanel().refreshGrids();
        this.getPanel().showSuccess(app);
        mask.hide();
      },
      failure: function(){
        mask.hide();
        this.getPanel().showFailure();
        this.getPanel().refreshGrids();
      }
    });
  }
});

Talho.ScriptManager.reg("Talho.Dashboard.Apps", Talho.Dashboard.Apps.Controller, function(config){
  var cont = new Talho.Dashboard.Apps.Controller(config);
  return cont.getPanel();
});
