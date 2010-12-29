Ext.ns('Talho');

Talho.Documents = Ext.extend(function(){}, {
    constructor: function(config){
        Ext.apply(this, config);

        var blank_store = new Ext.data.Store({});

        this.file_actions = new Talho.ux.Documents.FileActions({listeners: {
            scope: this,
            'refresh': this._refresh
        }});

        this._createFolderTreeGrid();
        this.file_actions.folder_tree = this._folderTreeGrid;

        var panelConfig = {
            closable: true,
            layout: 'border',
            items:[
                {region: 'west', itemId: 'folder_tree_holder', xtype:'panel', layout: 'border', margins: '5 0 5 5', width: 300, border: false, split: true, items:[
                    this._folderTreeGrid,
                    {xtype: 'button', text: 'Search', region: 'south', handler: function(){
                        Application.fireEvent('opentab', {title: 'Search for Files', initializer: 'Talho.DocumentSearch'});
                    }}
                ]},
                {xtype: 'container', itemId: 'file_grid_holder', region: 'center', layout: 'card', margins: '5 5 5 0', activeItem: 0, items: [this._createFileIconView(blank_store), this._createFileGrid(blank_store)] }
            ],
            reset: this._refresh.createDelegate(this)
        };

        Ext.apply(panelConfig, config);

        var panel = new Ext.Panel(panelConfig);

        panel.on('afterrender', function(){this.file_actions.download_frame_target = this.getPanel().getEl(); }, this, {delay: 1});

        this.getPanel = function(){
            return panel;
        }
    },

    /**
     * Tree grid for the folders. Should have: 1) status icons (shared, public, etc), 2) a root level for Users (and My Folders),
     * 3) a context menu for actions such as editing and setting up sharing options,
     */
    _createFolderTreeGrid: function(){
        return this._folderTreeGrid =  new Ext.ux.maximgb.tg.GridPanel({
            title: 'Folders',
            frame: true,
            region: 'center',
            itemId: 'folder_grid',
            bodyCssClass: 'document-folder-tree-grid',
            margins: '0 0 5 0',
            hideHeaders: true,
            store: new Ext.ux.maximgb.tg.AdjacencyListStore({
                url: '/folders.json',
                restful: true,
                reader: new Ext.data.JsonReader({
                    fields: ['name', 'id', 'safe_id', 'parent_id', 'safe_parent_id', 'leaf', 'shared', 'is_owner', 'is_author', {name: 'type', mapping:'ftype'}, {name:'created_at', type: 'date', dateFormat: 'Y-m-d\\Th:i:sP'}, {name: 'updated_at', type: 'date', dateFormat: 'Y-m-d\\Th:i:sP'}],
                    idProperty: 'safe_id',
                    root: 'folders'
                }),
                parent_id_field_name: 'safe_parent_id',
                leaf_field_name: 'leaf',
                autoLoad: true,
                listeners: {
                    scope: this,
                    'load': {
                        single: true,
                        fn: function(store){
                            this._folderTreeGrid.getSelectionModel().selectFirstRow();
                        }
                    }
                }
            }),
            master_column_id: 'name_column',
            columns: [
                {xtype: 'xactioncolumn', icon: '/images/shared.png', iconCls: 'folder-shared-icon', showField: 'shared', tooltip: 'Folder is shared with other users'},
                {id: 'name_column', header: '', dataIndex: 'name'},
                {xtype: 'xactioncolumn', icon: '/images/arrow_down2.png', iconCls: 'folder-context-icon', showField: 'is_owner', tooltip: 'Show the folder context menu', handler: this.showFolderContextMenu, scope: this}
            ],
            sm: new Ext.grid.RowSelectionModel({
                single:true,
                listeners: {
                    scope: this,
                    'rowselect': function(sm, row, record){
                        if(!this._fileGrid){
                            this._fileGrid = this.getPanel().getComponent('file_grid_holder').getComponent('file_grid');
                        }
                        if(!this._iconView){
                            this._iconView = this.getPanel().getComponent('file_grid_holder').getComponent('file_icon_holder').getComponent('file_icon_view');
                        }

                        this.getPanel().getComponent('file_grid_holder').getComponent('file_icon_holder').setTitle(record.get('name'));
                        this._fileGrid.setTitle(record.get('name'));

                        if(record.get('type') == 'share' && record.get('id') == null){
                            if(this._fileGrid){
                                var store = this._fileGrid.getStore();
                                if(store.proxy){
                                    store.removeAll();

                                    if(store.proxy.activeRequest){
                                        Ext.Ajax.abort(store.proxy.activeRequest);
                                        delete store.proxy.activeRequest;
                                    }
                                }
                            }
                        }
                        else{
                            this.showFiles(record);
                        }
                    },
                    'selectionchange': this._setFileControlsState
                }
            }),
            loadMask: true,
            autoExpandColumn: 'name_column',
            bbar: ['->', {text: 'Refresh', iconCls: '', scope: this, handler: this._refresh}, {text: 'Add Folder', iconCls: 'documents-add-folder-icon', scope: this.file_actions, handler: this.file_actions.createNewFolder}]
        });
    },

    showFiles: function(record){
        var store = new Talho.ux.Documents.FileStore({
            url: '/folders/' + record.get('id') + '.json',
            autoLoad: true,
            listeners: {
                scope: this,
                'load': function(){
                    true
                },
                'beforeload': function(store, options){
                    options['params'] = options['params'] || {};
                    options['params']['type'] = record.get('type');
                    return true;
                }
            }
        });

        this._fileGrid.reconfigure(store, this._fileGrid.getColumnModel());
        this._iconView.bindStore(store);
    },

    /**
     * Push this off into its own extension
     */
    _createFileGrid: function(store){
        return {
            xtype: 'grid',
            title: 'Files',
            itemId: 'file_grid',
            frame: true,
            loadMask: true,
            store: store,
            columns: [
                {header: 'Filename', dataIndex: 'name', id: 'filename_column', sortable: true},
                {header: 'Type', dataIndex: 'type', sortable: true},
                {header: 'Size', dataIndex: 'size', sortable: true},
                {header: 'Uploader', dataIndex: 'user_display_name', sortable: true}
            ],
            viewConfig: {
                enableRowBody: true,
                getRowClass: function(record, rowIndex, rp){
                    rp.body = '<span class="documents-detail-row-body">';
                    rp.body += '<span class="row-body-button download"><span class="documents-download-icon icon-16">&nbsp;</span><span class="inlineLink">Download File</span></span>';
                    rp.body += '<span class="row-body-button move"><span class="documents-move-icon icon-16">&nbsp;</span><span class="inlineLink">Move File</span></span>';
                    rp.body += '<span class="row-body-button replace"><span class="documents-replace-icon icon-16">&nbsp;</span><span class="inlineLink">Replace File</span></span>';
                    rp.body += '<span class="row-body-button delete"><span class="documents-delete-file-icon icon-16">&nbsp;</span><span class="inlineLink">Delete File</span></span>';
                    rp.body += "</span>";
                    return "documents-detail-row"
                }
            },
            autoExpandColumn: 'filename_column',
            tools: [{id: 'icon-view', scope: this, qtip: 'Icon View', handler: function(){
                this.getPanel().getComponent('file_grid_holder').layout.setActiveItem(0);
                this.getPanel().doLayout();
            }}],
            sm: new Ext.grid.RowSelectionModel({
                single:true,
                listeners: {
                    scope: this,
                    'selectionchange': this._setFileControlsState
                }
            }),
            listeners: {
                scope: this,
                'rowbodyclick': function(grid, index, event){
                    var elem = event.getTarget('.row-body-button', null, true);
                    if(elem.hasClass('download')){
                       this.file_actions.downloadFile()
                    }
                    else if(elem.hasClass('move')){
                        this.file_actions.moveItem();
                    }
                    else if(elem.hasClass('replace')){
                        this.file_actions.uploadFile('replace');
                    }
                    else if(elem.hasClass('delete')){
                        this.file_actions.deleteItem()
                    }
                }
            }
        };
    },

    _createFileIconView: function(store){

        return {
            xtype: 'panel',
            title: 'Files',
            layout: 'border',
            cls: 'document-icon-view-wrap',
            itemId: 'file_icon_holder',
            frame: true,
            items: [{
                xtype: 'document-fileiconview',
                store: store,
                region: 'center',
                listeners:{
                    scope: this,
                    'selectionchange': this._setFileControlsState,
                    'dblclick': function(gv, index){
                        var store = gv.getStore();
                        var rec = store.getAt(index);
                        if(rec.get('type') == 'folder'){
                            // open this folder in the view by selecting it in the folder list
                            var ftstore = this._folderTreeGrid.getStore();
                            var folder = ftstore.getAt( ftstore.findExact('id', rec.get('id') ) );
                            var ancestors = ftstore.getNodeAncestors(folder);
                            Ext.each(ancestors, function(ancestor){
                                ftstore.expandNode(ancestor);
                            });
                            this._folderTreeGrid.getSelectionModel().selectRecords([folder]);
                        }
                    }
                }},
                {region: 'east', xtype: 'document-filecontrols', itemId: 'file_controls', hidden: true, file_actions: this.file_actions }],
            tools: [
                {id: 'detail-view', scope: this, qtip: 'Detail View', handler: function(){
                    this.getPanel().getComponent('file_grid_holder').layout.setActiveItem(1);
                    this.getPanel().doLayout();
                }}
            ]
        }
    },

    showFileContextMenu: function(grid, index, event){
        if(event && event.preventDefault)
            event.preventDefault();

        var record = grid.getStore().getAt(index);

        var row = grid.getView().getRow(index);

        var fileContextMenu = new Ext.menu.Menu({
            defaultAlign: 'tl-br',
            defaultOffsets: [0, 2],
            items:[{itemId:'download', text:'Download File', iconCls: 'documents-download-icon'},
                {itemId: 'move', text: 'Move File', iconCls: 'documents-move-icon'},
                {itemId: 'delete', text: 'Delete File', iconCls: 'documents-delete-file-icon'},
                {itemId: 'direct_link', text: 'Generate direct link to file'}]
        });

        fileContextMenu.show(row);
    },

    showFolderContextMenu: function(grid, index, event){
        if(event && event.preventDefault)
            event.preventDefault();

        var record = grid.getStore().getAt(index);

        var row = grid.getView().getRow(index);

        if(!grid.getSelectionModel().isSelected(record)) grid.getSelectionModel().selectRecords([record]);

        var items = [{itemId:'add', text:'Add New Folder', iconCls: 'documents-add-folder-icon', handler: this.file_actions.createNewFolder, scope: this.file_actions}];

        if(record.get('id') != null && record.get('id') != 'null'){
            items.push({itemId:'edit', text:'Edit Folder', iconCls: 'documents-edit-folder-icon', handler: this.file_actions.createNewFolder.createDelegate(this.file_actions, ['edit'])});
            if(record.get('ftype') == 'folder')
                items.push({itemId: 'move', text: 'Move Folder', iconCls: 'documents-move-icon', handler: this.file_actions.moveItem, scope: this.file_actions});
            items.push({itemId: 'delete', text: 'Delete Folder', iconCls: 'documents-delete-folder-icon', handler: this.file_actions.deleteItem, scope: this.file_actions});
        }

        var fileContextMenu = new Ext.menu.Menu({
            defaultAlign: 'tl-br',
            defaultOffsets: [0, 2],
            items: items
        });

        fileContextMenu.show(row);
    },

    _setFileControlsState: function(control){
        if(!this._fileControls){
            this._fileControls = this.getPanel().getComponent('file_grid_holder').getComponent('file_icon_holder').getComponent('file_controls');
        }

        var selections = (control.getSelectedRecords || control.getSelections).apply(control);

        var folderSelections = this._folderTreeGrid.getSelectionModel().getSelections();
        if(selections.length < 1){ // we have no selection
            // let's see if there are any selected folders
            selections = folderSelections;
        }

        this.file_actions.current_selections = this._current_selections = selections;

        if(this._iconView.isVisible())
        {
            this._fileControls.show();

            if(selections.length > 1){ // we have more than one selection: display the actions you can perform on more than one doc/file. Currently we're set to be single select on everything so this shouldn't be a worry.

            }
            else if(selections.length == 1){ // we have exactly one selection. Let's work with it.
                var sel = selections[0];
                var show = [];
                if(folderSelections[0] && folderSelections[0].get('type') == 'share'){
                    if(folderSelections[0].get('is_owner')){
                        show.push('base_actions');
                    }
                    else if(folderSelections[0].get('is_author')){
                        show.push('author_actions');
                    }
                }
                else{
                    show.push('base_actions');
                }

                var type = sel.get('type');
                if(type == 'folder'){
                    show.push('folder_detail_container', 'folder_action_container', 'move_action_container');
                    this._fileControls.applySectionDetails('folder_detail_container', {
                        'name': sel.get('name'),
                        'image': Talho.ux.Documents.mimeToImageClass('folder'),
                        'created_at': Ext.util.Format.date(sel.get('created_at'), 'n/j/y h:i A'),
                        'updated_at': Ext.util.Format.date(sel.get('updated_at'), 'n/j/y h:i A')
                    });
                }
                else if(type.match(/share/)){ // we want to figure out what sharing permissions we have, eventually, but for now, roll with it
                    show.push('folder_detail_container');
                    if(sel.get('is_owner')){
                        show.push('folder_action_container');
                    }
                    this._fileControls.applySectionDetails('folder_detail_container', {
                        'name': sel.get('name'),
                        'image': Talho.ux.Documents.mimeToImageClass('folder'),
                        'created_at': Ext.util.Format.date(sel.get('created_at'), 'n/j/y h:i A'),
                        'updated_at': Ext.util.Format.date(sel.get('updated_at'), 'n/j/y h:i A')
                    });
                }
                else{
                    if(folderSelections[0] && folderSelections[0].get('type') == 'share'){  // we want to figure out what sharing permissions we have, eventually, but for now, roll with it
                        show.push('copy_action_container', 'file_detail_container');
                        if(folderSelections[0].get('is_author')){
                            show.push('file_action_container');
                        }
                        else{
                            show.push('file_reader_action_container');
                        }
                    }
                    else{
                        show.push('file_detail_container', 'file_action_container', 'move_action_container');
                    }

                    this._fileControls.applySectionDetails('file_detail_container', {
                        'name': sel.get('name'),
                        'image': Talho.ux.Documents.mimeToImageClass(sel.get('type')),
                        'type': Talho.ux.Documents.translateMimeType(sel.get('type')),
                        'size': Ext.util.Format.fileSize(sel.get('size')),
                        'created_at': Ext.util.Format.date(sel.get('created_at'), 'n/j/y h:i A'),
                        'updated_at': Ext.util.Format.date(sel.get('updated_at'), 'n/j/y h:i A')
                    });
                }

                this._fileControls.setSectionVisibilities(show);
            }
            else{ // there really is no selection. Let's hide it all because we have no clue what to do
                this._fileControls.hide();
            }
            this._fileControls.ownerCt.doLayout();
        }
    },
        
    _refresh: function(){
        if(this._fileGrid) this._fileGrid.getStore().load();
        this._folderTreeGrid.getStore().setActiveNode(null);
        this._folderTreeGrid.getStore().load({scope: this, callback: function(){
            var sel = this._folderTreeGrid.getSelectionModel().getSelected();
            if(sel){
                var store = this._folderTreeGrid.getStore();
                var ancestors = store.getNodeAncestors(sel);
                Ext.each(ancestors, function(ancestor){
                    store.expandNode(ancestor);
                });
                store.expandNode(sel);
            }
        }});
    }

});

Talho.Documents.initializer = function(config){
    var documents = new Talho.Documents(config);
    return documents.getPanel();
};

Talho.ScriptManager.reg('Talho.Documents', Talho.Documents, Talho.Documents.initializer);