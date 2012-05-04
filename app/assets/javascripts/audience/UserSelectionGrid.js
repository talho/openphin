Ext.ns('Talho.ux'); // using Talho.ux to not overly polute the Talho namespace, used primarily for declaring tab initializers

Talho.ux.UserSelectionGrid = Ext.extend(Ext.Panel, {
    title: 'Users',

    constructor: function(config){
        this.layout = 'border';
        this.addEvents('beforeselect');

        this.record = config.record || Ext.data.Record.create(['name', 'id', 'email', 'title', 'tip', 'type']);

        this._createUserSelectionStore(config);
        this._createUserSearchStore();

        this.items = [this._createUserSelectionGrid(), this._createUserSearchCombo()];

        Talho.ux.UserSelectionGrid.superclass.constructor.call(this, config);

    },

    getStore: function(){
        return this.user_store;
    },

    clear: function(){
        this.user_store.suspendEvents();
        this.user_store.removeAll();
        this.user_search_store.filters.clear();
        this.user_search_store.clearFilter();
        this.user_store.resumeEvents();
        this.user_store.fireEvent('datachanged', this.user_store);
    },

    _createUserSelectionStore: function(config){
        var userAddRecords = function(store, records){
            this.user_search_store.addFilters(Ext.invoke(records, 'get', 'id'));
        };

        this.user_store = new Ext.data.Store({
            reader: new Ext.data.JsonReader({idProperty: 'id', fields: this.record}),
            listeners:{
                scope: this,
                'add': userAddRecords,
                'load': userAddRecords,
                'remove': function(store, record){ this.user_search_store.removeFilter(record.get('id')); },
                'clear': function(store, record){ this.user_search_store.filters.clear(); this.user_search_store.clearFilter(); }
            }
        });

        if(!Ext.isEmpty(config.store_listeners) ) this.user_store.on(config.store_listeners);
    },

    _createUserSearchStore: function(){
        this.user_search_store = new Ext.data.JsonStore({
            proxy: new Ext.data.HttpProxy({
                url: '/search/show_clean.json',
                api: {read: {url: '/search/show_clean.json', method:'POST'}}
            }),
            idProperty: 'id',
            bodyCssClass: 'users',
            restful: true,
            root: 'users',
            totalProperty: 'total',
            fields: ['name', 'email', 'id', 'title', 'extra'],
            filters: new Ext.util.MixedCollection(),
            listeners: {
              scope: this,
              'beforeload': function(store, options){
                options.params = options.params || {};
                options.params["without_ids[]"] = store.filters.keys;
                return true;
              },
              'load': function(){
                this.user_search_store.filter(this.user_search_store.filters.getRange());
              }
            },
            addFilters: function(ids){
                Ext.each(ids, function(id){this.filters.add(id, {property: 'id', value: new RegExp('^(?!' + id.toString() + '$).*$')})}, this);
                this.filter(this.filters.getRange());
            },
            removeFilter: function(id){
                this.filters.removeKey(id);
                this.filter(this.filters.getRange());
            }
        });
    },

    _createUserSelectionGrid: function(){
        return {
            xtype: 'grid',
            viewConfig: {emptyText: "<h2>Enter in the person's name or email address in to the text box below to find and add PHIN users.<br/><br/>Once the user is found, click on the user to add them to your selection.</h2>", deferEmptyText: false},          
            store: this.user_store,
            sm: false,
            columns:[
                { id: 'name_column', header: 'Name', dataIndex: 'name', sortable: true, menuDisabled: true },
                { header: 'Email', dataIndex: 'email', sortable: true, width: 125, menuDisabled: true },
                { xtype: 'xactioncolumn', icon: '/assets/images/cross-circle.png', iconCls: 'remove_btn', scope: this, handler: function(grid, row){ grid.getStore().removeAt(row);}}
            ],
            autoExpandColumn: 'name_column',
            plugins: [new Ext.ux.DataTip({tpl:'<tpl for="."><div>{tip}</div></tpl>'})],
            region:'center',
            border: false
        };
    },
 
    _createUserSearchCombo: function(){
        return { xtype: 'combo',
                border: false,
                queryParam: 'tag',
                mode: 'remote',
                forceSelection: true,
                store: this.user_search_store,
                displayField: 'name',
                name: 'User',
                valueField: 'id',
                tpl:'<tpl for="."><div ext:qtip=\'{extra}\' class="x-combo-list-item">{name} - {email}</div></tpl>',
                minChars: 2,
                region: 'south',
                pageSize: 10,
                listeners:{
                    scope: this,
                    'beforequery': function(qe){
                        delete qe.combo.lastQuery;
                    },
                    'select': function(combo, record, index){
                      if(!this.fireEvent('beforeselect', record)){
                        combo.clearValue()
                        return;
                      }
                      var rec = new this.record({name: record.get('name'), email: record.get('email'), id: record.get('id'), title: record.get('title'), tip: record.get('extra'), type: 'user'}, record.get('id'));
                      rec.markDirty();
                      this.user_store.add(rec);
                      combo.clearValue();
                    }
                }
            }
    }
});