//= require_tree ./view

Ext.ns('Talho.Reports');

Talho.Reports.Controller = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    Ext.apply(this, config);
    
    var layout = new Talho.Reports.view.Layout({
      listeners: {
        scope: this,
        'newreport': this.showNewReport,
        'runreport': this.runReport,
        'deletereport': this.deleteReport
      }
    });
    this.getPanel = function(){
      return layout;
    }
  },
  
  showNewReport: function(){
    var layout = this.getPanel();
    while(layout.items.itemAt(1)){
      layout.remove(layout.items.itemAt(1));
    }
    
    layout.add(new Talho.Reports.view.New({flex: 1}));
    layout.add({xtype: 'box', flex: 1});
    
    layout.doLayout();
  },
  
  runReport: function(report_name){
    var mask = new Ext.LoadMask(this.getPanel().getEl(), {msg: 'Generating Report'});
    mask.show();
    Ext.Ajax.request({
      method: 'POST',
      url: '/reports.json',
      params: {report: report_name},
      failure: this.runFailed,
      success: this.runSucceeded,
      callback: function(){
        mask.hide();
        mask.destroy();
      },
      scope: this
    });
  },
  
  runFailed: function(resp){
    
  },
  
  runSucceeded: function(resp){
    var layout = this.getPanel();
    layout.items.itemAt(0).refresh();
    layout.remove(layout.items.itemAt(1));
    layout.add({xtype: 'box', flex: 1});
    layout.doLayout();
  },
  
  deleteReport: function(rec){
    Ext.Msg.confirm("Confirm delete", "Are you sure you want to delete the " + rec.get('name') + " report run on " + rec.get('date'), function(btn){
      if(btn == 'yes'){
        var mask = new Ext.LoadMask(this.getPanel().getEl(), {msg: 'Deleting Report'});
        mask.show();
        Ext.Ajax.request({
          method: 'DELETE',
          url: '/reports/' + rec.get('id') + '.json',
          scope: this,
          callback: function(){
            mask.hide();
            mask.destroy();
            this.getPanel().items.itemAt(0).refresh();
          }
        });
      }
    }, this);
  }
});

Talho.ScriptManager.reg('Talho.Reports', Talho.Reports.Controller, function(config){
  var cont = new Talho.Reports.Controller(config);
  return cont.getPanel();
});
