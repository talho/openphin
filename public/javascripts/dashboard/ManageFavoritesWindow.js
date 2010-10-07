Ext.ns("Ext.ux");

/**
 * This is a window that expects a store, already loaded and configured, of favorite items.
 */
Ext.ux.ManageFavoritesWindow = Ext.extend(Ext.Window, {
    constructor: function(config){
         var rowActions = new Ext.ux.grid.RowActions({
           actions: [
               {iconCls: 'removeBtn', qtip: 'delete', cb: function(grid, record, action, index, colIndex){
                   if(confirm("Are you sure you wish to remove " + record.get('tab_config').title + "?"))
                   {
                       var store = grid.getStore();
                       store.remove(record);
                   }
               }}
           ]
        });

        Ext.apply(config, {
            items: [{xtype: 'grid',
                region: 'center',
                title: 'Current Bookmarks',
                border: false,
                itemId: 'favorites_grid',
                store: config.store,
                cm: new Ext.grid.ColumnModel({
                    columns: [{id: 'name_column', header: 'Name', dataIndex: 'tab_config', renderer: function(value){return value.title;}, sortable: false}, rowActions]
                }),
                plugins: [rowActions],
                autoExpandColumn: 'name_column',
                sm: false
            },
                {xtype: 'box', region: 'south', margins: '5', html: 'To add additional bookmarks, drag tabs into the bookmark toolbar area. In addition to clicking the "x" above, you can remove items by right clicking the bookmark button and selecting remove.'}]
        });

        config.store.on('beforesave', function(){
            var grid = this.getComponent('favorites_grid');
            if(!grid.saveMask){
                grid.saveMask = new Ext.LoadMask(grid.getEl(), {msg: 'Saving...'});
            }

            grid.saveMask.show();
            return true;
        }, this);
        config.store.on('save', function(){this.getComponent('favorites_grid').saveMask.hide();}, this);

        Ext.applyIf(config, {
            layout: 'border',
            height: 400,
            width: 500
        });

        Ext.ux.ManageFavoritesWindow.superclass.constructor.call(this, config);
    },

    initComponent: function(){
        Ext.ux.ManageFavoritesWindow.superclass.initComponent.call(this);
    }
});