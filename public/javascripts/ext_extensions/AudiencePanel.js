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
    initComponent: function() {

        this.createTransferableRecord();


        var items = []

        if( this.showJurisdictions === true)
        {
            items.push({title: 'Jurisdictions', layout: 'fit', items: this.createJurisdictionsTree(), border: false});
        }

        items.push({title: 'Roles', layout:'border', items: this.createRolesGrid(), border: false});

        if (this.showGroup === true)
        {
            items.push({title: 'Groups', html: 'Group Placeholder', border: false});
        }

        items.push(this.createUserSearchPanel());

        var accordion = new Ext.Panel({
            fieldLabel: 'Group Membership',
            layout: 'accordion',
            flex: 2,
            layoutConfig: {
                hideCollapseTool: true,
                animate: true
            },
            items: items,
            activeItem: 0,
            plugins: ['donotcollapseactive']
        });


        Ext.apply(this, { // override properties that were set in the config that we don't want
            layout: 'hbox',
            border: false,
            layoutConfig: {
                align: 'stretch',
                defaultMargins:'0, 20'
            },
            items: [accordion, {title: "All Selected Placeholder", flex: 1}]
        });

        Ext.ux.AudiencePanel.superclass.initComponent.call(this);
    },

    createTransferableRecord: function(){
        this._transferableRecord = Ext.data.Record.create(
            ['name', 'id', 'email', 'title', 'tip', 'type']
        );
    },

    createRolesGrid: function() {
        var store = new Ext.data.JsonStore({
            url: '/audiences/roles',
            idProperty: 'role.id',
            fields: [
                {name: 'name', mapping: 'role.name'},
                {name: 'id', mapping: 'role.id'}
            ],
            autoSave: false
        });

        var sm = new Ext.grid.CheckboxSelectionModel({
            checkOnly: true,
            sortable: true
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
                this.roleGridView.getStore().filter();
        }, this, {delay: 50});

        this.roleGridView = new Ext.grid.GridPanel({
            store: store,
            region: 'center',
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

    createJurisdictionsTree: function() {
        this.jurisdictionContextMenu = new Ext.menu.Menu({
            defaultAlign: 'tl-b?',
            defaultOffsets: [0, 2],
            plain: true,
            items:[{id:'selectAll', text:'Select All Chilren'},
                {id: 'selectNone', text: 'Select No Children'}]
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
                fields: ['name', 'left', 'right', 'leaf', 'level', 'parent_id']
            }),
            listeners:{
                'load': function(store){
                    var fed = store.find('name', 'Federal');
                    if(Ext.isNumber(fed))
                    {
                        store.expandNode(store.getAt(fed));
                        var tex = store.find('name', 'Texas');
                        if(Ext.isNumber(tex))
                        {
                            store.expandNode(store.getAt(tex));
                        }
                    }
                }
            }
        });

        var sm = new Ext.grid.CheckboxSelectionModel({
            checkOnly: true,
            sortable: true
        });

        var rowActions = new Ext.ux.grid.RowActions({
            actions: [{iconCls: 'contextDownArrow', hideIndex: 'leaf', cb: function(grid, record, action, index){ this.showJurisdictionTreeContextMenu(grid, index);}.createDelegate(this)}]
        });

        this.jurisdictionTreeGrid = new Ext.ux.maximgb.tg.GridPanel({
            store: store,
            master_column_id : 'name',
            columns: [ sm,
                {id:'name', header: "Jurisdiction", sortable: true, dataIndex: 'name'},
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

    selectChildrenOfNode: function(record, index)
    {
        var store = this.jurisdictionTreeGrid.getStore();
        store.expandNode(record);
        var sm = this.jurisdictionTreeGrid.getSelectionModel();
        sm.selectRow(index, true);

        var children = store.getNodeDescendants(record);

        sm.selectRecords(children, true);
    },

    unselectChildrenOfNode: function(record, index)
    {
        var store = this.jurisdictionTreeGrid.getStore();
        var sm = this.jurisdictionTreeGrid.getSelectionModel();
        sm.deselectRow(index);

        var childIndexes = [];
        var childNodes = store.getNodeDescendants(record);
        Ext.each(childNodes, function(child){childIndexes.push(store.indexOf(child));});

        Ext.each(childIndexes, function(cindex){sm.deselectRow(cindex);});

        store.collapseNode(record);
        Ext.each(childNodes, function(child){store.collapseNode(child);});
    },

    createUserSearchPanel: function() {

        this.userStore = new Ext.data.Store({
              reader: new Ext.data.JsonReader({fields: this._transferableRecord})
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
                    sortable: true
                },
                {
                    header: 'Email',
                    dataIndex: 'email',
                    sortable: true,
                    width: 125
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
                store: new Ext.data.JsonStore({
                    url: '/search/show_clean',
                    idProperty: 'id',
                    restful: true,
                    fields: ['name', 'email', 'id', 'title', 'extra']
                }),
                displayField: 'name',
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
    }
});

Ext.reg('audiencepanel', Ext.ux.AudiencePanel);