Ext.namespace('Talho');

Talho.DashboardPortalColumn = Ext.extend(Ext.ux.PortalColumn, {
  defaultType : 'dashboardportlet',
  cls: ''
});

Ext.reg('dashboardportalcolumn', Talho.DashboardPortalColumn);

Talho.DashboardPortlet = Ext.extend(Ext.ux.Portlet, {
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

Ext.reg('dashboardportlet', Talho.DashboardPortlet);

Talho.DashboardPortal = Ext.extend(Ext.ux.Portal, {
  constructor: function(config) {
    Ext.apply(this, config);
    Talho.DashboardPortal.superclass.constructor.call(this, config);
  },
  region: 'center',
  itemId: this.itemId,
  defaultType : 'dashboardportalcolumn',
  cls: '',
  adminMode: false,
  listeners:{
    'show':function(panel){panel.doLayout();}
  },

  initComponent : function(config){
    this.bbar = {
      items: [{
        text: "Admin Mode",
        scope: this,
        handler: function(b, e) {
          var text = this.adminMode ? "Admin Mode" : "User Mode";
          b.setText(text);
          this.toggleAdmin();

          this.getBottomToolbar().items.each(function(item, index, allItems) {
            if(item != b) item.setVisible(!item.isVisible());
          });
        }
      },{
        xtype: 'tbseparator',
        hidden: true
      },{
        text: 'Preview',
        hidden: true
      },{
        xtype: 'tbseparator',
        hidden: true
      },{
        text: 'Published',
        hidden: true
      }],
      hidden: true
    }

    Ext.ux.Portal.superclass.initComponent.call(this);

    this.addEvents({
        validatedrop:true,
        beforedragover:true,
        dragover:true,
        beforedrop:true,
        drop:true
    });

    var toolbar = this.getBottomToolbar();
    Ext.Ajax.request({
      url: '/users/' + Application.current_user + '/is_admin.json',
      scope: toolbar,
      success: function(response) {
        var data = Ext.util.JSON.decode(response.responseText);
        if(data['admin']) this.show();
      }
    });
  },

  toggleAdmin: function() {
    this.items.each(function(item, index, allItems) {
      item.items.each(function(item, index, allItems) {
        item.el.toggleClass('x-panel-noborder');
        item.el.child('.x-panel-header').toggleClass('x-hide-display');
        var panel = item.el.child('.x-panel-body');
        var width = (item.el.getStyle('width') == panel.getStyle('width') ? -2 : 0)
        item.el.child('.x-panel-body').setStyle('width', (item.el.getWidth() + width));
        item.el.child('.x-panel-body').toggleClass('x-panel-body-noborder');
      });
    });

    this.adminMode = !this.adminMode;
  },

  initEvents : function(){
    Ext.ux.Portal.superclass.initEvents.call(this);

    this.dd = new Ext.ux.Portal.DropZone(this, this.dropConfig);
  },

  beforeDestroy : function() {
    if(this.dd){
        this.dd.unreg();
    }

    Ext.ux.Portal.superclass.beforeDestroy.call(this);
  }
});

Talho.Dashboard = Ext.extend(Ext.util.Observable, {
  constructor: function(config)
  {
    Ext.apply(this, config);

    Talho.Dashboard.superclass.constructor.call(this, config);

    var tools = [{
      id:'gear',
      handler: function(){
        Ext.Msg.alert('Message', 'The Settings tool was clicked.');
      }
    },{
      id:'close',
      handler: function(e, target, panel){
        panel.ownerCt.remove(panel, true);
      }
    }];

    var portal = new Talho.DashboardPortal({
      items: [{
        columnWidth:.33,
        style:'padding:10px 0 10px 10px',
        items:[{
          title: 'Grid in a Portlet',
          html: '<p> Test 1 </p>',
          data: {
            title: 'Grid in a Portlet',
            html: '<p> Test 1 </p>'
          },
          layout:'fit',
          tools: tools
        },{
          title: 'Grid in a Portlet',
          html: '<p> Test 1 </p>',
          data: {
            title: 'Another Panel 1',
            html: "<p> Test 2 </p>"
          },
          tools: tools
        }]
      },{
        columnWidth:.33,
        style:'padding:10px 0 10px 10px',
        items:[{
          title: 'Grid in a Portlet',
          html: '<p> Test 1 </p>',
          data: {
            title: 'Panel 2',
            html: "<p> Test 3 </p>"
          },
          tools: tools
        },{
          title: 'Grid in a Portlet',
          html: '<p> Test 1 </p>',
          data: {
            title: 'Another Panel 2',
            html: "<p> <b> Test 4 </b> </p>"
          },
          tools: tools          
        }]
      },{
        columnWidth:.33,
        style:'padding:10px',
        items:[{
          title: 'Grid in a Portlet',
          html: '<p> Test 1 </p>',
          data: {
            title: 'Panel 3',
            html: "<p> <i> Test 5 </i> </p>"
          },
          tools: tools
        },{
          title: 'Grid in a Portlet',
          html: '<p> Test 1 </p>',
          data: {
            title: 'Another Panel 3',
            html: "<p> Test 6 </p>"
          },
          tools: tools          
        }]
      }]
    });

    var panel = new Ext.Panel({
      title: 'Dashboard',
      layout: 'border',
      items: [portal]
    });


    this.getPanel = function(){
      return panel;
    }
  }
});

Talho.Dashboard.initialize = function(config)
{
  return (new Talho.Dashboard(config)).getPanel();
}
