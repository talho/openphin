Ext.ns('Talho');

Talho.Documents = Ext.extend(function(){}, {
    constructor: function(config){
        Ext.apply(this, config);

        var blank_store = new Ext.data.Store({});

        var panelConfig = {
            closable: true,
            layout: 'border',
            items:[
                {region: 'west', itemId: 'folder_tree_holder', xtype:'panel', layout: 'border', margins: '5 0 5 5', width: 300, border: false, split: true, items:[
                    {xtype: 'button', text: 'Search', region: 'north'},
                    this._createFolderTreeGrid()
                ]},
                {xtype: 'container', itemId: 'file_grid_holder', region: 'center', layout: 'card', margins: '5 5 5 0', activeItem: 0, items: [this._createFileIconView(blank_store), this._createFileGrid(blank_store)] }
            ]
        };

        Ext.apply(panelConfig, config);

        var panel = new Ext.Panel(panelConfig);

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
            margins: '5 0 0 0',
            store: new Ext.ux.maximgb.tg.AdjacencyListStore({
                url: '/documents/mock_folder_list',
                restful: true,
                reader: new Ext.data.JsonReader({
                    fields: ['name', 'id', 'parent_id', 'leaf', 'shared', 'is_owner', {name: 'type', mapping:'ftype'}, {name:'created_at', type: 'date', dateFormat: 'Y-m-d\\Th:i:sP'}, {name: 'updated_at', type: 'date', dateFormat: 'Y-m-d\\Th:i:sP'}],
                    idProperty: 'safe_id',
                    root: 'folders'
                }),
                parent_id_field_name: 'parent_id',
                leaf_field_name: 'leaf',
                autoLoad: true
            }),
            master_column_id: 'name_column',
            columns: [
                {xtype: 'xactioncolumn', icon: '/images/shared.png', showField: 'shared', tooltip: 'Folder is shared with other users'},
                {id: 'name_column', header: '', dataIndex: 'name'},
                {xtype: 'xactioncolumn', icon: '/images/arrow_down2.png', showField: 'is_owner', tooltip: 'Show the folder context menu', handler: this.showFolderContextMenu}
            ],
            sm: new Ext.grid.RowSelectionModel({
                single:true,
                listeners: {
                    scope: this,
                    'rowselect': function(sm, row, record){
                        this.showFiles(record);
                    },
                    'selectionchange': this._setFileControlsState
                }
            }),
            autoExpandColumn: 'name_column',
            bbar: ['->', {text: 'Add Folder', iconCls: 'documents-add-folder-icon', scope: this, handler: this._createNewFolder}]
        });
    },

    showFiles: function(record){
        var store = new Ext.data.JsonStore({
            url: '/documents/mock_file_list/' + record.get('id'),
            autoLoad: true,
            root: 'files',
            restful: true,
            idProperty: 'id_property_that_will_never_be_used_damn_you_store',
            listeners: {
                scope: this,
                'beforeload': function(store, options){
                    options['params'] = options['params'] || {};
                    options['params']['type'] = record.get('type');
                    return true;
                }
            },
            fields: [{name: 'name', sortType: Ext.data.SortTypes.asUCString}, {name:'type', mapping:'ftype'}, {name:'size', mapping: 'file_file_size'},
                'id', {name: 'created_at', type: 'date', dateFormat: 'Y-m-d\\Th:i:sP'}, {name: 'updated_at', mapping: 'file_updated_at', type: 'date', dateFormat: 'Y-m-d\\Th:i:sP'}, 'doc_url']
        });

        if(!this._fileGrid){
            this._fileGrid = this.getPanel().getComponent('file_grid_holder').getComponent('file_grid');
        }
        if(!this._iconView){
            this._iconView = this.getPanel().getComponent('file_grid_holder').getComponent('icon_outer').getComponent('file_icon_holder').getComponent('file_icon_view');
        }

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
                       this._downloadFile()
                    }
                    else if(elem.hasClass('move')){
                        this._moveItem();
                    }
                    else if(elem.hasClass('replace')){
                        this._uploadFile('replace');
                    }
                    else if(elem.hasClass('delete')){
                        this._deleteItem()
                    }
                }
            }
        };
    },

    _createFileIconView: function(store){
        var tpl = new Ext.XTemplate(
            '<tpl for=".">',
                '<div class="documents-folder-item">',
                    '<div class="documents-folder-item-icon {[this.icon_class(values.type)]}"></div>',
                    '<div>{name}</div>',
                '</div>',
            '</tpl>',
            { compiled: true,
              icon_class: function(type){
                switch(this._translateMimeType(type)){
                    case 'image': return 'documents-folder-item-image-icon';
                    case 'video': return 'documents-folder-item-video-icon';
                    case 'audio': return 'documents-folder-item-audio-icon';
                    case 'folder': return 'documents-folder-item-folder-icon';
                    case 'document': return 'documents-folder-item-doc-icon';
                    case 'spreadsheet': return 'documents-folder-item-spreadsheet-icon';
                    case 'presentation': return 'documents-folder-item-presentation-icon';
                    default: return 'documents-folder-item-file-icon';
                }
              }.createDelegate(this)
            }
        );

        return { xtype: 'container', layout: 'border', itemId: 'icon_outer',
            items:[{
                xtype: 'panel',
                title: 'Files',
                layout: 'fit',
                region: 'center',
                itemId: 'file_icon_holder',
                frame: true,
                items: [{
                    xtype: 'dataview',
                    autoScroll: true,
                    itemId: 'file_icon_view',
                    store: store,
                    tpl: tpl,
                    loadingText: 'Loading...',
                    emptyText: 'This folder is empty',
                    itemSelector: 'div.documents-folder-item',
                    overClass: 'documents-folder-item-hover',
                    selectedClass: 'documents-folder-item-selected',
                    singleSelect: true,
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
                    }}],
                tools: [
                    {id: 'detail-view', scope: this, qtip: 'Detail View', handler: function(){
                        this.getPanel().getComponent('file_grid_holder').layout.setActiveItem(1);
                        this.getPanel().doLayout();
                    }}]
                },
                {region: 'east', xtype: 'panel', itemId: 'file_controls', frame: true, title: 'Controls', width: 200, split: true, defaultType: 'container', hidden: true, items:[
                    new this.file_control_button({text: 'Create New Folder', iconCls: 'documents-add-folder-icon', scope: this, handler: this._createNewFolder}),
                    new this.file_control_button({text: 'Upload New File', iconCls: 'documents-add-icon', scope: this, handler: this._uploadFile}),
                    new Ext.menu.Separator({}),
                    { itemId: 'move_action_container', items: [
                        new this.file_control_button({itemId: 'move_selection', text: 'Move Selection', iconCls: 'documents-move-icon', scope: this, handler: this._moveItem}),
                        new this.file_control_button({itemId: 'copy_file', text: 'Copy to My Folders', iconCls: 'documents-move-icon', hidden: true, scope: this, handler: this._moveItem}),
                        new Ext.menu.Separator({})
                    ]},
                    { itemId: 'file_action_container', items:[
                            new this.file_control_button({text: 'Download File', iconCls: 'documents-download-icon', scope: this, handler: this._downloadFile}),
                            new this.file_control_button({text: 'Replace File', iconCls: 'documents-replace-icon', scope: this, handler: this._uploadFile.createDelegate(this, ['replace'])}),
                            new this.file_control_button({text: 'Delete File', iconCls: 'documents-delete-file-icon', scope: this, handler: this._deleteItem}),
                            new Ext.menu.Separator({})
                    ]},
                    { itemId: 'folder_action_container', items:[
                            new this.file_control_button({text: 'Edit Folder', iconCls: 'documents-edit-folder-icon', scope: this, handler: this._createNewFolder.createDelegate(this, ['edit'])}),
                            new this.file_control_button({text: 'Delete Folder', iconCls: 'documents-delete-folder-icon', scope: this, handler: this._deleteItem}),
                            new Ext.menu.Separator({})
                    ]},
                    { itemId: 'file_detail_container', layout: 'form', defaultType: 'displayfield', defaults:{style:{'padding-top': '3px'}}, labelWidth: 65, items:[
                        {itemId: 'type', fieldLabel: 'File Type', value: 'text/css'},
                        {itemId: 'size', fieldLabel: 'File Size', value: '150 kb'},
                        {itemId: 'created_at', fieldLabel: 'Created At', value: '10/10/2020'},
                        {itemId: 'updated_at', fieldLabel: 'Modified At', value: '10/10/2021'}
                    ]},
                    { itemId: 'folder_detail_container', hidden: true, layout: 'form', defaultType: 'displayfield', defaults:{style:{'padding-top': '3px'}}, labelWidth: 65, items:[
                        {itemId: 'created_at', fieldLabel: 'Created At', value: '10/10/2020'},
                        {itemId: 'updated_at', fieldLabel: 'Modified At', value: '10/10/2021'}
                    ]}
                ]}
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

        var fileContextMenu = new Ext.menu.Menu({
            defaultAlign: 'tl-br',
            defaultOffsets: [0, 2],
            items:[{itemId:'add', text:'Add New Folder', iconCls: 'documents-add-folder-icon'},
                {itemId:'edit', text:'Edit Folder', iconCls: 'documents-edit-folder-icon'},
                {itemId: 'move', text: 'Move Folder', iconCls: 'documents-move-icon'},
                {itemId: 'delete', text: 'Delete Folder', iconCls: 'documents-delete-folder-icon'}
            ]
        });

        fileContextMenu.show(row);
    },

    file_control_button: Ext.extend(Ext.Button, {
        template: new Ext.XTemplate('<div id="{0}" class="{1} documents-file-action-button" ><span class="{2}">&nbsp;</span><span class="inlineLink"></span></div>'),
        buttonSelector: 'span:last-child',
        getTemplateArgs: function(){
            return [this.id, this.cls, this.iconCls]
        },
        setIconClass : function(cls){
            this.iconCls = cls;
            if(this.el){
                this.setButtonClass();
            }
            return this;
        }
    }),

    _setFileControlsState: function(control){
        if(!this._fileControls){
            this._fileControls = this.getPanel().getComponent('file_grid_holder').getComponent('icon_outer').getComponent('file_controls');
        }

        var selections = (control.getSelectedRecords || control.getSelections).apply(control);

        var folderSelections = this._folderTreeGrid.getSelectionModel().getSelections();
        if(selections.length < 1){ // we have no selection
            // let's see if there are any selected folders
            selections = folderSelections;
        }

        this._current_selections = selections;

        if(this._iconView.isVisible())
        {
            this._fileControls.show();

            if(selections.length > 1){ // we have more than one selection: display the actions you can perform on more than one doc/file
                this._fileControls.setTitle("Multiple Items");
            }
            else if(selections.length == 1){ // we have exactly one selection. Let's work with it.
                var sel = selections[0];
                var type = sel.get('type');
                this._fileControls.setTitle(sel.get('name'));
                if(type == 'folder'){
                    this._setSectionVisibilities(this._fileControls, ['folder_detail_container', 'folder_action_container', 'move_action_container'], ['file_detail_container', 'file_action_container']);
                    this._applySectionDetails(this._fileControls.getComponent('folder_detail_container'), {
                        'created_at': Ext.util.Format.date(sel.get('created_at'), 'n/j/y h:i A'),
                        'updated_at': Ext.util.Format.date(sel.get('updated_at'), 'n/j/y h:i A')
                    });
                }
                else if(type.match(/share/)){ // we want to figure out what sharing permissions we have, eventually, but for now, roll with it
                    this._setSectionVisibilities(this._fileControls, ['folder_detail_container'], ['file_detail_container', 'file_action_container', 'folder_action_container', 'move_action_container']);
                }
                else{
                    if(folderSelections[0] && folderSelections[0].get('type') == 'share'){  // we want to figure out what sharing permissions we have, eventually, but for now, roll with it
                        this._setSectionVisibilities(this._fileControls, ['file_detail_container', 'file_action_container'], ['folder_detail_container', 'folder_action_container', 'move_action_container']);
                        var detail_container = this._fileControls.getComponent('file_detail_container');
                    }
                    else{
                        this._setSectionVisibilities(this._fileControls, ['file_detail_container', 'file_action_container', 'move_action_container'], ['folder_detail_container', 'folder_action_container']);
                        this._applySectionDetails(this._fileControls.getComponent('file_detail_container'), {
                            'type': this._translateMimeType(sel.get('type')),
                            'size': Ext.util.Format.fileSize(sel.get('size')),
                            'created_at': Ext.util.Format.date(sel.get('created_at'), 'n/j/y h:i A'),
                            'updated_at': Ext.util.Format.date(sel.get('updated_at'), 'n/j/y h:i A')
                        });
                    }
                }
            }
            else{ // there really is no selection. Let's hide it all because we have no clue what to do
                this._fileControls.hide();
            }
            this._fileControls.ownerCt.doLayout();
        }
    },

    _setSectionVisibilities: function(control, show, hide){
        Ext.each(show, function(s){control.getComponent(s).show();});
        Ext.each(hide, function(h){control.getComponent(h).hide();});
    },

    _applySectionDetails: function(container, values){
        for(var val in values){
            container.getComponent(val).setValue(values[val]).show();
        }
    },

    _translateMimeType: function(mime){
        if(mime.match(/image\//))
            return 'image';
        if(mime.match(/video\//))
            return 'video';
        if(mime.match(/audio\//))
            return 'audio';

        switch(mime){
            case 'folder': return 'folder';
            case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
            case 'application/vnd.openxmlformats-officedocument.wordprocessingml.template':
            case 'application/vnd.ms-word.document.macroEnabled.12':
            case 'application/vnd.ms-word.template.macroEnabled.12':
            case 'application/msword':
            case 'application/vnd.oasis.opendocument.text':
                return 'document';
            case 'application/vnd.ms-excel':
            case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
            case 'application/vnd.openxmlformats-officedocument.spreadsheetml.template':
            case 'application/vnd.ms-excel.sheet.macroEnabled.12':
            case 'application/vnd.ms-excel.template.macroEnabled.12':
            case 'application/vnd.ms-excel.addin.macroEnabled.12':
            case 'application/vnd.ms-excel.sheet.binary.macroEnabled.12':
            case 'application/vnd.oasis.opendocument.spreadsheet':
                return 'spreadsheet';
            case 'application/vnd.ms-powerpoint':
            case 'application/vnd.openxmlformats-officedocument.presentationml.presentation':
            case 'application/vnd.openxmlformats-officedocument.presentationml.template':
            case 'application/vnd.openxmlformats-officedocument.presentationml.slideshow':
            case 'application/vnd.ms-powerpoint.addin.macroEnabled.12':
            case 'application/vnd.ms-powerpoint.presentation.macroEnabled.12':
            case 'application/vnd.ms-powerpoint.slideshow.macroEnabled.12':
            case 'application/vnd.oasis.opendocument.presentation':
                return 'presentation';
            default: return 'file';
        }
    },

    _createNewFolder: function(mode){
        var win = new Talho.ux.documents.AddEditFolderWindow({isEdit: mode == 'edit'});
        win.show();
    },

    _uploadFile: function(mode){
        var win = new Ext.Window({title: mode == 'replace' ? 'Replace Document' : 'New Document',
            items:[{itemId: 'upload_form', xtype: 'form', fileUpload: true, padding: '5', items:[
                {xtype: 'textfield', inputType: 'file', fieldLabel: 'File'},
                {xtype: 'checkbox', hideLabel: true, boxLabel: 'Single View - remove this file from a user\'s view after they have seen the file'}
            ]}],
            buttons: [
                {text: 'Save'},
                {text: 'Cancel', handler: function(){win.close();}}
            ]
        });
        win.show();
    },

    _moveItem: function(mode){
        var win = new Ext.Window({title: mode == 'copy' ? 'Copy to My Documents': 'Move file/folder',
            items: {itemId: 'move_form', xtype: 'form', items:[
                {xtype: 'combo', fieldLabel: 'Move to'}
            ]},
            buttons: [
                {text: 'Save'},
                {text: 'Cancel', handler: function(){win.close();}}
            ]
        });
        win.show();
    },

    _downloadFile: function(){
        // create a hidden iframe, open the file
        if(!this._downloadFrame){
            this._downloadFrame = Ext.DomHelper.append(this.getPanel().getEl().dom, {tag: 'iframe', style: 'width:0;height:0;'});
            Ext.EventManager.on(this._downloadFrame, 'load', function(){
                // in a very strange bit of convenience, the frame load event will only fire here IF there is an error
                // need to test the convenience on IE.
                Ext.Msg.alert('Could Not Load File', 'There was an error downloading the file you have requested. Please contact an administrator');
            }, this);
        }

        if(this._current_selections.length > 0){
            this._downloadFrame.src = this._current_selections[0].get('doc_url');
        }
    },

    _deleteItem: function(){
        Ext.Msg.confirm("Delete File/Folder", "Are you sure you would like to delete this file/folder.");
    }

});

Talho.Documents.initializer = function(config){
    var documents = new Talho.Documents(config);
    return documents.getPanel();
};

Talho.ScriptManager.reg('Talho.Documents', Talho.Documents, Talho.Documents.initializer);