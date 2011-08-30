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
  {name: 'draft'},
  {name: 'audiences_attributes'}
]);

Talho.Dashboard.DashboardStore = Ext.extend(Ext.data.JsonStore, {
  readerConfig: {
    root: 'dashboards',
    idProperty: 'id',
    fields: ['id','name',{name: 'updated_at', type: 'date'},'columns','config','draft','audiences_attributes']
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
  name: "",
  adminMode: false,
  previewMode: false,
  columnCount: 3,
  audiences_attributes: null,  
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
        beforeload: function() {
          return Application.default_dashboard != undefined;
        },
        load: function(store, records, options) {
          //Ext.each(records, function(record, recordsIndex, allRecords) {
          if(records.length > 0) {
            record = records[0]
            this.items.clear();
            this.columnCount = record.data.config.length;
            Ext.ComponentMgr.get('columnToggle').setText(this.columnCount + " column");
            this.itemId = record.data.id;
            if(record.data.audiences_attributes.length > 0)
              this.audiences = record.data.audiences_attributes;
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
            this.itemId = Application.default_dashboard || undefined;
            record = new Talho.Dashboard.Record({
              id: Application.default_dashboard || undefined,
              name: "",
              updated_at: undefined,
              columns: undefined,
              config: undefined,
              draft: true,
              audiences_attributes: undefined
            });
            record.id = Application.default_dashboard;
            Ext.each(this.viewStore.data.items, function(item, index, allItems) {
              if(item.id == Application.default_dashboard) {
                record.name = item.data.name;
                this.name = record.name;
              }
            }, this);
            //store.add(rec);
            this.items.each(function(column, columnIndex, allColumnItems) {
              column.items.each(function(portlet, portletIndex, allPortletItems) {
                portlet.itemId = undefined
              });
            });
          } else {
            this.dashboardList.setValue(record.data[this.dashboardList.displayField]);
            this.switchDashboard(record, "true");
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
        },
        load: function() {
          if(Application.default_dashboard != undefined) {
            this.dashboardList.setValue(Application.default_dashboard);
          }
        }
      }
    });

    this.dashboardList = new Ext.form.ComboBox({
      id: 'dashboardlist',
      displayField: 'name',
      editable: false,
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
        title: 'Dashboard',
        items: [{
          text: 'New',
          scope: this,
          handler: function() {
            this.resetDashboardPage();
            //this.viewStore.removeAll(true);
          }
        },{
          xtype: 'container',
          width: 250,
          items: this.dashboardList
        },{
          text: 'Delete',
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
      },{
        xtype: 'buttongroup',
        title: 'Content',
        items: [{
          text: '3 column',
          id: 'columnToggle',
          scope: this,
          handler: function(b, e) {
            if(this.columnCount == 3) {
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
              b.setText("2 column");
              this.columnCount = 2;
            } else {
              this.items.each(function(item, index, allItems) {
                item.columnWidth = .33;
              });
              this.items.add(new Talho.Dashboard.PortalColumn({columnWidth:.33, style:'padding:10px', items: []}));
              this.doLayout();
              this.columnCount = 3;
              b.setText("3 column");
            }
          }
        },{
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
        title: 'Permissions',
        items: [{
          text: 'Edit',
          width: 75,
          scope: this,
          handler: function() {
            var audiencePanel = new Ext.ux.AudiencePanel({
              id:'portlet_audience-' + this.id,
              width: 550,
              height: 400,
              showJurisdictions: false,
              showRoles: false,
              showGroups: true
            });
            if(this.audiences != null && this.audiences.length > 0) {
              audiencePanel.load(this.audiences[0].audience.jurisdictions, this.audiences[0].audience.roles, this.audiences[0].audience.users, this.audiences[0].audience.groups);
            }
            
            var window = new Ext.Window({
              layout: 'fit',
              title: 'Edit Porlet Audience',
              constrain: true,
              style: {
                opacity: 100
              },
              headerCfg: {
                style: {
                  valign: 'middle',
                  padding: 3,
                  opacity: 100
                }
              },
              items: [audiencePanel],
              buttons: ['->',{
                text: 'OK',
                scope: this,
                handler: function() {
                  if(this.audiences_attributes == null) this.audiences_attributes = [];
                  if(this.audiences_attributes.length == 0) this.audiences_attributes.push({audience: null});
                  this.audiences_attributes[0].audience = audiencePanel.getSelectedItems();
                  this.audiences[0].audience.groups = this.audiences_attributes[0].audience.groups;
                  this.audiences[0].audience.jurisdictions = this.audiences_attributes[0].audience.jurisdictions;
                  this.audiences[0].audience.roles = this.audiences_attributes[0].audience.roles;
                  this.audiences[0].audience.users = this.audiences_attributes[0].audience.users;
                  window.close();
                }
              },{
                text: 'Cancel',
                handler: function() {
                  window.close();
                }
              }],
              tools: [{
                id:'help'
              }]
            });
            window.show();
          }
        }]
      }]
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
        text: 'Published',
        hidden: true,
        scope: this,
        handler: function(b, e) {
          Ext.Msg.confirm("Warning","This will revert the draft portlets back to what is currently published.  Any changes you have made will be lost.  Are you sure you want to continue?", function(btn) {
            if(btn == 'yes') {
              var record = this.publishedStore.getById(this.itemId);
              this.switchDashboard(record, "false");
            }
          }, this);
        }
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
          if(this.getPortlets().length == 0) {
            Ext.Msg.alert("Warning", "You must have at least one portlet added to save this dashboard.")
          } else {
            var opt = {
              title: "Warning",
              msg: "Clicking Save and Publish will make all changes active in production.  Are you sure you want to publish these changes?",
              prompt: false,
              scope: this,
              buttons: Ext.Msg.YESNO,
              fn: function(btn, text, opt) {
                if(btn == 'yes') {
                  if((this.name == undefined || $.trim(this.name) == "") && $.trim(text) == "") {
                    Ext.Msg.show(opt);
                  } else {
                    this.name = $.trim(text);
                    this.loadMask = new Ext.LoadMask(this.getEl(), {msg: "Saving and Publishing...", store: this.draftStore});
                    this.loadMask.show();
                    this.save(false);
                  }
                }
              }
            };
            if(this.name == undefined || $.trim(this.name) == "") {
              opt.msg = "Clicking Save and Publish will make all changes active in production.  Are you sure you want to publish these changes?<br/><br/>You must enter a name for this dashboard before continuing:";
              opt.prompt = true;
            }
            Ext.Msg.show(opt);
          }
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
      callback: function(obj, success, response) {
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
    if(this.publishedStore.data.length == 0) this.publishedStore.load();
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
    this.name = undefined;
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
        name: undefined,
        updated_at: undefined,
        columns: undefined,
        config: undefined,
        draft: undefined,
        audiences_attributes: undefined
      });
    } else {
      rec = this.draftStore.getById(this.itemId);
    }

    if(rec == undefined) Ext.Msg.alert("Error saving dashboard.");

    var config = this.buildConfig();
    if(rec.data.id != undefined && this.compareProperties(rec.data.config, config)) return;

    rec.beginEdit();
    if(this.audiences_attributes == null) {
      rec.data.audiences_attributes = null;
    } else {
      var audience = this.audienceAsNestedAttributes();
      audience['id'] = this.audiences[0].audience.id;
      rec.data.audiences_attributes = [audience];
    }
    rec.data.name = this.name;
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

  switchDashboard: function(record, draft) {
    if(String(record.data.draft) == draft) {
      this.items.each(function(item, index, allItems) {
        item.removeAll(true);
      });
      this.removeAll(true);
      Ext.each(record.data.config, function(item, index, allItems) {
        this.items.add(Ext.create(item));
      }, this);
      this.name = record.data.name;
      this.columnCount = record.data.columns;
      this.doLayout();
      this.toggleAdminBorder(this);
    }
  },

  audienceAsNestedAttributes: function() {
    var audience = {jurisdiction_ids: [], role_ids: [], user_ids: [], group_ids: []}
    Ext.each(this.audiences_attributes[0].audience.jurisdictions, function(item, index, allItems) {
      audience.jurisdiction_ids.push(item.id)
    });
    Ext.each(this.audiences_attributes[0].audience.roles, function(item, index, allItems) {
      audience.role_ids.push(item.id)
    });
    Ext.each(this.audiences_attributes[0].audience.users, function(item, index, allItems) {
      audience.user_ids.push(item.id)
    });
    Ext.each(this.audiences_attributes[0].audience.groups, function(item, index, allItems) {
      audience.group_ids.push(item.id)
    });
    return audience;
  },

  getPortlets: function() {
    var portlets = [];
    this.items.each(function(item, index, allItems) {
      portlets = portlets.concat(item.items.items);
    });
    return portlets;
  }
});