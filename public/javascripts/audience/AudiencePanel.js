Ext.ns("Ext.ux");

/**
 * An Ext.Panel that represents the Audience selection form. Will be able to output users, juridictions, and roles from its 3 "public" stores
 * Note: To put in a FormPanel, needs to be contained inside a panel in the form. Not sure why, but I blame the form panel
 */
Ext.ux.AudiencePanel = Ext.extend(Ext.Container, {
    /**
     *    @lends Ext.ux.AudiencePanel.prototype
     */
    showJurisdictions: true,
    showRoles: true,
    showUsers: true,
    
    initComponent: function() {

        this.createTransferableRecord();

        var items = [];

        if( this.showJurisdictions === true) items.push(this._createJurisdictionsTree());
        if( this.showRoles === true) items.push(this._createRoleSelectionGrid());
        if (this.showGroups === true) items.push(this._createGroupSelectionGrid());
        if (this.showUsers === true) items.push(this._createUserSelectionGrid());

        this.accordion = new Ext.Panel({
            fieldLabel: 'Group Membership',
            layout: 'accordion',
            flex: 3,
            layoutConfig: { hideCollapseTool: true, animate: true },
            items: items,
            margins: '0 20 0 0',
            activeItem: 0,
            plugins: ['donotcollapseactive']
        });

        Ext.apply(this, { // override properties that were set in the config that we don't want
            layout: 'hbox',
            layoutConfig: { align: 'stretch' },
            items: [this.accordion, this.createSelectionBreakdownPanel()]
        });

        Ext.ux.AudiencePanel.superclass.initComponent.call(this);
    },

    disable: function(){
        this.accordion.disable();
        this.selectedItemsGridPanel.disable();
        if(!this.selectedItemsGridPanel.getEl())
            this.selectedItemsGridPanel.on('afterrender', function(){this.selectedItemsGridPanel.removeClass('x-masked-relative');}, this, {delay: 10, single: true});
        else
            this.selectedItemsGridPanel.removeClass('x-masked-relative');
    },

    enable: function(){
        this.accordion.enable();
        this.selectedItemsGridPanel.enable();
    },

    destroy: function(){
    },

    findRecordIndexInSelectedItems: function(record, type){
        return this.selectedItemsStore.findBy(function(record, type, check, id){
            return record.get('id') === check.get('id') && check.get('type') === type;
        }.bind(this, [record, type], 0));
    },

    createTransferableRecord: function(){
        this._transferableRecord = Ext.data.Record.create(
            ['name', 'id', 'email', 'title', 'tip', 'type']
        );
        this._transferableRecord.prototype.getData = function(){return this.data};
    },

    _createRoleSelectionGrid: function(){
        return this.roleSelectionGrid = new Talho.ux.RoleSelectionGrid({
            store: this.role_store,
            store_listeners:{
                scope:this,
                'load': function(){
                    // look for all of the roles in the selectedItemsStore
                    var roles = [];
                    this.selectedItemsStore.query('type', 'role').each( function(role){roles.push({id:role.get('id')}); } );
                    this.roleSelectionGrid.load(roles);
                }
            },
            sm_listeners:{
                scope:this,
                'rowselect': function(sm, index, record){
                    if(this.findRecordIndexInSelectedItems(record, 'role') === -1) // If we don't find the record, add it
                        this.selectedItemsStore.addSorted(new this._transferableRecord({name: record.get('name'), id: record.get('id'), type: 'role'}));
                },
                'rowdeselect': function(sm, index, record){
                    var recordIndex = this.findRecordIndexInSelectedItems(record, 'role');
                    if(recordIndex !== -1)
                        this.selectedItemsStore.remove(this.selectedItemsStore.getAt(recordIndex));
                }
            }
        })
    },

    _createGroupSelectionGrid: function(){
        return this.groupSelectionGrid = new Talho.ux.GroupSelectionGrid({
            store: this.group_store,
            store_listeners:{
                scope:this,
                'load': function(){
                    // look for all of the groups in the selectedItemsStore
                    var groups = [];
                    this.selectedItemsStore.query('type', 'group').each( function(group){groups.push({id:group.get('id')}); } );
                    this.groupSelectionGrid.load(groups);
                }
            },
            sm_listeners:{
                scope:this,
                'rowselect': function(sm, index, record){
                    if(this.findRecordIndexInSelectedItems(record, 'group') === -1) // If we don't find the record, add it
                        this.selectedItemsStore.addSorted(new this._transferableRecord({name: record.get('name'), id: record.get('id'), type: 'group'}));
                },
                'rowdeselect': function(sm, index, record){
                    var recordIndex = this.findRecordIndexInSelectedItems(record, 'group');
                    if(recordIndex !== -1)
                        this.selectedItemsStore.remove(this.selectedItemsStore.getAt(recordIndex));
                }
            }
        })
    },

    _createJurisdictionsTree: function(){
        return this.jurisdictionTree = new Talho.ux.JurisdictionsTree({
            store: this.jurisdiction_store,
            store_listeners:{
                scope: this,
                'load': function(){
                     // look for all of the jurisdictions in the selectedItemsStore
                    var jurisdictions = [];
                    this.selectedItemsStore.query('type', 'jurisdiction').each( function(jurisdiction){jurisdictions.push({id:jurisdiction.get('id')}); } );
                    this.jurisdictionTree.load(jurisdictions);
                }
            },
            sm_listeners:{
                scope:this,
                'rowselect': function(sm, index, record){
                    this.selectedItemsStore.clearFilter();
                    if(this.findRecordIndexInSelectedItems(record, 'jurisdiction') === -1) // If we don't find the record, add it
                    {
                        record.isFullySelected = this.jurisdictionTree.nodeHasAllChildrenSelected(record);
                        var ancestors = this.jurisdictionTree.getStore().getNodeAncestors(record);
                        Ext.each(ancestors, function(ancestor){ ancestor.isFullySelected = this.jurisdictionTree.nodeHasAllChildrenSelected(ancestor); }, this);

                        this.selectedItemsStore.addSorted(new this._transferableRecord({name: record.get('name'), id: record.get('id'), type: 'jurisdiction'}));
                    }
                    this.selectedItemsStore.applyFilter();
                },
                'rowdeselect': function(sm, index, record){
                    record.isFullySelected = false;

                    var ancestors = this.jurisdictionTree.getStore().getNodeAncestors(record);
                    Ext.each(ancestors, function(ancestor){ ancestor.isFullySelected = false }, this);

                    this.selectedItemsStore.clearFilter();
                    var recordIndex = this.findRecordIndexInSelectedItems(record, 'jurisdiction');
                    if(recordIndex !== -1)
                        this.selectedItemsStore.removeAt(recordIndex);
                    this.selectedItemsStore.applyFilter();
                },
                'massselectionchange': function(sm, addedRecords, removedRecords){
                    this.selectedItemsStore.clearFilter();
                    Ext.each(removedRecords, function(record){this.selectedItemsStore.removeAt(this.findRecordIndexInSelectedItems(record, 'jurisdiction'))}, this);

                    // clean up the added records to make sure we don't add any duplicates
                    var dontAddThese = [];
                    Ext.each(addedRecords, function(record){if(this.findRecordIndexInSelectedItems(record, 'jurisdiction') !== -1) dontAddThese.push(record);}, this);
                    Ext.each(dontAddThese, function(record){addedRecords.remove(record);});

                    var transferableItems = [];
                    Ext.each(addedRecords, function(selection){transferableItems.push(new this._transferableRecord({name: selection.get('name'), id: selection.get('id'), type: 'jurisdiction'}));}, this);

                    if(transferableItems.length > 0)
                    {
                        this.selectedItemsStore.add(transferableItems);
                        this.selectedItemsStore.sort();
                    }

                    this.selectedItemsStore.applyFilter();
                }
            }
        });
    },

    _createUserSelectionGrid: function() {
        var userAddRecords = function(store, records){
            if(records.length === 1)
                this.selectedItemsStore.addSorted(records[0]);
            else
            {
                this.selectedItemsStore.add(records);
                this.selectedItemsStore.applySort();
            }
        };

        return this.userSelectionGrid = new Talho.ux.UserSelectionGrid({
            record: this._transferableRecord,
            store_listeners:{
                scope: this,
                'add': userAddRecords,
                'load': userAddRecords,
                'remove': function(store, record){
                    this.selectedItemsStore.remove(record);
                }
            }
        });
    },

    createSelectionBreakdownPanel: function(){
        this.selectedItemsStore = new Ext.data.GroupingStore({
            reader: new Ext.data.JsonReader({
                fields: this._transferableRecord,
                idProperty: 'this_is_a_really_long_id_that_we_wont_use'
            }),
            groupField: 'type',
            listeners: {
                scope:this
            },
            filterFn: function(record){
                var type = record.get('type');
                switch(type)
                {
                    case 'user':
                    case 'role':
                    case 'group':
                        return true; // we don't want to filter users, groups, or roles
                    case 'jurisdiction':
                        var store = this.jurisdictionTree.getStore();
                        var rc = store.getAt(store.findExact('id', record.get('id')));
                        if(rc){
                            var parent = store.getNodeParent(rc);
                            return parent === null || !parent.isFullySelected;
                        }
                        else return true;
                    default: return true; // if we can't figure out what to do with it, we don't want to filter it, in case
                }
            },
            sortInfo: {
                field: 'type',
                direction: 'ASC'
            }
        });

        this.selectedItemsStore.applyFilter = function(store){
            store.filterBy(store.filterFn, this);
        }.bind(this, [this.selectedItemsStore]);
        
        this.selectedItemsStore.on('add', this.selectedItemsStore.applyFilter, this, {delay: 50});
        this.selectedItemsStore.on('remove', this.selectedItemsStore.applyFilter, this, {delay: 50});

        this.selectedItemsGridPanel = new Ext.grid.GridPanel({
            sm: false,
            title: "Recipient Preview",
            bodyCssClass: 'selectedItems',
            flex: 2,
            store: this.selectedItemsStore,
            hideHeaders: true,
            colModel: new Ext.grid.ColumnModel({
                columns: [
                    {header: "Name", dataIndex: 'name', sortable:true, id: 'name_column',
                    renderer: function(value, metaData, record, rowIndex, colIndex, store) {
                        if(record.get('type') === 'jurisdiction')
                        {
                            var jts = this.jurisdictionTree.getStore();
                            var node = jts.getAt(jts.findExact('id', record.get('id')));
                        
                            if(node && node.isFullySelected)
                            {
                                metaData.attr = 'style="font-weight:bold;"';
                                value = value + ' (ALL)';
                            }
                        }
                        return value;
                    }.bind(this)},
                    {header: "Type", dataIndex: 'type', renderer: Ext.util.Format.capitalize, groupable: true, hidden: true},
                    {xtype: 'xactioncolumn', icon: '/stylesheets/images/cross-circle.png', iconCls: 'removeBtn', scope: this, handler: function(grid, row){
                        var record = grid.getStore().getAt(row);
                        var type = record.get('type'),
                            id = record.get('id');

                        if(type === 'user'){
                            this.userSelectionGrid.getStore().remove(record);
                            return;
                        }

                        var cgrid;
                        if(type === 'jurisdiction'){
                            cgrid = this.jurisdictionTree;
                            this.jurisdictionTree.clearFilter();
                        }
                        else if(type === 'role')
                            cgrid = this.roleSelectionGrid;
                        else if(type === 'group')
                            cgrid = this.groupSelectionGrid;
                        
                        var sm;
                        if(cgrid && cgrid.rendered && (sm = cgrid.getSelectionModel()) && sm.grid) {
                            sm.deselectRow(cgrid.getStore().findExact('id', id));
                        }
                        else
                           grid.getStore().remove(record);
                    }}
                ],
                defaults:{
                    menuDisabled: true
                }
            }),
            autoExpandColumn: 'name_column',
            view: new Ext.grid.GroupingView({
                groupTextTpl: '{group}s'
            })
        });

        return this.selectedItemsGridPanel;
    },

    getSelectedIds: function(){
        return {role_ids: Ext.invoke(this.selectedItemsStore.query('type', 'role').getRange(), 'get', 'id'),
                jurisdiction_ids: Ext.invoke(this.selectedItemsStore.query('type', 'jurisdiction').getRange(), 'get', 'id'),
                group_ids: Ext.invoke(this.selectedItemsStore.query('type', 'group').getRange(), 'get', 'id'),
                user_ids: Ext.invoke(this.selectedItemsStore.query('type', 'user').getRange(), 'get', 'id')
        };
    },

    getSelectedItems: function(){
        return {roles: Ext.invoke(this.selectedItemsStore.query('type', 'role').getRange(), 'getData'),
                jurisdictions: Ext.invoke(this.selectedItemsStore.query('type', 'jurisdiction').getRange(), 'getData'),
                groups: Ext.invoke(this.selectedItemsStore.query('type', 'group').getRange(), 'getData'),
                users: Ext.invoke(this.selectedItemsStore.query('type', 'user').getRange(), 'getData')
        };
    },

    clear: function(){
        // we need to clear each selection and then clear the selected store. Going to not listen to events as we add in order to speed things up just in case a lot of things were selected

        if(this.jurisdictionTree)
        {
            this.jurisdictionTree.clear();
        }

        this.roleSelectionGrid.clear();

        if(this.groupSelectionGrid)
        {
            this.groupSelectionGrid.clear();
        }

        if(this.userSelectionGrid)
            this.userSelectionGrid.clear();

        this.selectedItemsStore.clearFilter();
        this.selectedItemsStore.removeAll();

        if(this.accordion.rendered)
        {
            this.accordion.getLayout().setActiveItem(0);
        }
    },

    load: function(jurisdictions, roles, users, groups){
        groups = groups || [];
        // first prep each value
        Ext.each(jurisdictions, function(j){j.type = 'jurisdiction';});
        Ext.each(roles, function(r){r.type = 'role'});
        Ext.each(groups, function(r){r.type = 'group'});
        Ext.each(users, function(u){u.type = 'user'; if(!u.name){u.name = u.display_name;} });

        // clear the currently selected items: we're overwriting them
        this.selectedItemsStore.removeAll();

        // Now we need to see if jurisdictions and roles have been loaded: if they have, then we can set selected items now,
        // otherwise the load event handler for the roles and jurisdiction stores should check to see if there are any already
        // selected items
        
        if(this.roleSelectionGrid && this.roleSelectionGrid.getStore().getCount() > 0)
            this.roleSelectionGrid.load(roles);
        else
            this.selectedItemsStore.loadData(roles, true); // append: true

        if(this.groupSelectionGrid && this.groupSelectionGrid.getStore().getCount() > 0)
            this.groupSelectionGrid.load(groups);
        else
            this.selectedItemsStore.loadData(groups, true); // append: true

        if(this.jurisdictionTree && this.jurisdictionTree.getStore().getCount() > 0)
            this.jurisdictionTree.load(jurisdictions);
        else
           this.selectedItemsStore.loadData(jurisdictions, true); // append true

        // finally, let's handle user load. We're going to do this by loading directly into the user store and letting its events take care of things for us
        if(this.userSelectionGrid)
            this.userSelectionGrid.getStore().loadData(users);

        this.selectedItemsStore.applySort();
    }
});
                                                       
Ext.reg('audiencepanel', 'Ext.ux.AudiencePanel');
