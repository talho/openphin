Ext.ns('Talho.ux.documents');

Talho.ux.documents.AddEditFolderWindow = Ext.extend(Ext.Window,  {
    height: 600,
    width: 500,
    title: 'Add Folder',
    modal: true,

    constructor: function(config){
        this.addEvents('foldercreated');

        var cb = Ext.extend(Ext.form.Checkbox, {
            anchor: '100%',
            inputValue: 'true',
            uncheckedValue: 'false',
            plugins: [new Ext.ux.form.SubmitFalse({uncheckedValue: 'false'})]
        });

        Ext.apply(config, {
            layout: 'fit',
            items: {
                xtype: 'tabpanel',
                itemId: 'tp',
                border: false,
                activeTab: 0,
                items:[
                    {itemId: 'form', title: 'General Options', xtype:'form', padding: '5', items:[
                            {xtype: 'hidden', name: config.isEdit? 'folder_id': 'folder[parent_id]', value: config.selectedFolder.get('id') },
                            {xtype: 'field', fieldLabel: 'Folder Name', name: 'folder[name]', anchor: '100%'},
                            new cb({boxLabel: 'Notify users when files are added to this folder.', name: 'folder[notify_of_document_addition]'}),
                            new cb({boxLabel: 'Notify users when they have been invited to share this folder.', name: 'folder[notify_of_audience_addition]'}),
                            new cb({boxLabel: 'Notify the uploader the first time a user downloads a file within this folder.', name: 'folder[notify_of_file_download]'}),
                            new cb({boxLabel: 'Expire documents in this folder after 30 days.', name: 'folder[expire_documents]', checked: true}),
                            new cb({boxLabel: 'Notify the uploader 5 days before files expire.', name: 'folder[notify_before_document_expiry]', checked: true})
                        ],
                        url: '/folders' + (config.isEdit ? '/' + config.selectedFolder.get('id') : '') + '.json',
                        method: config.isEdit ? 'PUT' : 'POST',
                        listeners: {
                            scope: this,
                            'beforeaction': function(form, action){
                                if(action.type == 'submit')
                                {
                                    action.options.params = action.options.params || {};

                                    var rg = this.getComponent('tp').getComponent('sh').getComponent('rh').getComponent('rg');
                                    if(rg.getValue()){
                                        action.options.params['folder[shared]'] = rg.getValue().getRawValue();
                                        if(action.options.params['folder[shared]'] == 'shared'){
                                            var selectedItems = this.getComponent('tp').getComponent('sh').getComponent('ap').getSelectedIds();
                                            Ext.apply(action.options.params, {
                                                'folder[audience][jurisdiction_ids][]': selectedItems.jurisdiction_ids,
                                                'folder[audience][role_ids][]': selectedItems.role_ids,
                                                'folder[audience][user_ids][]': selectedItems.user_ids
                                            });

                                        }
                                    }

                                    try // wrap this in a try/catch block because getting the permissions component will totally bomb out when it hasn't been rendered yet
                                    {
                                        var permissions = this.getComponent('tp').getComponent('per').getComponent('perholder').getForm().getFieldValues();
                                        var vals = [];
                                        for(var k in permissions){
                                            if(k.match(/folder\[permissions\]\[\d+\]\[user_id\]/) !== null){
                                                var index = k.match(/\d+/)[0];
                                                var p = permissions['folder[permissions][' + index + '][permission]'];
                                                var u = permissions[k];
                                                vals.push({user_id: u, permission: p});
                                            }
                                        }

                                        action.options.params['folder[permissions]'] = Ext.encode(vals);
                                    }
                                    catch(e){}
                                }
                                return true;
                            }
                        }
                    },
                    {title: 'Sharing', itemId: 'sh', layout: 'vbox', layoutConfig: {align: 'stretch'}, padding: '5', items:[
                        {xtype:'container', itemId: 'rh', layout: 'form', labelAlign: 'top', items:[
                            {xtype: 'radiogroup', itemId: 'rg', columns: 1, fieldLabel: 'Share As', anchor: '100%', items:[
                                {itemId: 'in', boxLabel: 'Inherited', name: 'sharing', checked: config.isEdit? false : true, inputValue: 'inherited'},
                                {itemId: 'ns', boxLabel: 'Not Shared', name: 'sharing', inputValue: 'not_shared'},
                                {itemId: 'sh', boxLabel: 'Shared - Accessible to the audience specified below', name: 'sharing', inputValue: 'shared', scope: this, handler: function(cb, checked){
                                    if(checked){
                                        this.getComponent('tp').getComponent('sh').getComponent('ap').enable();
                                        this.getComponent('tp').getComponent('per').getComponent('perlabel').hide();
                                        this.getComponent('tp').getComponent('per').getComponent('perholder').show();
                                    }
                                    else{
                                        this.getComponent('tp').getComponent('sh').getComponent('ap').disable();
                                        this.getComponent('tp').getComponent('per').getComponent('perholder').hide();
                                        this.getComponent('tp').getComponent('per').getComponent('perlabel').show();
                                    }
                                }}],
                                getComponent: function(itemId){
                                    var col = new Ext.util.MixedCollection(false, function(item){return item.itemId;});
                                    col.addAll(this.items);
                                    return col.get(itemId);
                                }
                            }
                        ]},
                        {itemId: 'ap', xtype: 'audiencepanel', flex: 1, disabled: true, showJurisdictions: false, showRoles: false}
                    ]},
                    {title: 'Permissions', itemId: 'per', padding: '5', items:[
                        {itemId: 'perlabel', xtype: 'box', html: 'Permissions are only available when this folder is explicitly shared.'},
                        {itemId: 'perempty', xtype: 'box', hidden: true, html: 'You must select a user in order to apply a specific permission to this folder.'},
                        {itemId: 'perholder', xtype: 'form', border: false, hidden: true, autoScroll: true}
                    ], listeners:{
                        scope: this,
                        'show': function(){
                            this._fillPermissionsForm();
                        }
                    }}
                ],
                buttons:[
                    {text: 'Save', scope: this, handler: function(){
                        var form = this.getComponent('tp').getComponent('form').getForm();
                        form.submit({scope: this,
                            waitMsg: 'Saving...', 
                            success: function(){
                                this.fireEvent('foldercreated');
                                this.close();
                            },
                            failure: function(){
                                Ext.Msg.alert('Error', 'There was a problem saving this folder');
                            }
                        });
                    }},
                    {text: 'Cancel', scope: this, handler: function(){this.close()}}
                ]
            }
        });

        this.on('afterrender', function(){this.getComponent('tp').getComponent('form').getForm().waitMsgTarget = this.getLayoutTarget();});

        if(config.isEdit){
            this.title = 'Edit Folder';
            this.on('afterrender', function(){
                this.getComponent('tp').getComponent('form').getForm().load({url:'/folders' + (config.isEdit ? '/' + config.selectedFolder.get('id') : '') + '/edit.json', waitMsg: 'Loading...', method: 'GET', scope: this,
                    success: function(form, action){
                        this.loaded_data = action.result.data;

                        // set up audience panel and permissions selections here
                        var rg = this.getComponent('tp').getComponent('sh').getComponent('rh').getComponent('rg');
                        var rb = null;
                        switch(action.result.data['folder[shared]']){
                            case 'shared': rb = rg.getComponent('sh');
                                this.getComponent('tp').getComponent('per').getComponent('perlabel').hide();
                                this.getComponent('tp').getComponent('per').getComponent('perholder').show();
                                break;
                            case 'not_shared': rb = rg.getComponent('ns');
                                break;
                            case 'inherited':
                            default: rb = rg.getComponent('in');
                                break;
                        }
                        if(rb.setValue)
                            rb.setValue(true);
                        else
                            rb.checked = true;

                        var audience = this.incoming_audience = action.result.data['folder[audience]'];
                        if(audience){
                            Ext.each(audience.users, function(user){user.name = user.display_name;});
                            var ap = this.getComponent('tp').getComponent('sh').getComponent('ap');
                            if(!ap.rendered){
                                ap.on('afterrender', function(){
                                    ap.load(audience.jurisdictions,  audience.roles, audience.users, audience.groups);
                                    if(action.result.data['folder[shared]'] == 'shared'){
                                        ap.enable();
                                    }
                                    ap.doLayout();
                                }, this, {delay: 10});
                            }
                            else{
                                ap.load(audience.jurisdictions,  audience.roles, audience.users, audience.groups);
                                if(action.result.data['folder[shared]'] == 'shared'){
                                    ap.enable();
                                }
                            }
                        }
                    },
                    failure: function(){
                        Ext.Msg.alert("Error", "There was a problem loading the information for this folder. An Administrator has been notified.");
                        this.close();
                    }
                });
            }, this, {delay: 10});
        }

        Talho.ux.documents.AddEditFolderWindow.superclass.constructor.call(this, config);
    },

    _fillPermissionsForm: function(){
        var ap = this.getComponent('tp').getComponent('sh').getComponent('ap');
        var audience = null;
        if(!ap.rendered){
            audience = this.incoming_audience;
        }
        else{
            audience = ap.getSelectedItems();
        }

        var per_form = this.getComponent('tp').getComponent('per').getComponent('perholder');

        // get values
        var vals = new Ext.util.MixedCollection();
        try
        {
            var gval_results = [];
            if(per_form.rendered)
                gval_results = per_form.getForm().getValues();
            else
                gval_results =  this.loaded_data;

            for(var k in gval_results){
                if(k.match(/folder\[permissions\]\[\d+\]\[user_id\]/) !== null){
                    var index = k.match(/\d+/)[0];
                    var p = gval_results['folder[permissions][' + index + '][permission]'];
                    var u = gval_results[k];
                    vals.add({user_id: u, permission: p});
                }
            }
        }
        catch(e){

        }

        // clear form
        per_form.removeAll(true);

        this.getComponent('tp').getComponent('per').getComponent('perempty').hide();

        if(audience && ap.rendered && this.getComponent('tp').getComponent('sh').getComponent('rh').getComponent('rg').getValue().getRawValue() === 'shared' && audience.users.length < 1){
            this.getComponent('tp').getComponent('per').getComponent('perempty').show();
        }
        else if(audience)
        {
            // write new form rows, include already selected values
            Ext.each(audience.users, function(user, index){
                var v_index = vals.findIndex('user_id', user.id);
                var val = v_index != -1 ? vals.get(v_index).permission : 0;
                per_form.add([
                    {xtype: 'combo', mode: 'local', triggerAction: 'all', editable: false, fieldLabel: user.display_name || user.name, hiddenName: 'folder[permissions][' + index + '][permission]', store: [[0, 'Reader'], [1, 'Author'], [2, 'Admin']], value: val},
                    {xtype: 'hidden', name: 'folder[permissions][' + index + '][user_id]', value: user.id}
                ]);
            }, this);
        }

        // make sure it lays out
        this.doLayout();
    }
});