Ext.ns('Talho.ux.Documents');

(function(){
    Talho.ux.Documents.translateMimeType = function(mime){
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
    };

    Talho.ux.Documents.mimeToImageClass = function(type){
       switch(Talho.ux.Documents.translateMimeType(type)){
                case 'image': return 'documents-folder-item-image-icon';
                case 'video': return 'documents-folder-item-video-icon';
                case 'audio': return 'documents-folder-item-audio-icon';
                case 'folder': return 'documents-folder-item-folder-icon';
                case 'document': return 'documents-folder-item-doc-icon';
                case 'spreadsheet': return 'documents-folder-item-spreadsheet-icon';
                case 'presentation': return 'documents-folder-item-presentation-icon';
                default: return 'documents-folder-item-file-icon';
            }
    };

    var tpl = new Ext.XTemplate(
        '<tpl for=".">',
            '<div class="documents-folder-item">',
                '<div class="documents-folder-item-icon {[this.icon_class(values.type)]}"></div>',
                '<div unselectable="on">{name}</div>',
            '</div>',
        '</tpl>',
        { compiled: true,
          icon_class: function(type){
            return Talho.ux.Documents.mimeToImageClass(type);
          }
        }
    );

    Talho.ux.Documents.FileIconView = Ext.extend(Ext.DataView, {
        xtype: 'dataview',
        autoScroll: true,
        itemId: 'file_icon_view',
        cls: 'document-file-icon-view',
        tpl: tpl,
        loadingText: 'Loading...',
        emptyText: 'This folder is empty',
        itemSelector: 'div.documents-folder-item',
        overClass: 'documents-folder-item-hover',
        selectedClass: 'documents-folder-item-selected',
        singleSelect: true
    });

    Ext.reg('document-fileiconview', Talho.ux.Documents.FileIconView);

    Talho.ux.Documents.FileStore = Ext.extend(Ext.data.Store, {
        restful: true,
        reader: new Ext.data.JsonReader({
            root: 'files',
            idProperty: 'id_property_that_will_never_be_used_damn_you_store',
            fields: [{name: 'name', sortType: Ext.data.SortTypes.asUCString}, {name:'type', mapping:'ftype'}, {name:'size', mapping: 'file_file_size'},
                'id', {name: 'created_at', type: 'date', dateFormat: 'Y-m-d\\Th:i:sP'}, {name: 'updated_at', mapping: 'file_updated_at', type: 'date', dateFormat: 'Y-m-d\\Th:i:sP'}, 'doc_path',
                {name:'is_owner', type: 'boolean'}, {name:'is_author', type: 'boolean'}]
        })
    });

    var file_control_button = Ext.extend(Ext.Button, {
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
    });

    Talho.ux.Documents.FileActions = Ext.extend(Ext.util.Observable, {
        constructor: function(config){
            this.addEvents('refresh');
            Ext.apply(this, config);
            Talho.ux.Documents.FileActions.superclass.constructor.apply(this, arguments);
        },

        folder_tree: null,
        download_frame_target: null,
        current_selections: null,

        createNewFolder: function(mode){
            var sel = this.current_selections ? this.current_selections[0] : this.folder_tree.getStore().getAt(0) ;
            if(sel.get('type') !== 'folder' && !(sel.get('type') == 'share' && sel.get('is_owner')))
                sel = this.folder_tree.getSelectionModel().getSelected();

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

        uploadFile: function(mode){
            var sel = this.current_selections[0],
                folder = this.folder_tree.getSelectionModel().getSelected(),
                win;
            
            if(mode === 'replace'){
              fields = [{xtype: 'hidden', name: '_method', value: 'PUT'},
                        {xtype: 'textfield', inputType: 'file', fieldLabel: 'File', name: 'document[file]', anchor: '100%'}
              ];
                       
              win = new Ext.Window({width: 470, height: 120, title: 'Replace Document', modal: true,
                  items:[{itemId: 'upload_form', xtype: 'form', fileUpload: true, padding: '5', labelWidth: 30, items: fields,
                      buttons: [
                          {text: 'Save', scope: this, handler: function(){
                              var form = win.getComponent('upload_form').getForm();
                              form.waitMsgTarget = win.getLayoutTarget();
                              form.submit({
                                  waitMsg: 'Saving...',
                                  url: '/documents/' + sel.get('id') + '.json',
                                  method: 'PUT',
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
            }
            else{
              win = new Ext.Window({width: 400, height: 200, autoScroll: true, title: 'New Documents', folder_id: folder.get('id'), modal: true, items:{xtype:'box'},
                buttons:[{text: 'OK', scope: this, handler: function(){
                  win.close();
                  this.refresh();
                }}],
                listeners: {
                  'afterrender': {
                    scope: this,
                    delay: 1,
                    fn: function(){
                      var uploader = new qq.FileUploader({
                        element: win.getComponent(0).getEl().dom,
                        params: {
                          folder_id: folder.get('id')
                        },
                        action: '/documents.json'
                      });
                    }
                  }
                }
              });
            }
            win.show();
        },

        moveItem: function(mode){
            var sel = this.current_selections[0];
            var type = sel.get('type');

            if(sel.get('id') == null || sel.get('id') == 'null') return;

            var win = new Ext.Window({width: 350, height: 100, title: mode == 'copy' ? 'Copy': 'Move ' + (type == 'folder' ? 'Folder' : 'File'), modal: true,
                items: {itemId: 'move_form', xtype: 'form', border: false, padding: '5', items:[
                    {xtype: 'combo', fieldLabel: 'Move to', mode: 'local', triggerAction: 'all', hiddenName: 'parent_id', valueField: 'id', displayField: 'name', editable: false, allowBlank: false, store: new Ext.data.JsonStore({
                        url: '/folders/target_folders' + (type == 'folder' || type == 'organization' || type == 'share' ? '?folder_id=' + sel.get('id') : ''),
                        fields: ['name', 'id'],
                        idProperty: 'id',
                        autoLoad: true
                    })}
                ]},
                buttons: [
                    {text: 'Save', scope: this, handler: function(){
                        var form = win.getComponent('move_form').getForm();
                        form.waitMsgTarget = win.getLayoutTarget();
                        var url = (type == 'folder' || type == 'organization' || type == 'share' ? '/folders/' + sel.get('id') + '/move.json' : '/documents/' + sel.get('id') + '/' + (mode == 'copy' ? 'copy' : 'move') + '.json');
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

        downloadFile: function(){
            // create a hidden iframe, open the file
            if(Application.rails_environment === 'cucumber')
            {
                Ext.Ajax.request({
                    url: this.current_selections[0].get('doc_path'),
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
                    this._downloadFrame = Ext.DomHelper.append(this.download_frame_target.dom, {tag: 'iframe', style: 'width:0;height:0;'});
                    Ext.EventManager.on(this._downloadFrame, 'load', function(){
                        // in a very strange bit of convenience, the frame load event will only fire here IF there is an error
                        // need to test the convenience on IE.
                        Ext.Msg.alert('Could Not Load File', 'There was an error downloading the file you have requested. Please contact an administrator');
                    }, this);
                }

                if(this.current_selections.length > 0){
                    this._downloadFrame.src = window.location.protocol + "//" + window.location.host + this.current_selections[0].get('doc_path');
                }
            }
        },

        deleteItem: function(){
            var sel = this.current_selections[0];

            if(!sel){
                return;
            }

            var type = sel.get('type');
            if (type == 'folder' || type == 'organization' || type == 'share') {type = 'folder'}
            Ext.Msg.confirm("Delete " + (type == 'folder' ? "Folder" : "File"), "Are you sure you would like to delete this " + (type == 'folder' ? "folder" : "file") + ".",
                    function(btn)
                    {
                        if(btn == 'yes'){
                            if(type == 'folder' && this.folder_tree.getStore().indexOf(sel) > -1)
                            {
                                this.folder_tree.getSelectionModel().selectRecords([this.folder_tree.getStore().getNodeParent(sel)]);
                            }

                            if(this.folder_tree.loadMask && this.folder_tree.loadMask.show)
                                this.folder_tree.loadMask.show();

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
            this.fireEvent('refresh');
        }
    });

    Talho.ux.Documents.FileControls = Ext.extend(Ext.Panel, {width: 200, split: true, defaultType: 'container',
        file_actions: null,

        initComponent: function(){
            this.items = [
                { xtype: 'panel', defaultType: 'container', cls:'document-file-controls-sub-panel', items:[
                    { itemId: 'file_detail_container', hidden: true, layout: 'form', defaultType: 'displayfield', defaults:{style:{'padding-top': '3px'}}, labelWidth: 65, items:[
                        {itemId: 'image', xtype:'imagedisplayfield', value: ''},
                        {itemId: 'name', hideLabel: true, cls: 'document-detail-name-field', value: 'name'},
                        {itemId: 'size', fieldLabel: 'File Size', value: '150 kb'},
                        {itemId: 'created_at', fieldLabel: 'Created At', value: '10/10/2020'},
                        {itemId: 'updated_at', fieldLabel: 'Modified At', value: '10/10/2021'}
                    ]},
                    { itemId: 'folder_detail_container', hidden: true, layout: 'form', defaultType: 'displayfield', defaults:{style:{'padding-top': '3px'}}, labelWidth: 65, items:[
                        {itemId: 'image', xtype:'imagedisplayfield', value: ''},
                        {itemId: 'name', hideLabel: true, cls: 'document-detail-name-field', value: 'name'},
                        {itemId: 'created_at', fieldLabel: 'Created At', value: '10/10/2020'},
                        {itemId: 'updated_at', fieldLabel: 'Modified At', value: '10/10/2021'}
                    ]},
                    { itemId: 'file_search_detail_container', hidden: true, layout: 'form', defaultType: 'displayfield', defaults:{style:{'padding-top': '3px'}}, labelWidth: 65, items:[
                        {itemId: 'owner', fieldLabel: 'Owner', value: 'text/css'}
                    ]},
                    { itemId: 'file_reader_action_container', hidden: true, items:[
                            new file_control_button({text: 'Download File', iconCls: 'documents-download-icon', handler: this.file_actions.downloadFile, scope: this.file_actions}),
                            new Ext.menu.Separator({})
                    ]},
                    { itemId: 'file_action_container', hidden: true, items:[
                            new file_control_button({text: 'Download File', iconCls: 'documents-download-icon', handler: this.file_actions.downloadFile, scope: this.file_actions}),
                            new file_control_button({text: 'Replace File', iconCls: 'documents-replace-icon', handler: this.file_actions.uploadFile.createDelegate(this.file_actions, ['replace'])}),
                            new file_control_button({text: 'Delete File', iconCls: 'documents-delete-file-icon', handler: this.file_actions.deleteItem, scope: this.file_actions}),
                            new Ext.menu.Separator({})
                    ]},
                    { itemId: 'folder_action_container', hidden: true, items:[
                            new file_control_button({text: 'Edit Folder', iconCls: 'documents-edit-folder-icon', handler: this.file_actions.createNewFolder.createDelegate(this.file_actions, ['edit'])}),
                            new file_control_button({text: 'Delete Folder', iconCls: 'documents-delete-folder-icon', handler: this.file_actions.deleteItem, scope: this.file_actions}),
                            new Ext.menu.Separator({})
                    ]},
                    { itemId: 'move_action_container', hidden: true, items: [
                        new file_control_button({itemId: 'move_selection', text: 'Move Selection', iconCls: 'documents-move-icon', handler: this.file_actions.moveItem, scope: this.file_actions})
                    ]},
                    { itemId: 'copy_action_container', hidden: true, items: [
                        new file_control_button({itemId: 'copy_file', text: 'Copy to My Folders', iconCls: 'documents-move-icon', handler: this.file_actions.moveItem.createDelegate(this.file_actions, ['copy'])})
                    ]}
                ]},
                { itemId: 'base_actions', hidden: true, items: [
                    new file_control_button({text: 'Create New Folder', iconCls: 'documents-add-folder-icon', handler: this.file_actions.createNewFolder, scope: this.file_actions}),
                    new file_control_button({text: 'Upload New File', iconCls: 'documents-add-icon', handler: this.file_actions.uploadFile, scope: this.file_actions})
                ]},
                { itemId: 'author_actions', hidden: true, items: [
                    new file_control_button({text: 'Upload New File', iconCls: 'documents-add-icon', handler: this.file_actions.uploadFile, scope: this.file_actions})
                ]}
            ];

            Talho.ux.Documents.FileControls.superclass.initComponent.call(this);
        },

        setSectionVisibilities: function(show, hide){
            if(!hide){
                var allItems = new Ext.util.MixedCollection();
                allItems.addAll(Ext.clean(this._findAllChildrenItemIds(this.items.getRange())));
                Ext.each(show, function(s){allItems.remove(s);});
                hide = allItems.getRange();
            }
            Ext.each(show, function(s){this.findComponent(s).show();}, this);
            Ext.each(hide, function(h){this.findComponent(h).hide();}, this);
        },

        _findAllChildrenItemIds: function(items){
            var itemIds = [];
            Ext.each(items, function(item){
                if(item.isXType('panel', true)){
                    itemIds = itemIds.concat(this._findAllChildrenItemIds(item.items.getRange()));
                }
                else{
                    itemIds.push(item.itemId);
                }
            }, this);
            return itemIds;
        },

        findComponent: function(cstring){
            var c = this.getComponent(cstring);
            if(!c){
                ps = this.findByType('container', false); // find any containers, panels, etc
                Ext.each(ps, function(p){
                    var ct = p.getComponent(cstring);
                    if(ct){
                        c = ct;
                        return false;
                    }
                })
            }
            return c;
        },

        applySectionDetails: function(container, values){
            if(Ext.isString(container)){
                var container = this.findComponent(container);
            }
            for(var val in values){
                if(container.getComponent(val)) container.getComponent(val).setValue(values[val]).show();
            }
        }
    });

    Ext.reg('document-filecontrols', Talho.ux.Documents.FileControls);
})();