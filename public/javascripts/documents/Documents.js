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
            ],
            reset: this.refresh.createDelegate(this)
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
            bodyCssClass: 'document-folder-tree-grid',
            margins: '5 0 0 0',
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
                autoLoad: true
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
                        this.showFiles(record);
                    },
                    'selectionchange': this._setFileControlsState
                }
            }),
            loadMask: true,
            autoExpandColumn: 'name_column',
            bbar: ['->', {text: 'Add Folder', iconCls: 'documents-add-folder-icon', scope: this, handler: this._createNewFolder}]
        });
    },

    showFiles: function(record){
        var store = new Ext.data.JsonStore({
            url: '/folders/' + record.get('id') + '.json',
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
                'id', {name: 'created_at', type: 'date', dateFormat: 'Y-m-d\\Th:i:sP'}, {name: 'updated_at', mapping: 'file_updated_at', type: 'date', dateFormat: 'Y-m-d\\Th:i:sP'}, 'doc_url', 'is_owner', 'is_author']
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
                    '<div unselectable="on">{name}</div>',
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
                    cls: 'document-file-icon-view',
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
                    { itemId: 'base_actions', items: [
                        new this.file_control_button({text: 'Create New Folder', iconCls: 'documents-add-folder-icon', scope: this, handler: this._createNewFolder}),
                        new this.file_control_button({text: 'Upload New File', iconCls: 'documents-add-icon', scope: this, handler: this._uploadFile}),
                        new Ext.menu.Separator({})
                    ]},
                    { itemId: 'author_actions', items: [
                        new this.file_control_button({text: 'Upload New File', iconCls: 'documents-add-icon', scope: this, handler: this._uploadFile}),
                        new Ext.menu.Separator({})
                    ]},
                    { itemId: 'move_action_container', items: [
                        new this.file_control_button({itemId: 'move_selection', text: 'Move Selection', iconCls: 'documents-move-icon', scope: this, handler: this._moveItem}),
                        new Ext.menu.Separator({})
                    ]},
                    { itemId: 'copy_action_container', items: [
                        new this.file_control_button({itemId: 'copy_file', text: 'Copy to My Folders', iconCls: 'documents-move-icon', scope: this, handler: this._moveItem.createDelegate(this, ['copy'])}),
                        new Ext.menu.Separator({})
                    ]},
                    { itemId: 'file_reader_action_container', items:[
                            new this.file_control_button({text: 'Download File', iconCls: 'documents-download-icon', scope: this, handler: this._downloadFile}),
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
                    { itemId: 'folder_detail_container', layout: 'form', defaultType: 'displayfield', defaults:{style:{'padding-top': '3px'}}, labelWidth: 65, items:[
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

        if(!grid.getSelectionModel().isSelected(record)) grid.getSelectionModel().selectRecords([record]);

        var items = [{itemId:'add', text:'Add New Folder', iconCls: 'documents-add-folder-icon', scope: this, handler: this._createNewFolder}];

        if(record.get('id') != null && record.get('id') != 'null'){
            items.push({itemId:'edit', text:'Edit Folder', iconCls: 'documents-edit-folder-icon', handler: this._createNewFolder.createDelegate(this, ['edit'])});
            if(record.get('ftype') == 'folder')
                items.push({itemId: 'move', text: 'Move Folder', iconCls: 'documents-move-icon', handler: this._moveItem, scope: this});
            items.push({itemId: 'delete', text: 'Delete Folder', iconCls: 'documents-delete-folder-icon', handler: this._deleteItem, scope: this});
        }

        var fileContextMenu = new Ext.menu.Menu({
            defaultAlign: 'tl-br',
            defaultOffsets: [0, 2],
            items: items
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

            if(selections.length > 1){ // we have more than one selection: display the actions you can perform on more than one doc/file. Currently we're set to be single select on everything so this shouldn't be a worry.
                this._fileControls.setTitle("Multiple Items");
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
                this._fileControls.setTitle(sel.get('name'));
                if(type == 'folder'){
                    show.push('folder_detail_container', 'folder_action_container', 'move_action_container');
                    this._applySectionDetails(this._fileControls.getComponent('folder_detail_container'), {
                        'created_at': Ext.util.Format.date(sel.get('created_at'), 'n/j/y h:i A'),
                        'updated_at': Ext.util.Format.date(sel.get('updated_at'), 'n/j/y h:i A')
                    });
                }
                else if(type.match(/share/)){ // we want to figure out what sharing permissions we have, eventually, but for now, roll with it
                    show.push('folder_detail_container');
                    if(sel.get('is_owner')){
                        show.push('folder_action_container');
                    }
                    this._applySectionDetails(this._fileControls.getComponent('folder_detail_container'), {
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

                    this._applySectionDetails(this._fileControls.getComponent('file_detail_container'), {
                        'type': this._translateMimeType(sel.get('type')),
                        'size': Ext.util.Format.fileSize(sel.get('size')),
                        'created_at': Ext.util.Format.date(sel.get('created_at'), 'n/j/y h:i A'),
                        'updated_at': Ext.util.Format.date(sel.get('updated_at'), 'n/j/y h:i A')
                    });
                }

                this._setSectionVisibilities(this._fileControls, show);
            }
            else{ // there really is no selection. Let's hide it all because we have no clue what to do
                this._fileControls.hide();
            }
            this._fileControls.ownerCt.doLayout();
        }
    },

    _setSectionVisibilities: function(control, show, hide){
        if(!hide){
            var allItems = new Ext.util.MixedCollection();
            allItems.addAll(Ext.clean(Ext.pluck(control.items.getRange(), 'itemId')));
            Ext.each(show, function(s){allItems.remove(s);});
            hide = allItems.getRange();
        }
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
            case 'share':
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
        var sel = this._current_selections ? this._current_selections[0] : this._folderTreeGrid.getStore().getAt(0) ;
        if(sel.get('type') !== 'folder' && !(sel.get('type') == 'share' && sel.get('is_owner')))
            sel = this._folderTreeGrid.getSelectionModel().getSelected();
        
        if(sel){
            var win = new Talho.ux.documents.AddEditFolderWindow({isEdit: mode == 'edit', selectedFolder: sel, listeners:{
                scope: this,
                'foldercreated': function(){
                    this.refresh();
                }
            }});
            win.show();
        }
    },

    _uploadFile: function(mode){
        var sel = this._current_selections[0];
        var folder = this._folderTreeGrid.getSelectionModel().getSelected();

        var fields = [];
        if(mode === 'replace')
            fields.push({xtype: 'hidden', name: '_method', value: 'PUT'});
        else
            fields.push({xtype: 'hidden', name: 'document[folder_id]', value: folder.get('id')});
        fields.push({xtype: 'textfield', inputType: 'file', fieldLabel: 'File', name: 'document[file]', anchor: '100%'});

        var win = new Ext.Window({width: 470, height: 120, title: mode == 'replace' ? 'Replace Document' : 'New Document', modal: true,
            items:[{itemId: 'upload_form', xtype: 'form', fileUpload: true, padding: '5', labelWidth: 30, baseParams: {'authenticity_token': FORM_AUTH_TOKEN}, items: fields,
                buttons: [
                    {text: 'Save', scope: this, handler: function(){
                        var form = win.getComponent('upload_form').getForm();
                        form.waitMsgTarget = win.getLayoutTarget();
                        form.submit({
                            waitMsg: 'Saving...',
                            url: '/documents' + (mode == 'replace' ? '/' + sel.get('id') : '') + '.json',
                            method: mode == 'replace' ? 'PUT' : 'POST',
                            scope: this,
                            success: function(){
                                win.close();
                                this.refresh();
                            },
                            failure: function(form, action){
                                Ext.Msg.alert("Error", action.result && action.result.msg ? action.result.msg : "There was a problem saving this file");
                            }
                        })
                    }},
                    {text: 'Cancel', handler: function(){win.close();}}
                ]}
            ]
        });
        win.show();
    },

    _moveItem: function(mode){
        var sel = this._current_selections[0];
        var type = sel.get('type');

        if(sel.get('id') == null || sel.get('id') == 'null') return;

        var win = new Ext.Window({width: 350, height: 100, title: mode == 'copy' ? 'Copy': 'Move ' + (type == 'folder' ? 'Folder' : 'File'), modal: true,
            items: {itemId: 'move_form', xtype: 'form', border: false, padding: '5', items:[
                {xtype: 'combo', fieldLabel: 'Move to', mode: 'local', triggerAction: 'all', hiddenName: 'parent_id', valueField: 'id', displayField: 'name', editable: false, allowBlank: false, store: new Ext.data.JsonStore({
                    url: '/folders/target_folders' + (type == 'folder' ? '?folder_id=' + sel.get('id') : ''),
                    fields: ['name', 'id'],
                    idProperty: 'id',
                    autoLoad: true
                })}
            ]},
            buttons: [
                {text: 'Save', scope: this, handler: function(){
                    var form = win.getComponent('move_form').getForm();
                    form.waitMsgTarget = win.getLayoutTarget();
                    var url = type == 'folder' ? '/folders/' + sel.get('id') + '/move.json' : '/documents/' + sel.get('id') + '/' + (mode == 'copy' ? 'copy' : 'move') + '.json';
                    form.submit({waitMsg: 'Saving...', url: url, scope: this,
                    success: function(){this.refresh(); win.close();},
                    failure: function(){
                        Ext.Msg.alert('Error', 'There was a problem moving this folder. Administrators have been contacted');
                    }});
                }},
                {text: 'Cancel', handler: function(){win.close();}}
            ]
        });
        win.show();
    },

    _downloadFile: function(){
        // create a hidden iframe, open the file
        if(Application.rails_environment === 'cucumber')
        {
            Ext.Ajax.request({
                url: this._current_selections[0].get('doc_url'),
                method: 'GET',
                success: function(){
                    alert("Success");
                },
                failure: function(){
                    alert("File Download Failed");
                }
            })
        }
        else
        {
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
        }
    },

    _deleteItem: function(){
        var sel = this._current_selections[0];

        if(!sel){
            return;
        }

        var type = sel.get('type');
        Ext.Msg.confirm("Delete " + (type == 'folder' ? "Folder" : "File"), "Are you sure you would like to delete this " + (type == 'folder' ? "folder" : "file") + ".",
                function(btn)
                {
                    if(btn == 'yes'){
                        if(type == 'folder' && this._folderTreeGrid.getStore().indexOf(sel) > -1)
                        {
                            this._folderTreeGrid.getSelectionModel().selectRecords([this._folderTreeGrid.getStore().getNodeParent(sel)]);
                        }

                        if(this._folderTreeGrid.loadMask && this._folderTreeGrid.loadMask.show)
                            this._folderTreeGrid.loadMask.show();
                        
                        // do the delete ajax call based on what selection type this is
                        var url = (type == 'folder' ? '/folders/' : '/documents/') + sel.get('id') + '.json';
                        Ext.Ajax.request({
                            url: url,
                            method: 'DELETE',
                            scope: this,
                            callback: function(options, success){
                                if(success)
                                    this.refresh();
                                else
                                    Ext.Msg.alert("Error", "Could not delete " + (type == 'folder' ? "folder" : "file") + ".", function(){this.refresh();}, this);
                            }
                        })
                    }
                }, this
        );
    },

    refresh: function(){
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