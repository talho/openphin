Ext.ns("Talho.Dashboard.CMS.Views");

Talho.Dashboard.CMS.Views.ViewPortal = Ext.extend(Ext.ux.Portal, {
  columnCount: 3,
  buttonAlign: 'left',
  padding: '5px',
  loadPortlets: function(data){
    this.removeAll();
    this.columnCount = data.config.length;
    Ext.each(data.config, function(item, index, allItems) {
      this.add(item);
    }, this);
    this.doLayout();
  }
});
