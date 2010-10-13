Ext.ns("Ext.ux");

Ext.override(Ext.ux.maximgb.tg.AbstractTreeStore, {
    getNodeDescendants: function(rc)
    {
        if(!this.hasChildNodes(rc)) // if there are no child nodes
            return [];              // return an empty array

        var arr = this.getNodeChildren(rc);
        var desc = [];
        Ext.each(arr, function(node){desc = desc.concat(this.getNodeDescendants(node))}, this);

        return arr.concat(desc);
    }
});

/**
 * An Ext.Panel that represents the Audience selection form. Will be able to output users, juridictions, and roles from its 3 "public" stores
 * Note: To put in a FormPanel, needs to be contained inside a panel in the form. Not sure why, but I blame the form panel
 */
Ext.ux.AudiencePanel = Ext.extend(Ext.Panel, {
    /**
     *    @lends Ext.ux.AudiencePanel.prototype
     */
    showJurisdictions: true,
    showUsers: true,
    
    initComponent: function() {

        this.createTransferableRecord();

        var items = [];

        if( this.showJurisdictions === true)
        {
            items.push({title: 'Jurisdictions', layout: 'fit', items: this.createJurisdictionsTree(), border: false});
        }

        items.push({title: 'Roles', layout:'fit', items: this.createRolesGrid(), border: false});

        if (this.showGroups === true)
        {
            items.push({title: 'Groups/Organizations', layout:'fit', items: this.createGroupsGrid(), border: false});
        }

        if (this.showUsers)
        {
            items.push(this.createUserSearchPanel());
        }

        this.accordion = new Ext.Panel({
            fieldLabel: 'Group Membership',
            layout: 'accordion',
            flex: 3,
            layoutConfig: {
                hideCollapseTool: true,
                animate: true
            },
            items: items,
            margins: '0 20 0 0',
            activeItem: 0,
            plugins: ['donotcollapseactive']
        });


        Ext.apply(this, { // override properties that were set in the config that we don't want
            layout: 'hbox',
            border: false,
            layoutConfig: {
                align: 'stretch'
            },
            items: [this.accordion, this.createSelectionBreakdownPanel()]
        });

        Ext.ux.AudiencePanel.superclass.initComponent.call(this);
    },

    destroy: function(){
        this.jurisdictionContextMenu.destroy();
    },

    findRecordIndexInSelectedItems: function(record, type){
        return this.selectedItemsStore.findBy(function(record, type, check, id){
            return record.get('id') === check.get('id') && check.get('type') === type;
        }.createDelegate(this, [record, type], 0));
    },

    createTransferableRecord: function(){
        this._transferableRecord = Ext.data.Record.create(
            ['name', 'id', 'email', 'title', 'tip', 'type']
        );
        this._transferableRecord.prototype.getData = function(){return this.data};
    },

    createRolesGrid: function() {
        var store = new Ext.data.JsonStore({
            url: '/audiences/roles',
            idProperty: 'role.id',
            fields: [
                {name: 'name', mapping: 'role.name'},
                {name: 'id', mapping: 'role.id'}
            ],
            autoSave: false,
            listeners:{
                scope: this,
                'load': function(store){
                    // look for all of the roles in the selectedItemsStore
                    var roles = this.selectedItemsStore.query('type', 'role');
                    var rows = [];
                    roles.each(function(role){
                        var row = store.find('id', new RegExp('^' + role.get('id') + '$'));
                        if(row != -1)
                            rows.push(row);
                    });
                    this.roleGridView.getSelectionModel().selectRows(rows);
                }
            }
        });

        var sm = new Ext.grid.CheckboxSelectionModel({
            checkOnly: true,
            sortable: true,
            listeners:{
                scope: this,
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
        });

        var filterField = new Ext.form.TextField({
            enableKeyEvents: true
        });
        filterField.on('keypress', function(tf, evt) {
            var val = tf.getValue();
            if (!Ext.isEmpty(val))
            {
                val = new RegExp('.*' + val + '.*', 'i');
                this.roleGridView.getStore().filter([
                    {property:'name', value: val}
                ]);
            }
            else
                this.roleGridView.getStore().clearFilter();
        }, this, {delay: 50});

        this.roleGridView = new Ext.grid.GridPanel({
            store: store,
            bodyCssClass: 'roles',
            autoExpandColumn: 'name_column',
            cm: new Ext.grid.ColumnModel({
                columns:[sm, {id:'name_column', header:'Name', dataIndex:'name'}]
            }),
            sm: sm,
            border:false,
            loadMask: true,
            bbar:{
                items: filterField
            }
        });

        this.roleGridView.on('afterrender', function(grid) {
            grid.getStore().load();
        }, this, {single: true});

        return this.roleGridView;
    },

    createGroupsGrid: function(){
        var store = new Ext.data.GroupingStore({
            url: '/audiences/groups',
            reader: new Ext.data.JsonReader({
                idProperty: 'group.id',
                fields: [
                    {name: 'name', mapping: 'group.name'},
                    {name: 'id', mapping: 'group.id'},
                    {name: 'grouptype', mapping:'group.scope', convert:function(v, record){ return v === 'Organization' ? 'Organization' : 'Group';}}
                ]}),
            groupField: 'grouptype',
            autoSave: false,
            listeners:{
                scope: this,
                'load': function(store){
                    // look for all of the groups in the selectedItemsStore
                    var groups = this.selectedItemsStore.query('type', 'group');
                    var rows = [];
                    groups.each(function(group){
                        var row = store.find('id', new RegExp('^' + group.id + '$'));
                        if(row != -1)
                            rows.push(row);
                    });
                    this.groupGridView.getSelectionModel().selectRows(rows);
                }
            },
            sortInfo:{
                field: 'grouptype',
                direction: 'ASC'
            }
        });

        var sm = new Ext.grid.CheckboxSelectionModel({
            checkOnly: true,
            sortable: true,
            listeners:{
                scope: this,
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
        });

        var filterField = new Ext.form.TextField({
            enableKeyEvents: true
        });
        filterField.on('keypress', function(tf, evt) {
            var val = tf.getValue();
            if (!Ext.isEmpty(val))
            {
                val = new RegExp('.*' + val + '.*', 'i');
                this.groupGridView.getStore().filter([
                    {property:'name', value: val}
                ]);
            }
            else
                this.groupGridView.getStore().clearFilter();
        }, this, {delay: 50});

        this.groupGridView = new Ext.grid.GridPanel({
            store: store,
            bodyCssClass: 'groups',
            autoExpandColumn: 'name_column',
            cm: new Ext.grid.ColumnModel({
                columns:[sm, {id:'name_column', header:'Name', dataIndex:'name'}, {header: 'Group Type', dataIndex:'grouptype', hidden:true, groupRenderer: Ext.util.Format.capitalize, groupable: true}]
            }),
            sm: sm,
            border:false,
            loadMask: true,
            bbar:{
                items: filterField
            },            
            view: new Ext.grid.GroupingView({
                groupTextTpl: '{group}s',
                enableGroupingMenu: false
            })
        });

        this.groupGridView.on('afterrender', function(grid) {
            grid.getStore().load();
        }, this, {single: true});

        return this.groupGridView;
    },

    createJurisdictionsTree: function() {
        this.jurisdictionContextMenu = new Ext.menu.Menu({
            defaultAlign: 'tl-b?',
            defaultOffsets: [0, 2],
            plain: true,
            items:[{id:'selectAll', text:'Select All Sub-jurisdictions'},
                {id: 'selectNone', text: 'Select No Sub-jurisdictions'}]
        });

        var filterField = new Ext.form.TextField({
            enableKeyEvents: true
        });
        filterField.on('keypress', function(tf, evt) {
            var val = tf.getValue();
            if (!Ext.isEmpty(val))
            {
                val = new RegExp('.*' + val + '.*', 'i');
                this.jurisdictionTreeGrid.getStore().filter([
                    {property:'name', value: val}
                ]);
            }
            else
                this.jurisdictionTreeGrid.getStore().filter();
        }, this, {delay: 50});

        var store = new Ext.ux.maximgb.tg.NestedSetStore({
            leaf_field_name: 'leaf',
            right_field_name: 'right',
            left_field_name: 'left',
            level_field_name: 'level',
            root_node_level: 0,            
            url: '/audiences/jurisdictions_flat',
            autoLoad: true,
            reader: new Ext.data.JsonReader({
                idProperty: 'id',
                fields: ['name', 'id', 'left', 'right', 'leaf', 'level', 'parent_id']
            }),
            listeners:{
                scope:this,
                'load': function(store){
                    var fed = store.findExact('name', 'Federal');
                    if(Ext.isNumber(fed))
                    {
                        store.expandNode(store.getAt(fed));
                        var tex = store.findExact('name', 'Texas');
                        if(Ext.isNumber(tex))
                        {
                            store.expandNode(store.getAt(tex));
                        }
                    }

                    var sm = this.jurisdictionTreeGrid.getSelectionModel();
                    if(sm.grid)
                    {
                        // look for all of the jurisdictions in the selectedItemsStore
                        var jurisdictions = this.selectedItemsStore.query('type', 'jurisdiction');
                        var rows = [];
                        jurisdictions.each(function(jurisdiction){
                            var row = store.find('id', new RegExp('^' + jurisdiction.get('id') + '$'));
                            if(row != -1)
                                rows.push(row);
                        });
                        sm.suspendEvents();
                        sm.selectRows(rows);
                        sm.resumeEvents();
                        sm.fireEvent('massselectionchange', sm, sm.getSelections(), []);
                    }
                }
            }
        });

        var sm = new Ext.grid.CheckboxSelectionModel({
            checkOnly: true,
            sortable: false,
            header: '',
            listeners:{
                scope: this,
                'rowselect': function(sm, index, record){
                    this.selectedItemsStore.clearFilter();
                    if(this.findRecordIndexInSelectedItems(record, 'jurisdiction') === -1) // If we don't find the record, add it
                    {
                        record.isFullySelected = this.nodeHasAllChildrenSelected(record);
                        var ancestors = this.jurisdictionTreeGrid.getStore().getNodeAncestors(record);
                        Ext.each(ancestors, function(ancestor){ ancestor.isFullySelected = this.nodeHasAllChildrenSelected(ancestor); }, this);

                        this.selectedItemsStore.addSorted(new this._transferableRecord({name: record.get('name'), id: record.get('id'), type: 'jurisdiction'}));
                    }
                    this.selectedItemsStore.applyFilter();
                },
                'rowdeselect': function(sm, index, record){
                    record.isFullySelected = false;

                    var ancestors = this.jurisdictionTreeGrid.getStore().getNodeAncestors(record);
                    Ext.each(ancestors, function(ancestor){ ancestor.isFullySelected = false }, this);

                    this.selectedItemsStore.clearFilter();
                    var recordIndex = this.findRecordIndexInSelectedItems(record, 'jurisdiction');
                    if(recordIndex !== -1)
                        this.selectedItemsStore.removeAt(recordIndex);
                    this.selectedItemsStore.applyFilter();
                }
            }
        });

        sm.addEvents('massselectionchange');
        sm.addListener('massselectionchange', function(sm, addedRecords, removedRecords){

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
        }, this);

        var rowActions = new Ext.ux.grid.RowActions({
            actions: [{iconCls: 'contextDownArrow', hideIndex: 'leaf', cb: function(grid, record, action, index){ this.showJurisdictionTreeContextMenu(grid, index);}.createDelegate(this)}]
        });

        this.jurisdictionTreeGrid = new Ext.ux.maximgb.tg.GridPanel({
            store: store,
            bodyCssClass: 'jurisdictions',
            master_column_id : 'name',
            columns: [ sm,
                {id:'name', header: "Jurisdiction", sortable: true, dataIndex: 'name', menuDisabled: true},
                    rowActions
            ],
            autoExpandColumn: 'name',
            sm: sm,
            border:false,
            loadMask: true,
            plugins: [rowActions]
        });

        this.jurisdictionTreeGrid.on('rowcontextmenu', this.showJurisdictionTreeContextMenu, this);
        return this.jurisdictionTreeGrid;
    },

    showJurisdictionTreeContextMenu: function(grid, index, event){
        if(event)
            event.preventDefault();

        var record = grid.getStore().getAt(index);
        if(record.get('leaf')) // if this is a leaf, we don't want to go any further.
            return;

        var row = grid.getView().getRow(index);

        this.jurisdictionContextMenu.get('selectAll').setHandler(this.selectChildrenOfNode.createDelegate(this, [record, index]));
        this.jurisdictionContextMenu.get('selectNone').setHandler(this.unselectChildrenOfNode.createDelegate(this, [record, index]));

        this.jurisdictionContextMenu.show(row);
    },

    selectChildrenOfNode: function(record){
        var store = this.jurisdictionTreeGrid.getStore();
        store.expandNode(record);
        var sm = this.jurisdictionTreeGrid.getSelectionModel();

        var records = store.getNodeDescendants(record);

        records.unshift(record);

        sm.suspendEvents();
        sm.selectRecords(records, true);
        Ext.each(records, function(record){record.isFullySelected = this.nodeHasAllChildrenSelected(record);}, this);
        var ancestors = this.jurisdictionTreeGrid.getStore().getNodeAncestors(record);
        Ext.each(ancestors, function(ancestor){ ancestor.isFullySelected = this.nodeHasAllChildrenSelected(ancestor); }, this);
        sm.resumeEvents();
        sm.fireEvent('massselectionchange', sm, records, []);
    },

    unselectChildrenOfNode: function(record, index){
        var store = this.jurisdictionTreeGrid.getStore();
        var sm = this.jurisdictionTreeGrid.getSelectionModel();

        var indexes = [];
        indexes.push(index);
        var nodes = store.getNodeDescendants(record);
        Ext.each(nodes, function(child){indexes.push(store.indexOf(child));});
        nodes.unshift(record);
        
        sm.suspendEvents();
        Ext.each(indexes, function(i){sm.deselectRow(i);});
        sm.resumeEvents();
        sm.fireEvent('massselectionchange', sm, [], nodes);

        Ext.each(nodes, function(child){child.isFullySelected = false; store.collapseNode(child);});
        var ancestors = this.jurisdictionTreeGrid.getStore().getNodeAncestors(record);
        Ext.each(ancestors, function(ancestor){ ancestor.isFullySelected = false; }, this);
    },

    nodeHasAllChildrenSelected: function(record){
        var store = this.jurisdictionTreeGrid.getStore();
        if(store.isLeafNode(record))
            return false;

        var sm = this.jurisdictionTreeGrid.getSelectionModel();

        if(!sm.isSelected(record))
            return false;
        
        var children = store.getNodeDescendants(record);

        var partitioned = Ext.partition(children, function(child){return sm.isSelected(child);});

        return partitioned[1].length === 0
    },

    createUserSearchPanel: function() {

        this.userSearchStore = new Ext.data.JsonStore({
            proxy: new Ext.data.HttpProxy({
                url: '/search/show_clean',
                api: {read: {url: '/search/show_clean', method:'POST'}}
            }),
            idProperty: 'id',
            bodyCssClass: 'users',
            restful: true,
            fields: ['name', 'email', 'id', 'title', 'extra'],
            filters: new Ext.util.MixedCollection(),
            addFilters: function(ids){
                Ext.each(ids, function(id){this.filters.add(id, {property: 'id', value: new RegExp('^(?!' + id.toString() + '$).*$')})}, this);
                this.filter(this.filters.getRange());
            },
            removeFilter: function(id){
                this.filters.removeKey(id);
                this.filter(this.filters.getRange());
            }
        });

        var userAddRecords = function(store, records, index){
            if(records.length === 1)
                this.selectedItemsStore.addSorted(records[0]);
            else
            {
                this.selectedItemsStore.add(records);
                this.selectedItemsStore.applySort();
            }
            this.userSearchStore.addFilters(Ext.invoke(records, 'get', 'id'));
        };

        this.userStore = new Ext.data.Store({
            reader: new Ext.data.JsonReader({fields: this._transferableRecord}),
            listeners:{
                scope: this,
                'add': userAddRecords,
                'load': userAddRecords,
                'remove': function(store, record, index){
                    //var recordIndex = this.findRecordIndexInSelectedItems(record, 'user');
                    //if(recordIndex !== -1)
                    //    this.selectedItemsStore.removeAt(recordIndex);
                    this.selectedItemsStore.remove(record);
                    
                    this.userSearchStore.removeFilter(record.get('id'));
                }
            }
        });
        
        var rowActions = new Ext.ux.grid.RowActions({
            actions: [{iconCls: 'removeBtn', cb: function(grid, record, action, index){ grid.getStore().remove(record);} }]
        });

        var panel = new Ext.Panel({
            title: 'Users',
            layout: 'border',
            items: [{
                xtype: 'grid',
                store: this.userStore,
                sm: false,
                columns:[{
                    id: 'name_column',
                    header: 'Name',
                    dataIndex: 'name',
                    sortable: true,
                    menuDisabled: true
                },
                {
                    header: 'Email',
                    dataIndex: 'email',
                    sortable: true,
                    width: 125,
                    menuDisabled: true
                }, rowActions],
                autoExpandColumn: 'name_column',
                plugins: [new Ext.ux.DataTip({tpl:'<tpl for="."><div>{tip}</div></tpl>'}), rowActions],
                region:'center',
                border: false
            },
            {
                xtype: 'combo',
                border: false,
                queryParam: 'tag',
                mode: 'remote',
                forceSelection: true,
                store: this.userSearchStore,
                displayField: 'name',
                name: 'User',
                valueField: 'id',
                tpl:'<tpl for="."><div ext:qtip=\'{extra}\' class="x-combo-list-item">{name} - {email}</div></tpl>',
                minChars: 2,
                region: 'south',
                listeners:{
                    scope: this,
                    'select': function(combo, record, index){
                        this.userStore.add(new this._transferableRecord({name: record.get('name'), email: record.get('email'), id: record.get('id'), title: record.get('title'), tip: record.get('extra'), type: 'user'}));
                        combo.clearValue()
                    }
                }
            }
            ],
            border: false
        });

        return panel;
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
                        var store = this.jurisdictionTreeGrid.getStore();
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
        }.createDelegate(this, [this.selectedItemsStore]);
        
        this.selectedItemsStore.on('add', this.selectedItemsStore.applyFilter, this, {delay: 50});
        this.selectedItemsStore.on('remove', this.selectedItemsStore.applyFilter, this, {delay: 50});

        var rowActions = new Ext.ux.grid.RowActions({
            actions: [{iconCls: 'removeBtn', cb: function(grid, record, action, index){
                var type = record.get('type');
                var id = record.get('id');
                if(type === 'user')
                {
                    this.userStore.remove(record);
                    return;
                }

                var cgrid;
                if(type === 'jurisdiction')
                    cgrid = this.jurisdictionTreeGrid;
                else if(type === 'role')
                    cgrid = this.roleGridView;
                else if(type === 'group')
                    cgrid = this.groupGridView;
              
                if(cgrid && cgrid.rendered)
                {
                    var sm = cgrid.getSelectionModel();
                    sm.deselectRow(cgrid.getStore().findExact('id', id));
                }
                else
                {
                   grid.getStore().remove(record);
                }
            }.createDelegate(this)}]
        });

        this.selectedItemsGridPanel = new Ext.grid.GridPanel({
            sm: false,
            title: "All Selected Items",
            bodyCssClass: 'selectedItems',
            flex: 2,
            store: this.selectedItemsStore,
            colModel: new Ext.grid.ColumnModel({
                columns: [
                    {header: "Name", dataIndex: 'name', sortable:true, id: 'name_column',
                    renderer: function(value, metaData, record, rowIndex, colIndex, store) {
                        if(record.get('type') === 'jurisdiction')
                        {
                            var jts = this.jurisdictionTreeGrid.getStore();
                            var node = jts.getAt(jts.findExact('id', record.get('id')));
                        
                            if(node && node.isFullySelected)
                            {
                                metaData.attr = 'style="font-weight:bold;"';
                                value = value + ' (ALL)';
                            }
                        }
                        return value;
                    }.createDelegate(this)},
                    {header: "Type", dataIndex: 'type', renderer: Ext.util.Format.capitalize, groupable: true, hidden: true},
                        rowActions
                ],
                defaults:{
                    menuDisabled: true
                }
            }),
            autoExpandColumn: 'name_column',
            plugins: [rowActions],
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

        if(this.jurisdictionTreeGrid)
        {
            var jsm = this.jurisdictionTreeGrid.getSelectionModel();
            if(jsm.grid)
            {
                jsm.suspendEvents();
                jsm.clearSelections();
                jsm.resumeEvents();
            }
        }

        var rsm = this.roleGridView.getSelectionModel();
        if(rsm.grid)
        {
            rsm.suspendEvents();
            rsm.clearSelections();
            rsm.resumeEvents();
        }

        if(this.groupGridView)
        {
            var gsm = this.groupGridView.getSelectionModel();
            if(gsm.grid)
            {
                gsm.suspendEvents();
                gsm.clearSelections();
                gsm.resumeEvents();
            }
        }

        if(this.userStore)
        {
            this.userStore.suspendEvents();
            this.userStore.removeAll();
            this.userSearchStore.filters.clear();
            this.userSearchStore.clearFilter();
            this.userStore.resumeEvents();
            this.userStore.fireEvent('datachanged', this.userStore, this.userStore);
        }

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
        Ext.each(users, function(u){u.type = 'user'});

        // clear the currently selected items: we're overwriting them
        this.selectedItemsStore.removeAll();

        // Now we need to see if jurisdictions and roles have been loaded: if they have, then we can set selected items now,
        // otherwise the load event handler for the roles and jurisdiction stores should check to see if there are any already
        // selected items
        var store, rows;

        if(this.roleGridView.getStore().getCount() > 0)
        {
            store = this.roleGridView.getStore();

            // since we have the jurisdictions already selected in an array nearby, we'll go ahead and use that instead of going to the selectedItemsStore
            rows = [];
            Ext.each(roles, function(role){
                var row = store.find('id', role.id);
                if(row != -1)
                    rows.push(row);
            });

            this.roleGridView.getSelectionModel().selectRows(rows);
        }
        else
        {
            this.selectedItemsStore.loadData(roles, true); // append: true
        }

        if(this.groupGridView && this.groupGridView.getStore().getCount() > 0)
        {
            store = this.groupGridView.getStore();

            // since we have the jurisdictions already selected in an array nearby, we'll go ahead and use that instead of going to the selectedItemsStore
            rows = [];
            Ext.each(groups, function(group){
                var row = store.find('id', group.id);
                if(row != -1)
                    rows.push(row);
            });

            this.groupGridView.getSelectionModel().selectRows(rows);
        }
        else
        {
            this.selectedItemsStore.loadData(groups, true); // append: true
        }

        if(this.jurisdictionTreeGrid && this.jurisdictionTreeGrid.getStore().getCount() > 0)
        {
            store = this.jurisdictionTreeGrid.getStore();

            // since we have the jurisdictions already selected in an array nearby, we'll go ahead and use that instead of going to the selectedItemsStore
            rows = [];
            Ext.each(jurisdictions, function(jurisdiction){
                var row = store.find('id', jurisdiction.id);
                if(row != -1)
                    rows.push(row);
            });

            var sm = this.jurisdictionTreeGrid.getSelectionModel();
            sm.suspendEvents();
            sm.selectRows(rows);
            sm.resumeEvents();
            var records = sm.getSelections();
            Ext.each(records, function(record){record.isFullySelected = this.nodeHasAllChildrenSelected(record);}, this);
            sm.fireEvent('massselectionchange', sm, records, []);
        }
        else
        {
           this.selectedItemsStore.loadData(jurisdictions, true); // append true
        }

        // finally, let's handle user load. We're going to do this by loading directly into the user store and letting its events take care of things for us
        if(this.userStore)
            this.userStore.loadData(users);

        this.selectedItemsStore.applySort();
    }
});
                                                       
Ext.reg('audiencepanel', Ext.ux.AudiencePanel);
