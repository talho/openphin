Ext.ns("Talho");

Talho.Invitations = Ext.extend(function(){}, {
  constructor: function(config){
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
              if(currentInvitationId != store.getAt(rowIndex).data['id']) {
                currentInvitationId = store.getAt(rowIndex).data['id'];
                header.setText('Invitation: ' + store.getAt(rowIndex).data['name']);
                newstore = new Ext.data.JsonStore({
                  autoDestroy: true,
                  autoLoad: {params:{start: 0, limit: 20}},
                  remoteSort: true,
                  proxy: new Ext.data.HttpProxy({
                    url: '/admin_invitations/' + currentInvitationId + '.json',
                    method: 'GET'
                  }),
                  root: 'invitees',
                  fields: ['name','email','completion_status','organization_membership','profile_updated','pending_requests']
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
      frame: true,
      title: 'Invitations',
      iconCls: 'icon-grid'
    }];

    var header = new Ext.form.Label({
      text: '',
      style: {
        fontWeight: 'bold',
        fontSize: '14'
      }
    });

    var invitationStore = new Ext.data.ArrayStore({
      autoDestroy: true,
      fields: ['name','email','completion_status','organization_membership','profile_updated','pending_requests'],
      totalProperty: 'totalCount',
      remoteSort: true
    });

    var currentInvitationId = 0;

    var invitationToolbar = new Ext.PagingToolbar({
        pageSize: 20,
        store: invitationStore,
        displayInfo: true,
        displayMsg: 'Displaying invitees {0} - {1} of {2}',
        emptyMsg: 'No invitees to display'
      });

    var invitationGrid = new Ext.grid.GridPanel({
      width: 700,
      height: 500,
      store: invitationStore,
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
          dataIndex: 'completion_status'
        },{
          header: 'Organization Membership',
          dataIndex: 'organization_membership'
        },{
          header: 'Profile Updated',
          dataIndex: 'profile_updated'
        },{
          header: 'Pending Role Requests',
          dataIndex: 'pending_requests',
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
                      success: function() {
                        el4 = this.nextSibling();
                        el2 = this.previousSibling();
                        el1 = el2.previousSibling();
                        owner = this.ownerCt;
                        el4.destroy();
                        el2.destroy();
                        el1.destroy();
                        this.destroy();
                        owner.doLayout();
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
                      success: function() {
                        el3 = this.previousSibling();
                        el2 = el3.previousSibling();
                        el1 = el2.previousSibling();
                        owner = this.ownerCt;
                        this.destroy();
                        el3.destroy();
                        el2.destroy();
                        el1.destroy();
                        owner.doLayout();
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
                items: i,
                listeners: {
                  scope: this,
                  close: function(e) {
                    invitationStore.reload();
                  }
                }
              });
              win.show(invitationGrid);
            }
          }
        }]
      }),
      bbar: invitationToolbar
    });

    var content = new Ext.Container({
      defaults:{padding:'10'},
      hidden: true,
      items: [{
        xtype: 'container',
        layout: 'hbox',
        layoutConfig: {
          align: 'middle',
          pack: 'center'
        },
        items: [header]
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
      layoutConfig: {defaultMargins:'10',pack:'center'},
      region: 'west',
      width: 240,
      autoScroll: true,
      items: item_list
    });

    var centerPanel = new Ext.Panel({
      layout: 'fit',
      region: 'center',
      items: panel_items
    })

    var panel = new Ext.Panel({
      layout: 'border',
      title: 'View Invitations',
      items: [centerPanel, sidePanel],
      closeable: true
    });

    this.getPanel = function(){ return panel; }
    this.getCenterPanel = function(){ return centerPanel;}
    this.getSidePanel = function(){ return sidePanel;}
    
    Talho.Invitations.superclass.constructor.call(this, config);
  }
});

Talho.Invitations.initialize = function(config) {
  var o = new Talho.Invitations(config);
  return o.getPanel();
};

Talho.ScriptManager.reg('Talho.Invitations', Talho.Invitations, Talho.Invitations.initialize);
