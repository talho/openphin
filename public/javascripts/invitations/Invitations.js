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
                  fields: ['name','email','completion_status','organization_membership','profile_updated']
                });
                invitationGrid.reconfigure(newstore,invitationGrid.colModel);
                invitationToolbar.bind(newstore);
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
      fields: ['name','email','completion_status','organization_membership'],
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
      width: 600,
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
