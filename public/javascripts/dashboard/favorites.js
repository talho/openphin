

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

        this.favoritesPanel = new Ext.Panel({
            region:'north',
            height: 55,
            id: 'favoritestoolbar',
            layout: 'hbox',
            layoutConfig: {margin:'10'},
            listeners:{
                scope:this,
                'render': this.setupDropZone
            }
        });

        this.store = new Ext.data.JsonStore({
            fields: ['id', 'title', 'url', 'initializer'],
            listeners:{
                scope:this,
                add: this.addFavorites,
                load: this.addFavorites
            }
        });
        this.store.loadData([{id: 'han_home', title:'HAN Home', url:'/han', initializer: 'Talho.Alerts'},
                              {id: 'h1n1_faq', title:'H1N1 FAQ', url:'/faqs'}]);
    },

    getPanel: function(){
        return this.favoritesPanel;
    },

    setupDropZone: function(ct){
        ct.dropZone = new Ext.dd.DropTarget(ct.getEl().dom, {
            ddGroup: 'TabPanelDD',
            parent: this,
            buttonPanel: ct,
            canDrop: function(tabConfig)
            {
                if (this.parent.favoritesPanel.find('targetId', tabConfig.id).length > 0)
                {
                    return false;
                }
                else return true;
            },
            getTabConfig: function(item){
                return item.tabConfig;
            },
            notifyOver: function(source, evt, data)
            {
                var tabConfig = this.getTabConfig(data.item);
                if(this.canDrop(tabConfig))
                    return 'x-dd-drop-ok';
                else
                    return 'x-dd-drop-nodrop';
            },
            notifyDrop: function(dd, e, data){
                // Build launchable item
                var tabConfig = this.getTabConfig(data.item);

                if(this.canDrop(tabConfig))
                {
                    this.parent.store.loadData(tabConfig, true);
                    return true;
                }
                else return false;
            }
        });
    },

    addFavorites: function(store, records, index){
        Ext.each(records, function(record){
            this.addButton(record.json);
        }, this);
        
        this.favoritesPanel.doLayout();
    },

    addButton: function(tabConfig){
        // add the button
        this.favoritesPanel.add({
            xtype:'button',
            text: tabConfig.title,
            tabConfig: tabConfig,
            targetId: tabConfig.id,
            handler: function(b, e){
                this.fireEvent('favoriteclick', b.tabConfig);
            },
            scope: this
        });

        this.favoritesPanel.doLayout();
    }

});