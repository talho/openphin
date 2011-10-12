Ext.ns('Talho.ux');

Talho.ux.FavoritesPanel = Ext.extend(Ext.Panel, {
    constructor: function(config){
        config = config || {};

        Ext.applyIf(config, {
            region:'north',
            height: 29,
            collapseMode: 'mini',
            id: 'favoritestoolbar',
            layout: 'hbox',
            cls: 'favorites_bar',
            successProperty: 'success',
            layoutConfig: {defaultMargins:'3 2 1 3'},
            listeners: {}
        });

        Ext.apply(config.listeners, {
            'render': {fn: this.setupDropZone, scope: this},
            'afterrender':{
                fn:function(panel){
                   panel.loadMask = new Ext.LoadMask(panel.getEl(), {store: this.store});
                   panel.loadMask.show();
                   panel.saveMask = new Ext.LoadMask(panel.getEl(), {msg:'Saving Bookmarks...'});
                },
                single: true,
                scope: this
            }
        });

        this.addEvents(
            /**
             *  @event favoriteclick
             *  Fires when a favorite item is clicked
             *  @param {Object}  config  the tab configuration object, everything that should be needed by the index to launch the tab.
             */
           'favoriteclick',
            /**
             *  @event favoriteloadcomplete
             *  Fires when the favorite store has been loaded
             *  @param {Store}      store   the favorite store whose data has been loaded
             *  @param {Records[]}  records the records that were loaded
             */
           'favoriteloadcomplete'
        );

        Talho.ux.FavoritesPanel.superclass.constructor.call(this, config);
    },

    initComponent: function(){         
        this.contextMenu = new Ext.menu.Menu({
            defaultAlign: 'tl-b?',
            defaultOffsets: [0, 2],
            items:[{id:'removeFavoriteItem', text:'Remove', icon: '/images/x.png'}]
        });

        this.getStore();

        Talho.ux.FavoritesPanel.superclass.initComponent.call(this);
    },

    getStore: function(){
        if(!this.store){
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
                idProperty: 'id',
                fields: [{name: 'id', mapping:'id'}, {name:'tab_config', mapping:'tab_config'}]
            });
            
            this.store = new Ext.data.Store({
                url: '/favorites.json',
                restful: true,
                writer: writer,
                reader: reader,
                listeners:{
                    scope:this,
                    'save': this.renderFavorites,
                    'datachanged': this.renderFavorites,
                    'load': function(store){this.fireEvent('favoriteloadcomplete', store);},
                    'beforesave': function(){this.saveMask.show(); return true;}
                }
            });
            this.store.load();
        }

        return this.store;
    },

    setupDropZone: function(ct){
        ct.dropZone = new Ext.dd.DropTarget(ct.getEl().dom, {
            ddGroup:'TabPanelDD',
            parent: this,
            buttonPanel: ct,
            canDrop: function(tab_config)
            {
                // require a tab_config and a tab_config.id to save a favorite
                return !Ext.isEmpty(tab_config) && !Ext.isEmpty(tab_config.id) && !(this.parent.find('targetId', tab_config.id).length > 0)
            },
            gettab_config: function(data){
              if (data.item) {
                return data.item.tab_config;
              } else if (data.get('type') === 'folder' || data.get('type') === 'share'){
                  var tab_config = {};
                  tab_config.initializer = 'Talho.Documents';
                  tab_config.selected_folder_id = data.get('type') + data.get('id');
                  tab_config.id = 'Documents-' + tab_config.selected_folder_id;
                  tab_config.title = 'Documents: ' + data.get('name');
                  return tab_config;
              }
            },

            notifyOver: function(source, evt, data)
            {
                tab_config = this.gettab_config(data);
                if(this.canDrop(tab_config))
                    return 'x-dd-drop-ok';
                else
                    return 'x-dd-drop-nodrop';
            },
          
            notifyDrop: function(dd, e, data){
                // Build launchable item
                var tab_config = this.gettab_config(data);
                if(this.canDrop(tab_config))
                {
                    this.lock();
                    this.parent.saveMask.show();
                    this.parent.store.add(new this.parent.store.recordType({tab_config:tab_config}), true);
                    //this.parent.store.save();
                    return true;
                }
                else return false;
            }
        });
      ct.dropZone.addToGroup('FolderDD'); // Have to do this here because you can't add more than one ddGroup in the config.
    },

    renderFavorites: function(store){
        this.removeAll(true);

        store.each(function(record){
            this.addButton(record);
        }, this);

        if(this.dropZone) this.dropZone.unlock();
        if(this.saveMask) this.saveMask.hide();
        this.fireEvent('favoriteloadcomplete', store);
        this.doLayout();
    },

    addButton: function(record){
        // add the button
        var tab_config = record.get('tab_config');

        this.add({
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
                        this.showContextMenu(elem, options.recordId);
                    }, this, {recordId: b.recordId, preventDefault:true});
                },
               scope: this
            }
        });

        this.doLayout();
    },

    showContextMenu: function(elem, recordId){
        this.contextMenu.get('removeFavoriteItem').setHandler(this.removeItem.bind(this, [recordId]));

        this.contextMenu.show(elem);
    },

    removeItem: function(recordId){
        this.dropZone.lock();

        this.saveMask.show();

        this.store.remove(this.store.getById(recordId));
    }
});

