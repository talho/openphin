Ext.ns('Talho.ux');

Talho.ux.JurisdictionsTree = Ext.extend(Talho.ux.BaseSelectionGrid, {
    title: 'Jurisdictions',

    destroy: function(){
        this.jurisdictionContextMenu.destroy();
    },

    load: function(data){
        var sm = this.getSelectionModel();
        sm.suspendEvents();
        
        Talho.ux.JurisdictionsTree.superclass.load.call(this, data);

        sm.resumeEvents();
        var records = sm.getSelections();
        Ext.each(records, function(record){record.isFullySelected = this.nodeHasAllChildrenSelected(record);}, this);
        sm.fireEvent('massselectionchange', sm, records, []);
    },

    _createStore: function(config){
        this.store = new Ext.ux.maximgb.tg.NestedSetStore({
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
            viewConfig: {hi: 'there'},
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
                }
            }
        });

        Talho.ux.JurisdictionsTree.superclass._createStore.call(this, config);
    },

    _createSelectionModel: function(config){
        Talho.ux.JurisdictionsTree.superclass._createSelectionModel.call(this, config);
        this.sm.addEvents('massselectionchange');
    },

    _createSelectionGrid: function(){
        this.jurisdictionContextMenu = new Ext.menu.Menu({
            defaultAlign: 'tl-b?',
            defaultOffsets: [0, 2],
            plain: true,
            items:[{id:'selectAll', text:'Select All Sub-jurisdictions'},
                {id: 'selectNone', text: 'Select No Sub-jurisdictions'}]
        });


        this.jurisdictionTreeGrid = new Ext.ux.maximgb.tg.GridPanel({
            store: this.store,
            bodyCssClass: 'jurisdictions',
            master_column_id : 'name',
            columns: [ this.sm,
                {id:'name', header: "Jurisdiction", sortable: true, dataIndex: 'name', menuDisabled: true},
                {xtype:'xactioncolumn', icon: '/images/arrow_down2.png', iconCls:'contextArrow', hideField: 'leaf', scope: this, handler: function(grid, index){ this.showJurisdictionTreeContextMenu(grid, index);}}
            ],
            autoExpandColumn: 'name',
            sm: this.sm,
            border:false,
            loadMask: true,
            hideHeaders: true,
            listeners:{
                'scope': this,
                'rowcontextmenu': this.showJurisdictionTreeContextMenu
            }
        });

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
    }
});