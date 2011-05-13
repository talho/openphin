Ext.namespace('Talho');
Ext.namespace('Talho.Dashboard');

Talho.Dashboard.PortalColumn = Ext.extend(Ext.ux.PortalColumn, {
  defaultType : 'dashboardportlet',
  cls: ''
});

Ext.reg('dashboardportalcolumn', Talho.Dashboard.PortalColumn);

Talho.Dashboard.Portal = Ext.extend(Ext.ux.Portal, {
  constructor: function(config) {
    Ext.apply(this, config);
    Talho.Dashboard.Portal.superclass.constructor.call(this, config);
  },
  region: 'center',
  itemId: this.itemId,
  defaultType : 'dashboardportalcolumn', cls: '',
  adminMode: false,
  columnCount: 3,
  listeners:{
    'show':function(panel){panel.doLayout();}
  },

  initComponent : function(config){
    this.tbar = {
      hidden: true,
      items: [{
        xtype: 'buttongroup',
        items: [{
          text: 'New',
          scope: this,
          handler: function() {
            this.items.each(function(item, index, allItems) {
              item.removeAll(true);
            });
            this.removeAll(true);

            this.items.add(new Talho.Dashboard.PortalColumn({columnWidth: .33, style:'padding:10px', items: []}));
            this.items.add(new Talho.Dashboard.PortalColumn({columnWidth: .33, style:'padding:10px', items: []}));
            this.items.add(new Talho.Dashboard.PortalColumn({columnWidth: .33, style:'padding:10px', items: []}));
            this.columnCount = 3;
          }
        },{
          text: '2 column',
          scope: this,
          handler: function() {
            if(this.columnCount != 2) {
              // Distribute existing portlets on last column to other columns
              this.items.last().items.each(function(item, index, allItems) {
                if(index % 2 == 0) {
                  item.column = 0;
                  this.items.first().add(item);
                } else {
                  item.column = 1;
                  this.items.itemAt(1).add(item);
                }
              },this);

              //Remove the last column
              item = this.items.last();
              this.items.remove(item);
              item.destroy();

              // Set column width on remaining columns
              this.items.each(function(item, index, allItems) {
                item.columnWidth = .5;
              });
              this.doLayout();
              this.columnCount = 2;
            }
          }
        },{
          text: '3 column',
          scope: this,
          handler: function() {
            if(this.columnCount != 3) {
              this.items.each(function(item, index, allItems) {
                item.columnWidth = .33;
              });
              this.items.add(new Talho.Dashboard.PortalColumn({columnWidth:.33, style:'padding:10px', items: []}));
              this.doLayout();
              this.columnCount = 3;
            }
          }
        }]
      },{
        xtype: 'buttongroup',
        items: [{
          text: 'Add Portlet',
          menu: [{
            text: 'HTML',
            scope: this,
            handler: function() {
        /*item.el.toggleClass('x-panel-noborder');
        item.el.child('.x-panel-header').toggleClass('x-hide-display');
        var panel = item.el.child('.x-panel-body');
        var width = (item.el.getStyle('width') == panel.getStyle('width') ? -2 : 0)
        item.el.child('.x-panel-body').setStyle('width', (item.el.getWidth() + width));
        item.el.child('.x-panel-body').toggleClass('x-panel-body-noborder');*/
              this.items.first().add(new Talho.Dashboard.Portlet.HTML({html: '&nbsp;', headerCssClass: undefined, border: true, column: 0}));
              this.doLayout();
            }
          }]
        }]
      }]
    },
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
    this.getTopToolbar().setVisible(!this.getTopToolbar().isVisible());
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
    this.doLayout();
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