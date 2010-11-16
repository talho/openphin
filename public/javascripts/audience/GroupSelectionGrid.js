Ext.ns('Talho.ux'); // using Talho.ux to not overly polute the Talho namespace, used primarily for declaring tab initializers

Talho.ux.GroupSelectionGrid = Ext.extend(Talho.ux.BaseSelectionGrid, {
    title: 'Groups/Organizations',

    _createStore: function(config){
        this.store = new Ext.data.GroupingStore({
            url: '/audiences/groups',
            reader: new Ext.data.JsonReader({
                idProperty: 'id',
                fields: [
                    {name: 'name', mapping: 'name'},
                    {name: 'id', mapping: 'id'},
                    {name: 'grouptype', mapping:'scope', convert:function(v, record){ return v === 'Organization' ? 'Organization' : 'Group';}}
                ]}),
            groupField: 'grouptype',
            autoSave: false,
            sortInfo:{
                field: 'grouptype',
                direction: 'ASC'
            }
        });

        Talho.ux.GroupSelectionGrid.superclass._createStore.call(this, config);
    },

    _createSelectionGrid: function(){
        return this.groupGridView = new Ext.grid.GridPanel({
            store: this.store,
            bodyCssClass: 'groups',
            autoExpandColumn: 'name_column',
            cm: new Ext.grid.ColumnModel({
                columns:[this.sm, {id:'name_column', header:'Name', dataIndex:'name'}, {header: 'Group Type', dataIndex:'grouptype', hidden:true, groupRenderer: Ext.util.Format.capitalize, groupable: true}]
            }),
            sm: this.sm,
            border:false,
            loadMask: true,
            view: new Ext.grid.GroupingView({
                groupTextTpl: '{group}s',
                enableGroupingMenu: false
            }),
            listeners:{
                'afterrender':{
                    fn:function(grid) {
                        grid.getStore().load();
                    },
                    single: true,
                    delay:1
                }
            }
        });
    }
});