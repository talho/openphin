
Ext.define('Talho.controller.Menu',{
  extend: 'Ext.app.Controller',
  init: function(){
    this.control({
      'viewport > panel > toolbar menuitem': {
        'click': this.handle_click
       },
      'viewport > panel > toolbar button': {
        'click': this.handle_click
       }
    });
    this.callParent();
  },
  
  handle_click: function(btn){
    if(btn.tab){
      this.application.fireEvent('open_tab', btn.tab);
    }
    else if(btn.win){
      this.application.fireEvent('open_window', btn.win);
    }
  }
});
