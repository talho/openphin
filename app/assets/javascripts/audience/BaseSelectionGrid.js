Ext.ns('Talho.ux');

Talho.ux.BaseSelectionGrid = Ext.extend(Ext.Panel,{
    constructor: function(config){
        Ext.apply(this, config);
        
        this.layout = 'fit';

        this._createStore(config);
        this._createSelectionModel(config);

        var grid = this.items = this._createSelectionGrid();
        this.sm.grid = grid;
        
        this.bbar = {items: ['->', 'Search:', this._createFilterField(), {text:'Clear Search', scope: this, handler: this.clearFilter}]};

        // fix a problem of the store config being overwritten
        delete config.store;
        Talho.ux.BaseSelectionGrid.superclass.constructor.call(this, config);
    },

    getStore: function(){
        return this.store;
    },

    getSelectionModel: function(){
        return this.sm;
    },

    clearFilter: function(){
        this.getBottomToolbar().getComponent('search_field').setValue('');
        this.store.filter();
    },

    clear: function(){
        var sm = this.getSelectionModel();
        if(sm.grid){
            sm.suspendEvents();
            sm.clearSelections();
            sm.resumeEvents();
        }
    },

    load: function(data){
        var store = this.getStore();

        // since we have the jurisdictions already selected in an array nearby, we'll go ahead and use that instead of going to the selectedItemsStore
        var rows = [];
        Ext.each(data, function(item){
            var row = store.findExact('id', item.id);
            if(row != -1)
                rows.push(row);
        });

        if(this.getSelectionModel().grid)
            this.getSelectionModel().selectRows(rows);
        else
            this.getSelectionModel().selectRows(rows, true); // get around the case when this is called prior to the grid being fully rendered
    },

    _createFilterField: function(){
        return {
            xtype:'textfield',
            itemId: 'search_field',
            enableKeyEvents: true,
            listeners:{
                scope: this,
                'keypress':{
                    fn: function(tf, evt) {
                        var val = tf.getValue();
                        if (!Ext.isEmpty(val)){
                            val = new RegExp(val, 'ig');
                            this.store.filter([
                                {property:'name', value: val}
                            ]);
                        }
                        else{
                            this.store.filter();
                        }
                    },
                    delay: 50
                }
            }
        }
    },

    _createStore: function(config){
        this.store = this.store || new Ext.data.Store({ });
        if(config.store_listeners)
            this.store.on(config.store_listeners);
    },

    _createSelectionModel: function(config){
        this.sm = this.sm || new Ext.ux.grid.FilterableCheckboxSelectionModel({
            simple: true,
            sortable: false
        });
        if(config.sm_listeners)
            this.sm.on(config.sm_listeners);
    },

    /**
     * This should be overridden in a subclass
     */
    _createSelectionGrid: function(){
        return {};
    }
});