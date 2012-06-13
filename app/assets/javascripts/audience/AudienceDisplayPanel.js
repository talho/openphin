//= require ext_extensions/PagingStore
//= require_self

Ext.ns('Ext.ux');

Ext.ux.AudienceDisplayPanel = Ext.extend(Ext.Container, {
    layout: 'hbox',
    height: 300,
    width: 600,
    layoutConfig:{ align: 'stretch', padding: '5'}, 
     
    initComponent: function(){        
        this._createGridsAndStores();

        this.items = [ this.recipientGrid, this.audienceGrid ];

        Ext.ux.AudienceDisplayPanel.superclass.initComponent.apply(this, arguments);
    },

    /**
        *  Load takes a set of data and loads its values into the two stores that this container manages
        * @param   {Object}    data             The data that will be loaded into the two stores
        * @data      {Array}      recipients     An array of recipients to load into the recipient store
        * @data      {Array}      users           An array of recipients to load into the recipient store
        * @data      {Array}      jurisdictions An array of recipients to load into the recipient store
        * @data      {Array}      roles           An array of recipients to load into the recipient store
        * @data      {Array}      groups        An array of recipients to load into the recipient store
        */
    load: function(data){
        Ext.applyIf(data, {recipients: [], users: [], jurisdictions: [], roles: [], groups: []});

        // clear the stores
        this.recipientStore.loadData(data.recipients);

        // prep the audiences, groups, and users for reading in as json
        Ext.each(data.jurisdictions, function(jurisdiction){jurisdiction.type = 'jurisdiction';});
        Ext.each(data.roles, function(role){role.type = 'role';});
        Ext.each(data.users, function(user){user.type = 'user';});
        Ext.each(data.groups, function(group){group.type = 'group';});

        this.audienceStore.loadData(data.jurisdictions);
        this.audienceStore.loadData(data.roles, true);
        this.audienceStore.loadData(data.users, true);
        this.audienceStore.loadData(data.groups, true);
        this.audienceStore.sort();
    },

    loadRecipientStoreFromAjax: function(url, params, options)
    {
        options = options || {};
        Ext.apply(params, {no_page: true});
        
        this.recipientStore = new Ext.ux.data.PagingStore({
          reader: new Ext.data.JsonReader({
            fields: ['name', 'id', 'profile_path'],
            idProperty: 'id'
          }),            
          baseParams: params,
          proxy: new Ext.data.HttpProxy({
              api:{
                  read: {url: url, method: options.method || 'POST'}
              }                
          }),
          listeners: {
            'beforeload' : function(){
              return true;
            }
          }
        });

        this.recipientGrid.reconfigure(this.recipientStore, this.recipientGrid.getColumnModel());
        this.recipientGrid.getBottomToolbar().bindStore(this.recipientStore);

        this.recipientGrid.getBottomToolbar().doRefresh();
        //this.recipientStore.load();
    },

    _createGridsAndStores: function(){
        this.audienceStore = new Ext.data.GroupingStore({
            reader: new Ext.data.JsonReader({
                idProperty:'this_will_never_be_filled_because_we_dont_want_collisions',
                fields: ['name', 'id', 'type', 'profile_path']
            }),
            groupField: 'type'
        });

        this.recipientStore = new Ext.ux.data.PagingStore({
          reader: new Ext.data.JsonReader({
            idProperty: 'id',
            fields: ['name', 'id', 'profile_path']
          })
        });

        this.recipientGrid = new Ext.grid.GridPanel({xtype: 'grid', itemId: 'recipient_grid', title: 'Recipients',
            flex: 1,
            hideHeaders: true,
            bodyCssClass: 'recipients',
            store: this.recipientStore,
            margins: '0 20 0 0',
            columns:[{header: "Name", dataIndex: 'name', id: 'name_column', renderer: function(value, metaData){ metaData.css = 'inlineLink'; return value;}}],
            autoExpandColumn: 'name_column',
            disableSelection: true,
            loadMask: true,
            bbar: new Ext.PagingToolbar({
              store: this.recipientStore,
              pageSize: 30
            }),
            listeners:{
                scope: this,
                'rowclick': function(grid, rowIndex){
                    var record = grid.getStore().getAt(rowIndex);
                    Application.fireEvent('opentab', {title: 'User Profile - ' + record.get('name'), user_id: record.get('id'), id: 'user_profile_for_' + record.get('id'), initializer: 'Talho.ShowProfile' });
                }
            }
        });

        this.audienceGrid = new Ext.grid.GridPanel({
            xtype: 'grid', itemId: 'audience_grid', title: 'Audiences',
            flex: 1,
            hideHeaders: true,
            bodyCssClass: 'audiences',
            store:  this.audienceStore,
            cm: new Ext.grid.ColumnModel({
                columns: [
                    {header: "Name", dataIndex: 'name', sortable: true, id: 'name_column', renderer: function(value, metaData, record){
                        if(record.get('type') === 'user')
                            metaData.css = 'inlineLink';
                        return value;
                    }},
                    {header: "Type", dataIndex: 'type', renderer: Ext.util.Format.capitalize, groupable: true, hidden: true}
                ],
                defaults:{
                    menuDisabled: true
                }
            }),
            sortInfo: {
                field: 'name',
                direction: 'ASC'
            },
            disableSelection: true,
            autoExpandColumn: 'name_column',
            view: new Ext.grid.GroupingView({
                groupTextTpl: '{group}s'
            }),
            listeners:{
                scope: this,
                'rowclick': function(grid, rowIndex){
                    var record = grid.getStore().getAt(rowIndex);
                    if(record.get('type') === 'user')
                        Application.fireEvent('opentab', {title: 'User Profile - ' + record.get('name'), url: record.get('profile_path'), id: 'user_profile_for_' + record.get('id') });
                }
            }
        });
    }
});