Ext.namespace('Talho');
Ext.namespace('Talho.Dashboard');

Talho.Dashboard.PortalColumn = Ext.extend(Ext.ux.PortalColumn, {
  defaultType : 'dashboardportlet',
  cls: ''
});

Ext.reg('dashboardportalcolumn', Talho.Dashboard.PortalColumn);

Talho.Dashboard.Record = Ext.data.Record.create([
  {name: 'id'},
  {name: 'name'},
  {name: 'updated_at', type: 'date'},
  {name: 'columns'},
  {name: 'config'},
  {name: 'draft'}
]);

Talho.Dashboard.DashboardStore = Ext.extend(Ext.data.JsonStore, {
  readerConfig: {
    root: 'dashboards',
    idProperty: 'id',
    fields: ['id','name',{name: 'updated_at', type: 'date'},'columns','config','draft']
  },
  autoLoad: true,
  autoSave: false,
  restful: true,
  constructor: function(config) {
    Ext.applyIf(config, this.readerConfig);
    Talho.Dashboard.DashboardStore.superclass.constructor.call(this, config);
  }
});

Talho.Dashboard.Portal = Ext.extend(Ext.ux.Portal, {
  constructor: function(config) {
    Ext.apply(this, config);
    Talho.Dashboard.Portal.superclass.constructor.call(this, config);
  },
  region: 'center',
  itemId: this.itemId,
  defaultType : 'dashboardportalcolumn', cls: '',
  adminMode: false,
  previewMode: false,
  columnCount: 3,
  listeners:{
    show: function(panel){panel.doLayout();},
    beforedrop: function(dropEvent) {
      dropEvent.panel.column = dropEvent.columnIndex;
    },
    render: function() {
      this.loadMask = new Ext.LoadMask(this.getEl(),{msg:"Loading Dashboard...", removeMask: true, store: this.viewStore});
    }
  },

  initComponent : function(config){
    this.viewStore = new Talho.Dashboard.DashboardStore({
      url: '/dashboard/' + Application.default_dashboard + '.json',
      storeId: 'dashboardViewStore',
      listeners: {
        scope: this,
        load: function(store, records, options) {
          //Ext.each(records, function(record, recordsIndex, allRecords) {
          if(records.length > 0) {
            record = records[0]
            this.items.clear();
            this.columnCount = record.data.config.length;
            this.itemId = record.data.id;
            Ext.each(record.data.config, function(item, index, allItems) {
              this.items.add(Ext.create(item));
            }, this);
          }
          //}, this);

          this.doLayout();
        },
        save: function(store, batch, data) {
          this.loadMask.hide();
          if(data.create != undefined) this.itemId = data.create[0].id
        }
      }
    });

    this.draftStore = new Talho.Dashboard.DashboardStore({
      autoLoad: false,
      storeId: 'dashboardDraftStore',
      proxy: new Ext.data.HttpProxy({
        url: '/dashboard.json',
        api: {
          read: '/dashboard.json?draft=true'
        }
      }),
      writer: new Ext.data.JsonWriter({
        encode: true,
        writeAllFields: true
      }),
      listeners: {
        scope: this,
        beforeload: function() {
          this.dashboardList.setRawValue("Loading Dashboards...");
        },
        load: function(store, records, options) {
          var record = store.getById(Application.default_dashboard);
          if(record == undefined) {
            this.dashboardList.setRawValue("");
            this.itemId = Application.default_dashboard;
            rec = new Talho.Dashboard.Record({
              id: Application.default_dashboard,
              date: undefined,
              config: undefined
            });
            rec.id = Application.default_dashboard;
            store.add(rec);
            this.items.each(function(column, columnIndex, allColumnItems) {
              column.items.each(function(portlet, portletIndex, allPortletItems) {
                portlet.itemId = undefined
              });
            });
          } else {
            this.dashboardList.setValue(record.data[this.dashboardList.displayField]);
            this.switchDashboard(record);
          }

          this.doLayout();
        },
        save: function(store, batch, data) {
          this.loadMask.hide();
          if(data.create != undefined) this.itemId = data.create[0].id
        }
      }
    });

    this.publishedStore = new Talho.Dashboard.DashboardStore({
      autoLoad: false,
      storeId: 'dashboardPublishedStore',
      url: '/dashboard.json'
    });

    this.dashboardListStore = new Talho.Dashboard.DashboardStore({
      autoLoad: false,
      storeId: 'dashboardListStore',
      url: '/dashboard/all.json',
      listeners: {
        scope: this,
        beforeload: function() {
          this.dashboardList.setRawValue("Loading Dashboards...");
        }
      }
    });

    this.dashboardList = new Ext.form.ComboBox({
      displayField: 'name',
      hiddenName: 'name',
      valueField: 'id',
      hiddenValue: 'id',
      lazyRender: true,
      store: this.dashboardListStore,
      mode: 'local',
      width: 250
    });

    this.tbar = {
      hidden: true,
      items: [{
        xtype: 'buttongroup',
        items: [{
          text: 'New',
          scope: this,
          handler: function() {
            this.resetDashboardPage();
            //this.viewStore.removeAll(true);
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
              this.items.first().add(new Talho.Dashboard.Portlet.HTML({html: '&nbsp;', headerCssClass: undefined, border: true, column: 0}));
              this.doLayout();
            }
          }]
        }]
      },{
        xtype: 'buttongroup',
        items: [{
          text: 'Delete Dashboard',
          scope: this,
          handler: function() {
            Ext.Msg.confirm("Warning","Are you sure you want to delete this dashboard and all its contents?", function(btn) {
              if(btn == 'yes') {
                if(this.itemId) {
                  this.loadMask = new Ext.LoadMask(this.getEl(), {msg: "Deleting...", store: this.draftStore});
                  this.loadMask.show();
                  var rec = this.draftStore.getById(this.itemId);
                  this.draftStore.remove(rec);
                  this.draftStore.save();
                }
                this.resetDashboardPage();
              }
            }, this);
          }
        }]
      },this.dashboardList]
    };

    this.bbar = {
      items: [{
        text: "Admin Mode",
        scope: this,
        handler: function(b, e) {
          var toggleBBar = function() {
            var text = this.adminMode ? "Admin Mode" : "User Mode";
            b.setText(text);
            this.toggleAdmin();

            this.getBottomToolbar().items.each(function(item, index, allItems) {
              if(item != b) item.setVisible(!item.isVisible());
            });
          }.createDelegate(this);

          var revertItems = function() {
            this.items.each(function(column, columnIndex, allColumnItems) {
              column.items.each(function(portlet, portletIndex, allPortletItems) {
                if(portlet.isModified()) {
                  if(portlet.itemId == undefined) {
                    column.remove(portlet);
                  }
                  if(!portlet.revert()) return false;
                }
              }, this);
            }, this);
            return true;
          }.createDelegate(this);

          if(this.adminMode) {
            this.items.each(function(item, index, allItems) {
              if(item.items.length == 0) toggleBBar();
              
              item.items.each(function(portlet, index, allItems) {
                if(portlet.isModified()) {
                  Ext.Msg.confirm("Warning","The contents have changed and not been published.  Any changes you have made will be lost.  Are you sure you want to continue?", function(btn) {
                    if(btn == 'yes') {
                      if(!revertItems()) {
                        Ext.Msg.alert("Error", "Could not revert one or more controls.  Please refresh your browser to correct this error, but doing so will cause you to lose any changes you have made.");
                        return;
                      };
                      toggleBBar();
                      this.doLayout();
                    }
                  }, this);
                } else {
                  toggleBBar();
                }
              }, this);
            }, this);
          } else {
            toggleBBar();
          }
        }
      },{
        xtype: 'tbseparator',
        hidden: true
      },{
        text: 'Preview',
        hidden: true,
        scope: this,
        handler: function(b, e) {
          this.previewMode = !this.previewMode;
          var text = this.previewMode ? "Edit" : "Preview";
          b.setText(text);
          this.toggleAdminBorder(this);
        }
      },{
        xtype: 'tbseparator',
        hidden: true
      },{
        text: 'Published',
        hidden: true
      },{
        xtype: 'tbfill',
        hidden: true
      },{
        text: 'Save',
        hidden: true,
        scope: this,
        handler: function(b, e) {
          this.loadMask = new Ext.LoadMask(this.getEl(), {msg: "Saving...", store: this.draftStore});
          this.loadMask.show();
          this.save(true);
        }
      },{
        xtype: 'tbseparator',
        hidden: true
      },{
        text: 'Save and Publish',
        hidden: true,
        scope: this,
        handler: function(b, e) {
          Ext.Msg.confirm("Warning", "Clicking Save and Publish will make all changes active in production.  Are you sure you want to publish these changes?", function(btn) {
            if(btn == 'yes') {
              this.loadMask = new Ext.LoadMask(this.getEl(), {msg: "Saving and Publishing...", store: this.draftStore});
              this.loadMask.show();
              this.save(false);
            }
          }, this);
        }
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

  toggleAdminBorder: function(obj) {
    obj.items.each(function(item, index, allItems) {
      item.items.each(function(item, index, allItems) {
        item.el.toggleClass('x-panel-noborder');
        item.el.child('.x-panel-header').toggleClass('x-hide-display');
        var panel = item.el.child('.x-panel-body');
        var width = (item.el.getStyle('width') == panel.getStyle('width') ? -2 : 0)
        item.el.child('.x-panel-body').setStyle('width', (item.el.getWidth() + width));
        item.el.child('.x-panel-body').toggleClass('x-panel-body-noborder');
      });
    });
  },

  toggleAdmin: function() {
    this.getTopToolbar().setVisible(!this.getTopToolbar().isVisible());
    if(!this.previewMode) this.toggleAdminBorder(this);
    this.adminMode = !this.adminMode;
    this.loadMask = new Ext.LoadMask(this.getEl(),{msg:"Loading Dashboard...", removeMask: true, store: this.adminMode ? this.draftStore : this.viewStore});
    if(!this.adminMode) this.previewMode = false;
    if(this.dashboardList.getStore().data.length == 0) this.dashboardList.getStore().load();
    if(this.draftStore.data.length == 0) this.draftStore.load();
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
  },

  resetDashboardPage: function() {
    this.items.each(function(item, index, allItems) {
      item.removeAll(true);
    });
    this.removeAll(true);
    this.items.add(new Talho.Dashboard.PortalColumn({columnWidth: .33, style:'padding:10px', items: []}));
    this.items.add(new Talho.Dashboard.PortalColumn({columnWidth: .33, style:'padding:10px', items: []}));
    this.items.add(new Talho.Dashboard.PortalColumn({columnWidth: .33, style:'padding:10px', items: []}));
    this.columnCount = 3;
    this.itemId = undefined;
    this.doLayout();
  },

  save: function(draft) {
    var rec = undefined;

    if(this.itemId == undefined) {
      rec = new Talho.Dashboard.Record({
        id: undefined,
        date: undefined,
        config: undefined
      });
    } else {
      rec = this.draftStore.getById(this.itemId);
    }

    if(rec == undefined) Ext.Msg.alert("Error saving dashboard.");

    var config = this.buildConfig();
    if(rec.data.id != undefined && this.compareProperties(rec.data.config, config)) return;

    rec.beginEdit();
    rec.data.config = config;
    rec.data.draft = draft;
    rec.data.columns = this.columnCount;
    rec.markDirty();
    rec.endEdit();
    if(rec.data.id == undefined) this.draftStore.add(rec);
    var i = this.draftStore.save();
  },

  buildConfig: function() {
    var config = [];
    this.items.each(function(column, columnIndex, allColumnItems) {
      var item = {columnWidth: column.columnWidth, style: 'padding:10px 0 10px 10px', xtype: 'dashboardportalcolumn', items: []}
      column.items.each(function(portlet, portletIndex, allPortletItems) {
        item.items.push(portlet.buildConfig());
      });
      config.push(item);
    });
    return config;
  },

  compareProperties: function(config1, config2) {
    if(config1 == undefined || config1.length != config2.length) return false;

    for(var i = 0; i < config1.length; i++) {
      for(var propertyName in config1[i]) {
        if(propertyName != "remove" && propertyName != "__proto__") {
          if(propertyName == "items") {
            if(!this.compareProperties(config1[i].items, config2[i].items)) return false;
          } else {
            if(config1[i][propertyName] != config2[i][propertyName]) return false;
          }
        }
      }
    }

    return true;
  },

  switchDashboard: function(record) {
    if(record.data.draft == "true") {
      this.items.each(function(item, index, allItems) {
        item.removeAll(true);
      });
      this.removeAll(true);
      Ext.each(record.data.config, function(item, index, allItems) {
        this.items.add(Ext.create(item));
      }, this);
      this.columnCount = record.data.columns;
      this.doLayout();
      this.toggleAdminBorder(this);
    }
  }
});