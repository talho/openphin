

var Favorites = Ext.extend(Ext.util.Observable, {
    constructor: function(config){
        Ext.apply(this, config);

        this.addEvents({
            /**
                     *  @event favoriteclick
                     *  Fires when a favorite item is clicked
                     *  @param {Object}  config  the tab configuration object, everything that should be needed by the index to launch the tab.
                     */
           'favoriteclick': true
        });

        Favorites.superclass.constructor.call(this, config);

        this.contextMenu = new Ext.menu.Menu({
            defaultAlign: 'tl-b?',
            defaultOffsets: [0, 2],
            items:[{id:'removeFavoriteItem', text:'Remove'}]
        });

        this.favoritesPanel = new Ext.Panel({
            region:'north',
            height: 44,
            id: 'favoritestoolbar',
            layout: 'hbox',
            successProperty: 'success',
            layoutConfig: {defaultMargins:'5 0 5 5'},
            listeners:{
                scope:this,
                'render': this.setupDropZone
            }
        });

        this.favoritesPanel.on('afterrender', function(panel){
            panel.loadMask = new Ext.LoadMask(panel.getEl(), {store: this.store});
            panel.loadMask.show();
            panel.saveMask = new Ext.LoadMask(panel.getEl(), {msg:'Saving...'});
        }, this, {single: true});

        var writer = new Ext.data.JsonWriter({
            encode: false,
            createRecord: function(record){
                return {
                   tab_config: record.get('tab_config') 
                };
            },
            render: function(params, baseParams, data) {
                var jdata = Ext.apply({}, baseParams);
                jdata['favorite'] = data;
                params.jsonData = jdata;
            }
        });

        var reader = new Ext.data.ux.RailsJsonReader({
            idProperty: 'favorite.id',
            fields: [{name: 'id', mapping:'favorite.id'}, {name:'tab_config', mapping:'favorite.tab_config'}]
        });

        this.store = new Ext.data.Store({
            url: '/favorites.json',
            restful: true,
            writer: writer,
            reader: reader,
            listeners:{
                scope:this,
                save: this.renderFavorites,
                datachanged: this.renderFavorites
            }
        });

        this.store.load();
    },

    getPanel: function(){
        return this.favoritesPanel;
    },

    setupDropZone: function(ct){
        ct.dropZone = new Ext.dd.DropTarget(ct.getEl().dom, {
            ddGroup: 'TabPanelDD',
            parent: this,
            buttonPanel: ct,
            canDrop: function(tab_config)
            {
                // require a tab_config and a tab_config.id to save a favorite
                return !Ext.isEmpty(tab_config) && !Ext.isEmpty(tab_config.id) && !(this.parent.favoritesPanel.find('targetId', tab_config.id).length > 0)
            },
            gettab_config: function(item){
                return item.tab_config;
            },
            notifyOver: function(source, evt, data)
            {
                var tab_config = this.gettab_config(data.item);
                if(this.canDrop(tab_config))
                    return 'x-dd-drop-ok';
                else
                    return 'x-dd-drop-nodrop';
            },
            notifyDrop: function(dd, e, data){
                // Build launchable item
                var tab_config = this.gettab_config(data.item);

                if(this.canDrop(tab_config))
                {
                    this.lock();
                    this.parent.favoritesPanel.saveMask.show();
                    this.parent.store.add(new this.parent.store.recordType({tab_config:tab_config}), true);
                    //this.parent.store.save();
                    return true;
                }
                else return false;
            }
        });
    },

    renderFavorites: function(store){
        this.favoritesPanel.removeAll(true);

        store.each(function(record){
            this.addButton(record);
        }, this);

        this.favoritesPanel.dropZone.unlock();
        this.favoritesPanel.saveMask.hide();
        this.favoritesPanel.doLayout();
    },

    addButton: function(record){
        // add the button
        var tab_config = record.get('tab_config');

        this.favoritesPanel.add({
            xtype:'button',
            text: tab_config.title,
            tab_config: tab_config,
            targetId: tab_config.id,
            recordId: record.id,
            template: new Ext.Template('<span id="{4}" class="favorite_button {3}" ><span></span></span>'),
            buttonSelector: 'span',
            listeners:{
                'click': function(b, e){
                   this.fireEvent('favoriteclick', b.tab_config);
                },
                'render': function(b){
                    b.getEl().on('contextmenu', function(evt, elem, options){
                        elem = evt.getTarget('.favorite_button', 10, true);

                        this.contextMenu.get('removeFavoriteItem').setHandler(this.removeItem.createDelegate(this, [options.recordId]))

                        this.contextMenu.show(elem);
                    }, this, {recordId: b.recordId, preventDefault:true});
                },
               scope: this
            }
        });

        this.favoritesPanel.doLayout();
    },

    removeItem: function(recordId){
        this.favoritesPanel.dropZone.lock();

        this.favoritesPanel.saveMask.show();

        this.store.remove(this.store.getById(recordId));
    }
});