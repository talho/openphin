Ext.ns('Talho.Dashboard.CMS.Views');

Talho.Dashboard.CMS.Views.AdminPortal = Ext.extend(Talho.Dashboard.CMS.Views.ViewPortal, {
  toggleAdminBorder: function() {
    Ext.each(this.findByType(Ext.ux.Portlet), function(item) {
      var el = item.getEl(),
          panel = el.child('.x-panel-body');
      el.toggleClass('x-panel-noborder');
      el.child('.x-panel-header').toggleClass('x-hide-display');
      panel.toggleClass('x-panel-body-noborder').setWidth(el.getWidth());
    });
    this.doLayout();
  },
});
