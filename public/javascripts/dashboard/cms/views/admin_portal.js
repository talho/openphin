Ext.ns('Talho.Dashboard.CMS.Views');

Talho.Dashboard.CMS.Views.AdminPortal = Ext.extend(Talho.Dashboard.CMS.Views.ViewPortal, {
  listeners: {
    beforedrop: function(dropEvent) {
      dropEvent.panel.column = dropEvent.columnIndex + 1;
    }
  }, 
  
  toggleAdminBorder: function() {
    Ext.each(this.findByType(Ext.ux.Portlet), function(item) {
      item.toggleAdminBorder();
    }, this);
    this.doLayout();
  },
  
  changeNumColumns: function(cols){
    var current_columns = this.findByType('portalcolumn');
    if(current_columns.length === cols){
      return;
    }
    
    this.columnCount = cols;
    var width = (1.0/cols);
    
    if(current_columns.length < cols){
      this.add({xtype: 'portalcolumn', style: {padding: '5px'}, columnWidth: width, items: []});
    }
    else{ // there are more current columns than 
      while(current_columns.length > cols){
        var last = current_columns[current_columns.length - 1];
        current_columns.remove(last);
        last.items.each(function(portlet, i){
          portlet.column = (i % current_columns.length) + 1;
          current_columns[(i % current_columns.length)].add(portlet); // mod by the remaining columns, add portlet to column 
        });
        this.remove(last);
      }
    }
    
    Ext.each(current_columns, function(column){
      column.columnWidth = width;
    });
    
    this.doLayout();
  },
  
  addPortlet: function(portlet_type){
    var portlet_config;
    
    switch(portlet_type){
      case 'html':
      default: 
        portlet_config = {xtype: 'dashboardhtmlportlet', column: 1, html: '&nbsp;'};
    }
    
    var portlet = this.items.get(0).add(portlet_config);
    portlet.on('render', function(portlet){portlet.toggleAdminBorder();}, this, {delay: 1, once: true});
    this.doLayout();
  },
  
  getConfig: function(){
    var config = [];
    this.items.each(function(column) {
      var col_config = {items: Ext.invoke(column.items.getRange(), 'buildConfig')}
      config.push(col_config);
    });
    return config;
  }
});
