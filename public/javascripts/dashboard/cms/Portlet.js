
Ext.define('Talho.Dashboard.Portlet', {
  extend: 'Ext.ux.Portlet',
  alias: ['widget.dashboardportlet'],
  // Used to restrict which properties can be used when creating a portlet from the json data
  fields: {
    //border: true,
    column: true,
    //headerCssClass: true,
    itemId: true,
    //ownerCt: true,
    xtype: true
  },

  constructor: function(config) {
    approvedConfig = {}
    for(var property in config) {
      if(property in this.fields && this.fields[property])
      approvedConfig[property] = config[property];
    }

    Ext.apply(this, approvedConfig);
    Talho.Dashboard.Portlet.superclass.constructor.call(this);
  },

  initComponent: function(config) {
    Ext.ux.Portlet.superclass.initComponent.call(this);
  },

  isModified: function() {
    return true;
  },

  revert: function() {
    return false;
  },

  buildConfig: function() {
    return {};
  },

  border: false,
  header: true,
  frame: false,
  closable: false,
  collapsible : false,
  draggable : true,
  headerCssClass: 'x-hide-display',
  cls: '',
  tools: [{
    id:'close',
    handler: function(e, target, panel){
      panel.ownerCt.remove(panel, true);
    }
  }],
  
  toggleAdminBorder: function(){
      var el = this.getEl(),
          panel = el.child('.x-panel-body');
      el.toggleClass('x-panel-noborder').toggleClass('portlet-admin');
      el.child('.x-panel-header').toggleClass('x-hide-display');
      panel.toggleClass('x-panel-body-noborder').setWidth(el.getWidth());
  }
});
