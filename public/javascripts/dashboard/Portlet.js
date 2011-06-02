Ext.namespace('Talho');
Ext.namespace('Talho.Dashboard');
Ext.namespace('Talho.Dashboard.Portlet');

Talho.Dashboard.Portlet = Ext.extend(Ext.ux.Portlet, {
  // Used to restrict which properties can be used when creating a portlet from the json data
  fields: {
    border: true,
    column: true,
    headerCssClass: true,
    ownerCt: true,
    xtype: true
  },

  constructor: function(config) {
    approvedConfig = {}
    for(var property in config) {
      if(property in this.fields && this.fields[property])
      approvedConfig[property] = config[property];
    }

    Ext.apply(this, approvedConfig);
    debugger
    Talho.Dashboard.Portlet.superclass.constructor.call(this, approvedConfig);
  },

  initComponent: function(config) {
    Ext.ux.Portlet.superclass.initComponent.call(this);
  },
  border: false,
  header: true,
  frame: false,
  closable: false,
  collapsible : false,
  draggable : true,
  headerCssClass: 'x-hide-display',
  cls: ''
});

Ext.reg('dashboardportlet', Talho.Dashboard.Portlet);