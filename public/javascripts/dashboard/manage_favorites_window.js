
/**
 * This is a window that expects a store, already loaded and configured, of favorite items.
 */
Ext.define('Ext.ux.ManageFavoritesWindow', {
    extend: 'Ext.Window',
    layout: 'border',
    height: 400,
    width: 500,
    modal: true,
    initComponent: function(){
         /*var rowActions = new Ext.ux.grid.RowActions({
           actions: [
               
           ]
        });*/

        this.items = [{xtype: 'grid',
                region: 'center',
                title: 'Current Bookmarks',
                border: false,
                itemId: 'favorites_grid',
                store: this.store,
                columns: [
                  {id: 'name_column', header: 'Name', dataIndex: 'tab_config', renderer: function(value){return value.title;}, sortable: false, flex: 1}, 
                  {xtype: 'actioncolumn', iconCls: 'removeBtn', icon: '/images/cross-circle.png', tooltip: 'delete', width: 20, menuDisabled: true, handler: function(grid, row, col, item, e){
                     var store = grid.getStore(),
                         record = store.getAt(row);
                         
                     Ext.Msg.confirm("Confirm Removal", "Are you sure you wish to remove " + record.get('tab_config').title + "?", function(btn){
                       if(btn === 'yes'){
                         store.removeAt(row);
                       }
                   });
               }}
                //  rowActions
                ],                
                sm: false
            },
            {xtype: 'box', region: 'south', margins: '5', html: 'To add additional bookmarks, drag tabs into the bookmark toolbar area. In addition to clicking the "x" above, you can remove items by right clicking the bookmark button and selecting remove.'}
        ];

        this.store.on('beforesave', function(){
            var grid = this.getComponent('favorites_grid');
            if(!grid.saveMask){
                grid.saveMask = new Ext.LoadMask(grid.getEl(), {msg: 'Saving...'});
            }

            grid.saveMask.show();
            return true;
        }, this);
        this.store.on('save', function(){this.getComponent('favorites_grid').saveMask.hide();}, this);

        Ext.ux.ManageFavoritesWindow.superclass.initComponent.call(this);
    }
});