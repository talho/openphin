Ext.namespace('Talho');
Ext.namespace('Talho.Dashboard');
Ext.namespace('Talho.Dashboard.Portlet');

Talho.Dashboard.Portlet = Ext.extend(Ext.ux.Portlet, {
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