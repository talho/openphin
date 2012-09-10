Ext.ns('Talho.Dashboard.CMS.Views');

Talho.Dashboard.CMS.Views.AdminPortal = Ext.extend(Talho.Dashboard.CMS.Views.ViewPortal, {
  cls: 'admin-dashboard-portal',
  
  listeners: {
    beforedrop: function(dropEvent) {
      dropEvent.panel.column = dropEvent.columnIndex + 1;
    }
  },
  
  showSaveMask: function(){
    var ssm = function(){
      if(!this.saveMask){ this.saveMask = new Ext.LoadMask(this.getEl(), { msg: 'Saving...'}); }
      this.saveMask.show();
    }
    
    if(this.rendered){
      ssm.call(this);
    }
    else {
      this.on('afterrender', ssm, this, {once: true, delay: 1});
    }
  },
  
  hideSaveMask: function(){
    this.saveMask.hide();
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
    
    while(current_columns.length < cols){
      current_columns.push( this.add({xtype: 'portalcolumn', style: {padding: '5px'}, columnWidth: width, items: []}) );
    }
    
    while(current_columns.length > cols){
      var last = current_columns[current_columns.length - 1];
      current_columns.remove(last);
      last.items.each(function(portlet, i){
        portlet.column = (i % current_columns.length) + 1;
        current_columns[(i % current_columns.length)].add(portlet); // mod by the remaining columns, add portlet to column 
      });
      this.remove(last);
    }
    
    
    Ext.each(current_columns, function(column){
      column.columnWidth = width;
    });
    
    this.doLayout();
  },
  
  addPortlet: function(portlet_type){
    var portlet_config;
    
    switch(portlet_type){
      case 'phin': portlet_config = {xtype: 'dashboardphinportlet', column: 1, html: '&nbsp;'};
        break;
      case 'twitter': portlet_config = {xtype: 'dashboardtwitterportlet', column: 1};
        break;
      case 'rss': portlet_config = {xtype: 'dashboardrssportlet', column: 1};
        break;
      case 'forum': portlet_config = {xtype: 'dashboardforumportlet', column: 1};
        break;
      case 'doc': portlet_config = {xtype: 'dashboarddocportlet', column: 1};
        break;
      case 'alert': portlet_config = {xtype: 'dashboardalertportlet', column: 1};
        break;
      case 'html':
      default: portlet_config = {xtype: 'dashboardhtmlportlet', column: 1, html: '&nbsp;'};
        break;
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

