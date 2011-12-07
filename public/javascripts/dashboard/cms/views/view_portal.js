Ext.ns("Talho.Dashboard.CMS.Views");

Talho.Dashboard.CMS.Views.ViewPortal = Ext.extend(Ext.ux.Portal, {
  columnCount: 3,
  buttonAlign: 'left',
  padding: '0px 5px',
  loadPortlets: function(data){
    this.removeAll();
    if(!data.config){
      return;
    }
    this.columnCount = data.config.length;
    Ext.each(data.config, function(item, index, allItems) {
      this.add(item);
    }, this);
    this.doLayout();
  },
  
  showLoadMask: function(){
    var slm = function(){
      if(!this.loadMask){ this.loadMask = new Ext.LoadMask(this.getEl()); }
      this.loadMask.show();
    }
    
    if(this.rendered){
      slm.call(this);
    }
    else {
      this.on('afterrender', slm, this, {once: true, delay: 1});
    }
  },
  
  hideLoadMask: function(){
    this.loadMask.hide();
  }
});
