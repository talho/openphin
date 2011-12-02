Ext.ns("Talho");

Talho.Invitations = Ext.extend(function(){}, {
  constructor: function(config){

    this.recipesStore = new Ext.data.JsonStore({
      url: '/admin_invitations/recipe_types.json',
      restful: true,
      root: 'recipes',
      fields: ['name_humanized','id'],
      autoLoad: true,
      autoSave: false
    });

    var store = new Ext.data.JsonStore({
      autoDestroy: true,
      autoLoad: true,
      url: '/admin_invitations.json',
      root: 'invitations',
      idProperty: 'id',
      fields: ['id','name']
    });
    
    var item_list = [{
      xtype: 'grid',
      store: store,
      hideHeaders: true,
      viewConfig: {
        autoFill: true
      },
      loadMask: true,
      colModel: new Ext.grid.ColumnModel({
        menuDisabled: true,
        columns: [{
          header: 'Invitation Name',
          sortable: true,
          resizable: false,
          dataIndex: 'name',
          listeners: {
            scope: this,
            click: function(column, grid, rowIndex, e) {
              if(this.currentInvitationId != store.getAt(rowIndex).data['id']) {
                this.currentInvitationId = store.getAt(rowIndex).data['id'];
                header.setText(store.getAt(rowIndex).data['name']);
                newstore = new Ext.data.JsonStore({
                  autoDestroy: true,
                  autoLoad: {params:{start: 0, limit: 20}},
                  remoteSort: true,
                  proxy: new Ext.data.HttpProxy({
                    url: '/admin_invitations/' + this.currentInvitationId + '.json',
                    method: 'GET'
                  }),
                  root: 'invitees',
                  fields: ['name','email','completionStatus','organizationMembership','profileUpdated','pendingRequests'],
                  listeners: {
                    load: function() {
                      bodyContainer = content.getComponent('invitationBodyContainer');
                      if(bodyContainer.items.items.length == 0) {
                        subjectContainer = content.getComponent('invitationSubjectContainer');
                        subject = subjectContainer.getComponent('invitationSubject');
                        subject.update("<b>Subject:</b>&nbsp;" + newstore.reader.jsonData["invitation"]["subject"]);

                        organizationContainer = content.getComponent('invitationOrganizationContainer');
                        organization = organizationContainer.getComponent('invitationOrganization');
                        org = newstore.reader.jsonData["invitation"]["organization"];
                        if(org) organization.update("<b>Default Organization:</b>&nbsp;" + org);
                        
                        bodyContainer.add(new Ext.form.DisplayField({width: 550, html: newstore.reader.jsonData["invitation"]["body"]}));

                        complete_percentage = newstore.reader.jsonData["invitation"]["complete_percentage"];
                        complete_total = newstore.reader.jsonData["invitation"]["complete_total"];
                        incomplete_percentage = newstore.reader.jsonData["invitation"]["incomplete_percentage"];
                        incomplete_total = newstore.reader.jsonData["invitation"]["incomplete_total"];

                        invitationTopToolbar.add({xtype: 'box', style: 'color: white;', html: "<b>Registrations complete:</b>&nbsp;" + complete_percentage + "% (" + complete_total + ")"});
                        invitationTopToolbar.add({xtype: 'tbfill'});
                        invitationTopToolbar.add({xtype: 'box', style: 'color: white;', html: "<b>Registrations incomplete:</b>&nbsp;" + incomplete_percentage + "% (" + incomplete_total + ")"});
                        invitationTopToolbar.doLayout();
                        centerPanel.doLayout();
                      }
                      return true;
                    }
                  }
                });
                invitationGrid.reconfigure(newstore,invitationGrid.colModel);
                invitationToolbar.bind(newstore);
                invitationStore = newstore;
                content.show();
              }
            }
          }
        }]
      }),
      //sm: new Ext.grid.CellSelectionModel(),
      //frame: true,
      title: 'Invitations',
      iconCls: 'icon-grid'
    }];

    var header = new Ext.form.Label({
      text: '',
      style: {
        fontWeight: 'bold',
        fontSize: '150%'
      }
    });

    var invitationStore = new Ext.data.ArrayStore({
      autoDestroy: true,
      fields: ['name','email','completionStatus','organizationMembership','profileUpdated','pendingRequests'],
      totalProperty: 'totalCount',
      remoteSort: true
    });

    this.currentInvitationId = 0;

    var invitationToolbar = new Ext.PagingToolbar({
      pageSize: 20,
      store: invitationStore,
      displayInfo: true,
      displayMsg: 'Displaying invitees {0} - {1} of {2}',
      emptyMsg: 'No invitees to display'
    });

    var invitationTopToolbar = new Ext.Toolbar();

    var invitationGrid = new Ext.grid.GridPanel({
      width: 700,
      height: 500,
      store: invitationStore,
      id: 'invitationGrid',
      viewConfig: {
        autoFill: true
      },
      trackMouseOver: false,
      disableSelection: true,
      loadMask: true,
      colModel: new Ext.grid.ColumnModel({
        defaults: {
          sortable: true
        },
        columns: [{
          header: 'Name',
          dataIndex: 'name'
        },{
          header: 'Email',
          dataIndex: 'email'
        },{
          header: 'Completion Status',
          dataIndex: 'completionStatus'
        },{
          header: 'Organization Membership',
          dataIndex: 'organizationMembership'
        },{
          header: 'Profile Updated',
          dataIndex: 'profileUpdated'
        },{
          header: 'Pending Role Requests',
          dataIndex: 'pendingRequests',
          renderer: function(value, metaData, record, rowIndex, colIndex, store) {
            return value.length > 0 ? 'Click here to see<br/>pending role requests' : ''
          },
          listeners: {
            click: function(column, grid, rowIndex, e){
              if(grid.store.getAt(rowIndex).data['pending_requests'].length == 0) return;
              var i = [{
                html: 'Role'
              },{
                html: 'Jurisdiction'
              },{
                html: 'Approve'
              },{
                html: 'Deny'
              }];

              updateGridOnTableRemoval = function(storeItems, responseResults) {
                Ext.each(storeItems,function(storeItem, storeIndex, storeAllItems) {
                  if(storeItem.data['email'] == responseResults['email']) {
                    if(storeItem.data['pending_requests'].length > 0) {
                      Ext.each(storeItem.data['pending_requests'], function(item, index, allItems) {
                        if(item['jurisdiction'] == responseResults['jurisdiction'] && item['role'] == responseResults['role']) {
                          storeItem.data['pending_requests'].remove(item);
                          return false;
                        }
                      });
                    }
                  }
                });
                Ext.getCmp('invitationGrid').getView().refresh();
              };

              Ext.each(grid.store.getAt(rowIndex).data['pending_requests'], function() {
                i.push({html: this['role']});
                i.push({html: this['jurisdiction']});
                var c = {
                  xtype: 'button',
                  text: 'Approve',
                  scope: this,
                  handler: function(b, e) {
                    Ext.Ajax.request({
                      url: this['approve_url'],
                      scope: b,
                      success: function(response, opts) {
                        owner = this.ownerCt;

                        td3 = this.el.parent();
                        td4 = this.nextSibling().el.parent();
                        td2 = this.previousSibling().el.parent();
                        td1 = this.previousSibling().previousSibling().el.parent();
                        tr1 = td3.parent();

                        ind = owner.items.indexOf(this);
                        var i = ind - (ind % 4) - 1;
                        for(var x = i + 4; x > i; x--) {
                          owner.items.items[x].destroy();
                        }

                        td4.remove();
                        td3.remove();
                        td2.remove();
                        td1.remove();
                        tr1.remove();

                        owner.layout.currentRow -= 1;
                        storeItems = Ext.getCmp('invitationGrid').store.data.items;
                        responseResults = Ext.decode(response.responseText);
                        updateGridOnTableRemoval(storeItems, responseResults);
                      },
                      failure: function() {
                        Ext.Msg.alert('Error', 'Error when attempting to approve role request.')
                      }
                    });
                  }
                };
                i.push(c);
                c = {
                  xtype: 'button',
                  text: 'Deny',
                  scope: this,
                  handler: function(b, e) {
                    Ext.Ajax.request({
                      url: this['deny_url'],
                      scope: b,
                      success: function(response, opts) {
                        owner = this.ownerCt;

                        td4 = this.el.parent();
                        td3 = this.previousSibling().el.parent();
                        td2 = this.previousSibling().previousSibling().el.parent();
                        td1 = this.previousSibling().previousSibling().previousSibling().el.parent();
                        tr1 = td4.parent();

                        ind = owner.items.indexOf(this);
                        var i = ind - (ind % 4) - 1;
                        for(var x = i + 4; x > i; x--) {
                          owner.items.items[x].destroy();
                        }

                        td4.remove();
                        td3.remove();
                        td2.remove();
                        td1.remove();
                        tr1.remove();

                        owner.layout.currentRow -= 1;
                        storeItems = Ext.getCmp('invitationGrid').store.data.items;
                        responseResults = Ext.decode(response.responseText);
                        updateGridOnTableRemoval(storeItems, responseResults);
                      },
                      failure: function() {
                        Ext.Msg.alert('Error', 'Error when attempting to deny role request.')
                      }
                    });
                  }
                };
                i.push(c);
              });

              win = new Ext.Window({
                layout: 'table',
                layoutConfig: {
                  columns: 4
                },
                width: 300,
                height: 200,
                closeAction: 'close',
                constrain: true,
                modal: true,
                title: 'Pending Role Requests',
                items: i
              });
              win.show(invitationGrid);
            }
          }
        }]
      }),
      tbar: invitationTopToolbar,
      bbar: invitationToolbar
    });

    var content = new Ext.Container({
      style: 'padding:10px; ',
      hidden: true,
      items: [{
        xtype: 'container',
        layout: 'hbox',
        layoutConfig: {
          align: 'middle',
          pack: 'center'
        },
        items: [
          header,
          {xtype: 'button', text:'Generate Report', style: 'padding-left:10px', scope: this, handler: function(){this.generate_report();}}
        ]
      },{
        xtype: 'box',
        html: '<br/>'
      },{
        xtype: 'container',
        layout: 'hbox',
        layoutConfig: {
          align: 'middle',
          pack: 'center'
        },
        itemId: 'invitationSubjectContainer',
        items: [{
          xtype: 'box',
          itemId: 'invitationSubject'
        }]
      },{
        xtype: 'box',
        html: '<br/>'
      },{
        xtype: 'container',
        layout: 'hbox',
        layoutConfig: {
          align: 'middle',
          pack: 'center'
        },
        itemId: 'invitationOrganizationContainer',
        items: [{
          xtype: 'box',
          itemId: 'invitationOrganization'
        }]
      },{
        xtype: 'box',
        html: '<br/>'
      },{
        xtype: 'container',
        layout: 'hbox',
        layoutConfig: {
          align: 'middle',
          pack: 'center'
        },
        itemId: 'invitationBodyContainer'
      },{
        xtype: 'box',
        html: '<br/>'
      },{
        xtype: 'container',
        layout: 'hbox',
        layoutConfig: {
          align: 'middle',
          pack: 'center'
        },
        items: [invitationGrid]
      }]
    });

    var panel_items = [
      {xtype: 'box', id: 'flashBox', html: '<p class="flash">&nbsp;</p>', hidden: true},
      content
    ];

    var sidePanel = new Ext.Panel({
      layout: 'fit',
      region: 'west',
      width: 240,
      margins: '5 5 5 5',
      autoScroll: true,
      items: item_list
    });

    var centerPanel = new Ext.Panel({
      layout: 'fit',
      region: 'center',
      margins: '5 5 5 0',
      autoScroll: true,
      items: panel_items
    });

    var panel = new Ext.Panel({
      layout: 'border',
      title: 'View Invitations',
      itemId: config.id,
      items: [centerPanel, sidePanel],
      closable: true
    });

    this.getPanel = function(){ return panel };
    this.getCenterPanel = function(){ return centerPanel};
    this.getSidePanel = function(){ return sidePanel};
    
    Talho.Invitations.superclass.constructor.call(this, config);
  },

  generate_report: function(){
    var win = new Ext.Window({
      title: "Generate Report",
      layout: 'form',
      labelAlign: 'top',
      padding: '10',
      width: 450,
      modal: true,
      items: [
          {xtype: 'combo', itemId:'recipeSelection', fieldLabel: 'Report Recipe', name: 'recipe[id]', editable: false, value: 'Select...', anchor: '100%',
            triggerAction: 'all', store: this.recipesStore, displayField: 'name_humanized', valueField: 'id', mode: 'local'},
          {xtype: 'displayfield', itemId: 'recipeDisplay', value: '', name: 'report_name'}
      ],
      buttons: [
        {text: 'Generate', itemId: 'generate', scope: this, width:'auto', disabled: true, handler: function(){ this.request_report(win); }},
        {text: 'Cancel', itemId: 'cancel', scope: this, width:'auto', handler: function(){ win.close(); } }
      ]
    });
    win.show();
    win.getComponent('recipeSelection').on('select', function(view,nodes){
      if (win.getComponent('recipeSelection').selectedIndex > -1) {
        win.getFooterToolbar().getComponent('generate').enable();
      }
    })
  },

  request_report: function(win){
    var recipe_id = win.getComponent('recipeSelection').getValue();
    var criteria = {'recipe': recipe_id, 'model': 'Invitation', 'method': 'find_by_id', 'params': this.currentInvitationId};
    Ext.Ajax.request({
      url: '/report/reports.json',
      method: 'POST',
      params: Ext.encode({'criteria': criteria}),
      headers: {"Content-Type":"application/json","Accept":"application/json"},
      scope:  this,
      success: function(responseObj, options){
        var footer = win.getFooterToolbar();
        footer.getComponent('generate').hide();
        footer.getComponent('cancel').setText('OK');
        var response = Ext.decode(responseObj.responseText);
        win.getComponent('recipeDisplay').setValue(this.report_msg(response.report['name']));
      },
      failure: function(responseObj){
        var response = Ext.decode(responseObj.responseText);
        win.getComponent('recipeDisplay').setValue(this.ajax_err_cb(response));
      }
    });
  },

  report_msg: function(report_name, opts) {
    return '<br><b>Report: ' + report_name + '</b><br><br>' +
      '<div style="height:80px;">' + 'has been scheduled. Please check the Reports panel or your email for status.' + '<\div>';
  },

  ajax_err_cb: function(response, opts) {
    return '<b>Status: ' + response.status + ' => ' + response.statusText + '</b><br><br>' +
      '<div style="height:400px;overflow:scroll;">' + response.responseText + '<\div>';
  },

});

Talho.Invitations.initialize = function(config) {
  var o = new Talho.Invitations(config);
  return o.getPanel();
};

Talho.ScriptManager.reg('Talho.Invitations', Talho.Invitations, Talho.Invitations.initialize);
