
Ext.define('Talho.controller.Tab',{
  extend: 'Ext.app.Controller',
  refs: [{
    selector: 'applicationtabpanel',
    ref: 'panel'
  }],
  
  init: function(){
    this.application.on({
      'open_tab': this.openTab, 
      'open_window': this.openWindow, 
      scope: this
    });
  },
  
  openTab: function(config){
    console.log('Open ' + config.title + ' tab.');
  },
  
  openWindow: function(config){
    console.log('Open ' + config.title + ' window.');
  }
});
