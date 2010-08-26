
Ext.ns('Talho');

Talho.ManageGroups = Ext.extend(Ext.util.Observable, {
    constructor: function(config){

        Ext.apply(this, config);

        Talho.ManageGroups.superclass.constructor.call(this, config);

        this.primary_panel = new Ext.Panel({
            layout:'card',
            itemId: config.id,
            layoutOnCardChange: true,
            items: [this._getGroupView(), this._getCreateView(),
                this._getGroupDetailView()],
            activeItem: 0,
            closable: true,
            defaults:{
                border:false
            },
            title: "Manage Groups"
        });

        this.primary_panel.canGoBack = this.canGoBack.createDelegate(this);
        this.primary_panel.canGoForward = this.canGoForward.createDelegate(this);
        this.primary_panel.back = this.back.createDelegate(this);
        this.primary_panel.forward = this.forward.createDelegate(this);
        
        this.primary_panel.addEvents('afternavigation');

        this.getPanel = function(){ return this.primary_panel; }
    },

    _getGroupView: function(){
        var store = new Ext.data.JsonStore({
            restful: true,
            url: '/admin_groups.json',
            root: 'groups',
            idProperty: 'id',
            remoteSort: 'true',
            totalProperty: 'count',
            fields:['name', 'scope', {name: "owner", mapping: "owner.display_name"}, {name: "owner_id", mapping: "owner.id"}]
        });

        var rowActions = new Ext.ux.grid.RowActions({
           actions: [{iconCls: 'editBtn', qtip: 'edit'}, {iconCls: 'removeBtn', qtip: 'delete'}]
        });

        this.group_list = new Ext.grid.GridPanel({
            store: store,
            border: false,
            width: 500,
            height: 300,
            columns: [
                {header: 'Name', id: 'name_column', dataIndex: 'name'},
                {header: 'Owner', dataIndex: 'owner'},
                {header: 'Scope', dataIndex: 'scope'},
                    rowActions

            ],
            sm: false,
            autoExpandColumn: 'name_column',
            loadMask: true,
            plugins: [rowActions],
            listeners:{
                scope: this,
                'cellclick': function(grid, row, column, e){
                    var fieldName = grid.getColumnModel().getDataIndex(column); // Get field name
                    if(fieldName === 'name')
                    {
                        var record = grid.getStore().getAt(row);  // Get the Record
                        this.showGroupDetail(record.id);
                    }
                }
            }
        });

        this.group_display_panel = new Ext.Panel({
            layout:'vbox',
            layoutConfig: {
                padding: '30 0',
                align: 'center'
            },
            autoScroll: true,
            defaults:{border:false},
            items:[
                    {xtype:'button', text:'Create New Group', handler: this.showNewGroup, scope: this},
                    {xtype:'panel', border:true, items:[this.group_list]},
                    {xtype:'button', text:'Create New Group', handler: this.showNewGroup, scope: this}
                ],
            listeners:{
                'show': function(){ this.group_list.getStore().load(); },
                scope:this
            }
        });

        return this.group_display_panel;
    },

    _getCreateView: function(){

        var jurisdiction_store = new Ext.data.JsonStore({
            restful: true,
            url: '/jurisdictions/user_alerting',
            idProperty: 'jurisdiction.id',
            fields: [{name: 'name', mapping: 'jurisdiction.name'}, {name: 'id', mapping: 'jurisdiction.id'}]
        });

        jurisdiction_store.load();

        this.audience_panel = new Ext.ux.AudiencePanel({
           width: 600, height: 400, showJurisdictions: true
        });

        this.create_group_form_panel = new Ext.form.FormPanel({
            itemId: 'create_group_form',
            border:false,
            method: 'POST',
            url: '/admin_groups.json',
            items:[
                {fieldLabel: 'Group Name', xtype:'textfield', name: 'group[name]'},
                {fieldLabel: 'Scope', xtype:'combo', name: 'group[scope]', store:['Personal', 'Jurisdiction', 'Global', 'Organization'], editable: false, forceSelection: true},
                {fieldLabel: 'Owner Jurisdition', xtype: 'combo', hiddenName: 'group[owner_jurisdiction_id]', editable: false, forceSelection: true, store: jurisdiction_store, mode: 'local', valueField: 'id', displayField: 'name', triggerAction: 'all'},
                {items: this.audience_panel, border: false},
                {xtype: 'button', text: 'Submit', scope: this, handler: function(){
                    this.create_group_form_panel.getForm().submit();
                }}
            ],
            listeners:{
                scope: this,
                'actioncomplete': function(form, action){
                    if(action.type == 'submit')
                    {
                        this.showGroupDetail(action.result);
                    }
                },
                'actionfailed': function(form, action){
                    if(action.type == 'submit')
                    {
                        Ext.Msg.alert('Error', action.response.responseText);
                    }
                }
            }
        });

        this.create_group_form_panel.getForm().on('beforeaction', function(form, action){
            var audienceIds = this.audience_panel.getSelectedIds();

            action.options.params = {};

            action.options.params['group[jurisdiction_ids]'] = audienceIds.jurisdiction_ids;
            action.options.params['group[role_ids]'] = audienceIds.role_ids;
            action.options.params['group[user_ids]'] = audienceIds.user_ids;

            return true;
        }, this);

        var panel = new Ext.Panel({
            items: [this.create_group_form_panel],
            border:false,
            autoScroll:true
        });
        
        return panel;
    },

    _getGroupDetailView: function(){
        this.group_detail_panel = new Ext.Panel({
            autoScroll: true,
            border: false,
            items: [{xtype: 'box', itemId:'group_name', html: 'NAME'},
                {border: false, itemId: 'group_form_section', layout: 'form', items:[
                    {xtype: 'box', itemId: 'group_scope', fieldLabel: 'Scope', html: 'SCOPE'},
                    {xtype: 'box', itemId: 'group_jurisdiction', fieldLabel: 'Jurisdiction', html: 'JURISDICTION'}
                ]},
                {xtype: 'panel', itemId: 'group_grid_holder', border: false, layout: 'hbox', width: 500, height: 300,
                    layoutConfig: {
                        align: 'stretch',
                        defaultMargins:'0, 20, 0, 0'
                    },
                    items:[
                        {xtype: 'grid', itemId: 'recipient_grid', title: 'Recipients',
                            flex: 1,
                            store: new Ext.data.JsonStore({
                                idProperty: 'id',
                                fields: ['name', 'id', 'profile_path']
                            }),
                            columns:[{header: "Name", dataIndex: 'name', id: 'name_column'}],
                            autoExpandColumn: 'name_column',
                            sm: false
                        },
                        {
                            xtype: 'grid', itemId: 'audience_grid', title: 'Audiences',
                            flex: 1,
                            store: new Ext.data.GroupingStore({
                                reader: new Ext.data.JsonReader({
                                    idProperty: 'id',
                                    fields: ['name', 'id', 'type']
                                }),
                                groupField: 'type'}),
                            cm: new Ext.grid.ColumnModel({
                                columns: [
                                    {header: "Name", dataIndex: 'name', sortable:true, id: 'name_column'},
                                    {header: "Type", dataIndex: 'type', renderer: Ext.util.Format.capitalize, groupable: true, hidden: true}
                                ],
                                defaults:{
                                    menuDisabled: true
                                }
                            }),
                            sm: false,
                            autoExpandColumn: 'name_column',
                            view: new Ext.grid.GroupingView({
                                groupTextTpl: '{group}s'
                            })
                        }
                ]},
                {xtype: 'box', itemId: 'group_csv_link', html:'<a href="" target="_blank">Download Report (CSV)</a>'}
            ]
        });

        this.group_detail_panel.on('render', function(panel){
            if(panel.mask === true)
                var showAfter = true;

            panel.mask = new Ext.LoadMask(panel.getEl());
            if(showAfter)
                panel.mask.show();
        });

        return this.group_detail_panel;
    },

    fillGroupDetail: function(group){
        this.group_detail_panel.mask.hide();

        this.group_detail_panel.getComponent('group_name').update(group.name);
        this.group_detail_panel.getComponent('group_form_section').getComponent('group_scope').update(group.scope);
        this.group_detail_panel.getComponent('group_form_section').getComponent('group_jurisdiction').update(group.owner_jurisdiction.jurisdiction.name);
        this.group_detail_panel.getComponent('group_csv_link').getEl().select('a').set({href: group.csv_path});

        // clear the stores
        var audStore = this.group_detail_panel.getComponent('group_grid_holder').getComponent('audience_grid').getStore();
        var recipStore = this.group_detail_panel.getComponent('group_grid_holder').getComponent('recipient_grid').getStore();

        recipStore.loadData(group.recipients);

        // prep the audiences, groups, and users for reading in as json
        Ext.each(group.jurisdictions, function(jurisdiction){jurisdiction.type = 'jurisdiction';});
        Ext.each(group.roles, function(role){role.type = 'role';});
        Ext.each(group.users, function(user){user.type = 'user';});

        audStore.loadData(group.jurisdictions);
        audStore.loadData(group.roles, true);
        audStore.loadData(group.users, true);
    },

    showNewGroup: function(){
        // reset the group form
        this.create_group_form_panel.getForm().reset();
        this.audience_panel.clear();

        this.primary_panel.layout.setActiveItem(1);
        this.primary_panel.fireEvent('afternavigation', this.primary_panel);
        this.primary_panel.setTitle('Create New Group');
    },

    showGroupDetail: function(group){
        if(Ext.isObject(group))
        {
            // we have the group already to go and just need to load the json here
            this.fillGroupDetail(group);
        }
        else
        {
            // we need to make an ajax request to get the group information
            if(this.group_detail_panel.mask && this.group_detail_panel.mask.show)
                this.group_detail_panel.mask.show();
            else
                this.group_detail_panel.mask = true;

            Ext.Ajax.request({
                url: '/admin_groups/' + group + '.json',
                method: 'GET',
                success: function(response, options){
                    var group = Ext.decode(response.responseText);
                    this.fillGroupDetail(group);
                },
                scope: this
            });
        }

        this.primary_panel.layout.setActiveItem(2);
        this.primary_panel.fireEvent('afternavigation', this.primary_panel);
        this.primary_panel.setTitle('Group Detail');
    },

    forward: function(){},

    back: function(){
        if(this.canGoBack())
        {
            this.primary_panel.layout.setActiveItem(0);
            this.primary_panel.fireEvent('afternavigation', this.primary_panel);
            this.primary_panel.setTitle('Manage Groups');
        }
    },

    canGoForward: function(){ return false; },

    canGoBack: function(){
        return this.primary_panel.items.indexOf(this.primary_panel.layout.activeItem) !== 0
    }
});

Talho.ManageGroups.initialize = function(config)
{
    var manage_groups = new Talho.ManageGroups(config);
    return manage_groups.getPanel();
};