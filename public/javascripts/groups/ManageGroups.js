
Ext.ns('Talho');

/**
 * Talho.ManageGroups creates a card layout panel that manages a set of 3 panels: Group Lists, Create Group, and Group Detail
 * @param  {Object}  config  configuration for Manage Groups - In this case, for now, it's empty
 */
Talho.ManageGroups = Ext.extend(Ext.util.Observable, {
    /**
      * @lends Talho.ManageGroups.prototype
      */
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

    /**
         * Creates the group view for listing a user's groups
         */
    _getGroupView: function(){
        var store = new Ext.data.JsonStore({
            restful: true,
            url: '/admin_groups.json',
            root: 'groups',
            idProperty: 'id',
            remoteSort: 'true',
            totalProperty: 'count',
            per_page: 10,
            paramNames:{
                limit: 'per_page'
            },
            listeners:{
                scope: this,
                'beforeload': function(store, options){
                    if(!options.params){
                        options.params = {};
                    }
                    options.params['page'] = ((options.params.start || 0) / store.per_page) + 1;

                    return true;
                },
                'beforesave': function(){
                    if(!Ext.isBoolean(this.group_list.loadMask))
                    {
                        this.group_list.loadMask.msg = "Saving...";
                        this.group_list.loadMask.show();
                    }
                    return true;
                },
                'save': function(store){
                    if(!Ext.isBoolean(this.group_list.loadMask))
                    {
                        this.group_list.loadMask.hide();
                        this.group_list.loadMask.msg = "Loading...";
                    }
                    store.load();
                }
            },
            fields:['name', 'scope', {name: "owner", mapping: "owner.display_name"}, {name: "owner_id", mapping: "owner.id"}, {name: 'owner_path', mapping: 'owner.profile_path'}, 'group_path'],
            autoSave: false,
            writer: new Ext.data.JsonWriter({
                encode: false
            })
        });

        var rowActions = new Ext.ux.grid.xActionColumn({
           items: [
               {icon: '/stylesheets/images/page_edit.png', tooltip: 'Edit Group', handler: function(grid, row){
                   var record = grid.getStore().getAt(row);
                   this.showNewGroup(record.id);
               }, scope: this},
               {icon: '/images/cross-circle.png', tooltip: 'Delete Group', handler: function(grid, row, action, index, colIndex){
                   var store = grid.getStore();
                   var record = store.getAt(row);
                   if(confirm("Are you sure you wish to delete " + record.get('name') + "?"))
                   {
                       store.remove(record);
                       store.save();
                   }
               }, scope: this}
           ]
        });

        this.group_list = new Ext.grid.GridPanel({
            store: store,
            border: false,
            width: 500,
            height: 300,
            columns: [
                {header: 'Name', id: 'name_column', dataIndex: 'name'},
                {header: 'Owner', dataIndex: 'owner', renderer: function(value, metaData){ metaData.css = 'inlineLink'; return value;}},
                {header: 'Scope', dataIndex: 'scope'},
                rowActions

            ],
            sm: false,
            autoExpandColumn: 'name_column',
            loadMask: true,
            listeners:{
                scope: this,
                'cellclick': function(grid, row, column, e){
                    var fieldName = grid.getColumnModel().getDataIndex(column); // Get field name
                    var record = grid.getStore().getAt(row);  // Get the Record
                    if(fieldName === 'name')
                    {
                        this.showGroupDetail(record.id);
                    }
                    else if(fieldName === 'owner')
                    {
                        Application.fireEvent('opentab', {title: 'User Profile - ' + record.get('owner'), url: record.get('owner_path'), id: 'user_profile_for_' + record.get('owner_id') });
                    }
                }
            },
            bbar: new Ext.PagingToolbar({
                store: store,       // grid and PagingToolbar using same store
                pageSize: store.per_page
            })
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

    /**
         * Creates the create/edit view fields: name, scope, owner jurisdiction, and the audience panel
         */
    _getCreateView: function(){

        var jurisdiction_store = new Ext.data.JsonStore({
            restful: true,
            url: '/jurisdictions/user_alerting',
            idProperty: 'id',
            fields: [{name: 'name', mapping: 'name'}, {name: 'id', mapping: 'id'}]
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
            editing: false,
            items:[
                {fieldLabel: 'Group Name', itemId: 'group_name', xtype:'textfield', name: 'group[name]'},
                {fieldLabel: 'Scope', itemId: 'group_scope', xtype:'combo', name: 'group[scope]', store:['Personal', 'Jurisdiction', 'Global', 'Organization'], forceSelection: true, typeAhead: true, typeAheadDelay: 0, mode: 'local', triggerAction: 'all'},
                {fieldLabel: 'Owner Jurisdiction', itemId: 'group_owner_jurisdiction', xtype: 'combo', hiddenName: 'group[owner_jurisdiction_id]', forceSelection: true, typeAhead: true, typeAheadDelay: 0, store: jurisdiction_store, mode: 'local', valueField: 'id', displayField: 'name', triggerAction: 'all'},
                {items: this.audience_panel, border: false},
                {xtype: 'button', text: 'Save', scope: this, handler: function(){
                    var options = {};

                    if(this.create_group_form_panel.editing)
                    {
                        options.url = '/admin_groups/' + this.create_group_form_panel.groupId + '.json';
                        options.method = 'PUT';
                    }

                    this.create_group_form_panel.getForm().submit(options);
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
                    //if(action.type == 'submit')
                    //{
                        Ext.Msg.alert('Error', action.response.responseText);
                        this.back();
                    //}
                }
            }
        });

        this.create_group_form_panel.getForm().on('beforeaction', function(form, action){
            var audienceIds = this.audience_panel.getSelectedIds();

            action.options.params = {};

            action.options.params['group[jurisdiction_ids][]'] = audienceIds.jurisdiction_ids;
            action.options.params['group[role_ids][]'] = audienceIds.role_ids;
            action.options.params['group[user_ids][]'] = audienceIds.user_ids;

            return true;
        }, this);


        var panel = new Ext.Panel({
            itemId: 'create_group_form_holder',
            items: [this.create_group_form_panel],
            border:false,
            autoScroll:true
        });

        panel.on('render', function(panel){
            if(this.create_group_form_panel.mask === true)
                var showAfter = true;

            this.create_group_form_panel.mask = new Ext.LoadMask(panel.getEl());
            if(showAfter)
                this.create_group_form_panel.mask.show();
        }, this);

        return panel;
    },

    /**
         * Create the group detail view which displays the same information as is in the create/edit form except is not editable from this page
         */
    _getGroupDetailView: function(){
        this.group_detail_panel = new Ext.Container({
            autoScroll: true,
            border: false,
            items: [{xtype: 'box', cls:'group_name', itemId:'group_name', html: 'NAME'},
                {border: false, itemId: 'group_form_section', layout: 'form', items:[
                    {xtype: 'box', cls: 'group_scope', itemId: 'group_scope', fieldLabel: 'Scope', html: 'SCOPE'},
                    {xtype: 'box', cls: 'group_owner_jurisdiction', itemId: 'group_jurisdiction', fieldLabel: 'Jurisdiction', html: 'JURISDICTION'}
                ]},
                new Ext.ux.AudienceDisplayPanel({itemId: 'group_audience_panel'}),
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

    /**
         *  Fills in the details for the Group Detail page from the group that we either had the results from (after creation) or the group that we looked up on click
         * @param {Object} group    the group that we're going to show the details for
         */
    fillGroupDetail: function(group){
        this.group_detail_panel.mask.hide();

        this.group_detail_panel.getComponent('group_name').update(group.name);
        this.group_detail_panel.getComponent('group_form_section').getComponent('group_scope').update(group.scope);
        this.group_detail_panel.getComponent('group_form_section').getComponent('group_jurisdiction').update(group.owner_jurisdiction.jurisdiction.name);
        this.group_detail_panel.getComponent('group_csv_link').getEl().select('a').set({href: group.csv_path});

        this.group_detail_panel.getComponent('group_audience_panel').load(group);
    },

    /**
         * Shows the create group form
         */
    showNewGroup: function(groupId){
        // reset the group form
        this.create_group_form_panel.getForm().reset();
        this.audience_panel.clear();

        if(Ext.isNumber(groupId))
        {
            // if we passed in a group id, we need to show a mask and load the data for the group of that id into this form
            if(this.create_group_form_panel.mask && this.create_group_form_panel.mask.show)
                this.create_group_form_panel.mask.show();
            else
                this.create_group_form_panel.mask = true;

            Ext.Ajax.request({
                url: '/admin_groups/' + groupId + '.json',
                method: 'GET',
                success: function(response, options){
                    var group = Ext.decode(response.responseText);

                    // Fill in the field details
                    this.create_group_form_panel.groupId = group.id;
                    this.create_group_form_panel.getComponent('group_name').setValue(group.name);
                    this.create_group_form_panel.getComponent('group_scope').setValue(group.scope);
                    this.create_group_form_panel.getComponent('group_owner_jurisdiction').setValue(group.owner_jurisdiction.jurisdiction.id);
                    var group_lock_version = this.create_group_form_panel.getComponent('group_lock_version');
                    if(!group_lock_version) // Handle adding/removing the group lock version to take care of issue with blank lock version not being able to save on the create new.
                    {
                        group_lock_version = this.create_group_form_panel.add({itemId: 'group_lock_version', xtype:'hidden', name: 'group[lock_version]'});
                        this.create_group_form_panel.doLayout();
                    }
                    group_lock_version.setValue(group.lock_version);

                    // Pass the audience panel the selected items to initialize selected and initial checked items
                    this.audience_panel.load(group.jurisdictions, group.roles, group.users);
                    
                    this.create_group_form_panel.mask.hide();
                },
                scope: this
            });

            this.create_group_form_panel.editing = true;
            this.primary_panel.setTitle('Edit Group');
        }
        else
        {
            this.create_group_form_panel.editing = false;
            this.primary_panel.setTitle('Create New Group');
            var group_lock_version = this.create_group_form_panel.getComponent('group_lock_version');
            if(group_lock_version) {  // Handle adding/removing the group lock version to take care of issue with blank lock version not being able to save on the create new.
                this.create_group_form_panel.remove(group_lock_version);
                this.create_group_form_panel.doLayout();
            }
        }

        this.primary_panel.layout.setActiveItem(1);
        this.primary_panel.fireEvent('afternavigation', this.primary_panel);
    },

    /**
         * Shows the group detail form
         * @param   {Object/Int}    group   Either an object representation of the group or the group ID that we will be looking up
         */
    showGroupDetail: function(group){
        if(Ext.isObject(group))
        {
            // we have the group already to go and just need to load the json here
            this.group_detail_panel.on('show', function(){this.fillGroupDetail(group.group || group)}, this, {delay: 10})
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

    /**
         * You can never go forward, only back
         */
    forward: function(){},

    /**
         * Handler for the back method, always goes to the Group List card
         */
    back: function(){
        if(this.canGoBack())
        {
            this.primary_panel.layout.setActiveItem(0);
            this.primary_panel.fireEvent('afternavigation', this.primary_panel);
            this.primary_panel.setTitle('Manage Groups');
        }
    },

    /**
         * You can never go forward
         */
    canGoForward: function(){ return false; },

    /**
         * If we're not on the group list card, we can go back
         */
    canGoBack: function(){
        return this.primary_panel.items.indexOf(this.primary_panel.layout.activeItem) !== 0
    }
});

/**
 * Initializer for the ManageGroup object. Returns a panel
 * @param   {Ojbect}    config  Configuration for the ManageGroups panel
 */
Talho.ManageGroups.initialize = function(config)
{
    var manage_groups = new Talho.ManageGroups(config);
    return manage_groups.getPanel();
};

Talho.ScriptManager.reg('Talho.ManageGroups', Talho.ManageGroups, Talho.ManageGroups.initialize);