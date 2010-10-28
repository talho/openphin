Ext.ns('Talho.ux'); // using Talho.ux to not overly polute the Talho namespace, used primarily for declaring tab initializers

Talho.ux.RoleSelectionGrid = Ext.extend(Talho.ux.BaseSelectionGrid, {
    title: 'Roles',

    _createStore: function(config){
        this.store = new Ext.data.JsonStore({
            url: '/audiences/roles',
            idProperty: 'role.id',
            fields: [
                {name: 'name', mapping: 'role.name'},
                {name: 'id', mapping: 'role.id'}
            ],
            autoSave: false,
            autoLoad: false
        });

        Talho.ux.RoleSelectionGrid.superclass._createStore.call(this, config);
    },

    _createSelectionGrid: function(){
        return this.roleGridView = new Ext.grid.GridPanel({
            store: this.store,
            bodyCssClass: 'roles',
            autoExpandColumn: 'name_column',
            columns:[this.sm, {id:'name_column', header:'Name', dataIndex:'name'}],
            sm: this.sm,
            border:false,
            loadMask: true,
            listeners:{
                scope: this,
                'afterrender': {
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