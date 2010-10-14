Ext.namespace('Talho');

Talho.Forums = Ext.extend(function(config){Ext.apply(this, config);}, {
    constructor: function(config)
    {
        Talho.Forums.superclass.constructor.call(this, config);

        this.topic_grid = null;

        var panel = new Ext.Panel({
            title: this.title,
            itemId: this.id,
            closable: true,
            listeners:{
                scope: this
            },
            layout: 'border',
            items:[
                this._create_forum_list_grid(),
                {xtype: 'container', itemId: 'topic_grid_holder', region: 'center', layout: 'fit', margins: '5 5 5 0', items: {xtype: 'panel', title:'Topics', frame: true}}//, items: this._create_topic_list_grid(new Ext.data.JsonStore())}
            ],
            reset: this.refresh.createDelegate(this)
        });

        this.getPanel = function() {
            return panel;
        };
    },

    _create_forum_list_grid: function(){
        var store = new Ext.data.JsonStore({
            url: '/forums.json',
            restful: true,
            root: 'forums',
            idProperty: 'id',
            fields: ['name', {name:'hidden_at', type: 'date'}, {name:'created_at', type:'date'}, {name:'updated_at', type:'date'},
                'lock_version', 'id', {name: 'not_moderator', mapping: 'is_moderator', type: 'boolean', convert: this.inverse_boolean}, 'threads'
            ],
            autoLoad: true
        });

        var layout_config = {
            region: 'west',
            width: 300,
            margins: '5 0 5 5',
            frame: true,
            split: true,
            title: 'Forums',
            collapsible: true,
            bbar: [{ iconCls:'add_forum', text:'Add Forum', handler: this.create_or_edit_forum,  scope: this}]
        };

        var rowActions = new Ext.ux.grid.RowActions({
            keepSelection: true,
            actions:[{iconCls: 'edit_cell', hideIndex: 'not_moderator', cb: function(grid, record){this.create_or_edit_forum(record.id);}.createDelegate(this), qtip: 'Edit'}]
        });

        var grid_config = {
            loadMask: true,
            store: store,
            colModel: new Ext.grid.ColumnModel({
                columns: [
                    {id: 'name_column', header: 'Name', sortable: true, dataIndex: 'name', renderer: function(value, p, record){
                        var tip = "Created: " + record.get("created_at").format('m-d-Y') + '<br/>' +
                                  "Last Post: " + record.get('updated_at').format('m-d-Y');
                        p.attr = 'qtip="' + tip + '" qtitle="' + value + '"';
                        return value;
                    }},
                    {header: 'Created', sortable: true, dataIndex: 'created_at', renderer: Ext.util.Format.dateRenderer('m-d-Y'), hidden: true},
                    {header: 'Updated', sortable: true, dataIndex: 'updated_at', renderer: Ext.util.Format.dateRenderer('m-d-Y'), hidden: true},
                    {header: 'Threads', sortable: true, dataIndex: 'threads', width: 55},
                    rowActions
                ]
            }),
            plugins: [rowActions],
            autoExpandColumn: 'name_column',
            sm: new Ext.grid.RowSelectionModel({
                listeners: {
                    scope: this,
                    'rowselect': this.getForumData
                },
                singleSelect:true
            })
        };

        Ext.apply(grid_config, layout_config);

        this.forum_grid = new Ext.grid.GridPanel(grid_config);

        return this.forum_grid;
    },

    _create_topic_list_grid: function(store){
        var rowActions = new Ext.ux.grid.RowActions({
            actions:[
                {iconCls: 'edit_cell', qtip: 'Edit Topic', hideIndex: 'not_moderator', cb: function(grid, record){this.create_or_edit_topic(record.id);}.createDelegate(this) },
                {iconCls: 'move_topic', qtip: 'Move Topic', hideIndex: 'not_moderator'},
                {iconCls: 'delete_cell', qtip: 'Delete Topic', hideIndex: 'not_super_admin'}
            ]
        });

        var ptoolbar = new Ext.PagingToolbar({
            store: store,
            prependButtons: true,
            buttons:[{ iconCls:'add_forum', text:'New Topic', handler: function(){this.create_or_edit_topic();}, scope: this}, '->']
        });

        this.topic_grid = new Ext.grid.GridPanel({
            frame: true,
            title: 'Topics',
            loadMask: true,
            sm: new Ext.grid.RowSelectionModel({
                singleSelect:true
            }),
            cm: new Ext.grid.ColumnModel({
                columns: [
                    {header: ' ', sortable: false, dataIndex: 'user_avatar', renderer: this.render_user_avatar, width: 75},
                    {id: 'name_column', header: 'Name', sortable: true, dataIndex: 'name'},
                    {header: 'Replies', sortable: true, dataIndex: 'posts', width: 55},
                    {header: 'Created At', sortable: true, dataIndex: 'created_at', renderer: Ext.util.Format.dateRenderer('l M jS Y, h:i:s A'), width: 210},
                    {header: 'Last Updated', sortable: true, dataIndex: 'updated_at', renderer: Ext.util.Format.dateRenderer('l M jS Y, h:i:s A'), width: 210},
                    rowActions
                ]
            }),
            autoExpandColumn: 'name_column',
            plugins: [rowActions],
            bbar: ptoolbar,
            store: store
        });

        return this.topic_grid;
    },

    create_or_edit_forum: function(forum_id) {
        // If it's edit mode, we need to show the window with a load mask, request the forum information, load the information after we get a response and go.
        if(Ext.isNumber(forum_id)){
            var edit_mode = true;
        }

        var create_forum_audience_panel = new Ext.ux.AudiencePanel({
            region: 'center'
        });

        var forum_name_box = new Ext.form.TextField({});
        var forum_hidden_box = new Ext.form.Checkbox({boxLabel: 'Hidden'});

        var create_forum_win = new Ext.Window({
            title: edit_mode ? 'Edite Forum' : 'New Forum',
            layout: 'border',
            width: 600,
            height: 500,
            modal: true,
            items: [
                {xtype: 'container', region: 'north', autoHeight: true, margins: '5', layout: 'form', items: {xtype: 'compositefield', fieldLabel: 'Forum Name', items: [forum_name_box, forum_hidden_box]} },
                create_forum_audience_panel],
            buttons: [{
                text:'Save',
                handler: function(){
                    if(!create_forum_win.saveMask) create_forum_win.saveMask = new Ext.LoadMask(create_forum_win.getLayoutTarget(), {msg: 'Saving...'});
                    create_forum_win.saveMask.show();

                    var name = forum_name_box.getValue();
                    if(name === ""){
                        alert('Please provide a name for this forum.');
                        return;
                    }

                    var selectedItems = create_forum_audience_panel.getSelectedIds();
                    var valid = selectedItems.role_ids.length > 0 || selectedItems.jurisdiction_ids.length > 0 || selectedItems.user_ids.length > 0;
                    if(!valid)
                    {
                        alert('Please select at least one user, jurisdiction, role, or group as an Audience for this forum.');
                        return;
                    }

                    var hidden = forum_hidden_box.getValue();

                    var url = '/forums.json';
                    var method = 'POST';
                    if(edit_mode){
                        url = '/forums/' + forum_id + '.json';
                        method = 'PUT';
                    }

                    Ext.Ajax.request({
                        url: url,
                        method: method,
                        params: {
                            'forum[audience_attributes][jurisdiction_ids][]': selectedItems.jurisdiction_ids,
                            'forum[audience_attributes][role_ids][]': selectedItems.role_ids,
                            'forum[audience_attributes][user_ids][]': selectedItems.user_ids,
                            'forum[hide]': hidden ? '1' : '0',
                            'forum[name]': name
                        },
                        callback: function(options, success, response){
                            create_forum_win.saveMask.hide();
                            if(success){
                                create_forum_win.close();
                                this.refresh();
                            }
                            else{
                                Ext.Msg.alert(response.responseText);
                            }
                        },
                        scope: this
                    });
                },
                scope: this
            },{
                text: 'Cancel',
                handler: function() {
                    create_forum_win.close();
                }
            }]
        });

        if(edit_mode){
            create_forum_win.on('afterrender', function(){
                create_forum_win.loadMask = new Ext.LoadMask(create_forum_win.getLayoutTarget());
                create_forum_win.loadMask.show();
            }, this, {delay: 10});

            Ext.Ajax.request({
                url: '/forums/' + forum_id + '/edit.json',
                callback: function(options, success, response){
                    if(success){
                        create_forum_win.loadMask.hide();
                        var forum_detail = Ext.decode(response.responseText);
                        forum_name_box.setValue(forum_detail.name);
                        forum_hidden_box.setValue(forum_detail.hidden_at ? true : false);
                        Ext.each(forum_detail.audience.users, function(user){user.name = user.display_name;});
                        create_forum_audience_panel.load(forum_detail.audience.jurisdictions,  forum_detail.audience.roles, forum_detail.audience.users);
                    }
                    else{
                        create_forum_win.close();
                    }
                },
                scope: this
            })
        }

        create_forum_win.show();
    },

    render_user_avatar: function(value, metaData, record, rowIndex, colIndex, store) {
        return '<img style="width:65px;height:65px" src="' + value + '" />';
    },

    getForumData: function(sm, rowindex, record) {
        var data_store = new Ext.data.JsonStore({
            restful: true,
            root: 'topics',
            idProperty: 'id',
            totalProperty: 'total_entries',
            forumId: record.id,
            paramsNames:{
                start: 'page',
                limit: 'per_page'
            },
            autoLoad: true,
            fields: ['forum_id', 'comment_id', 'sticky', 'locked_at', 'name', 'content', 'poster_id', {name:'hidden_at', type: 'date'},
                {name:'created_at', type:'date'}, {name:'updated_at', type:'date'}, 'lock_version', {name:'not_moderator',type:'boolean', mapping: 'is_moderator', convert: this.inverse_boolean},
                {name:'not_super_admin', mapping: 'is_super_admin', convert: this.inverse_boolean, type:'boolean'}, 'id', 'posts', 'user_avatar'],
            url: '/forums/' + record.id + '/topics.json'
        });

        if(!this.topic_grid){
            var topic_grid_holder = this.getPanel().getComponent('topic_grid_holder');
            topic_grid_holder.removeAll(true);
            topic_grid_holder.add(this._create_topic_list_grid(data_store));
            topic_grid_holder.doLayout();
        }
        else {
            this.topic_grid.reconfigure(data_store, this.topic_grid.getColumnModel());
            this.topic_grid.getBottomToolbar().bindStore(data_store);
        }
    },

    inverse_boolean: function(v){ return !v;},

    create_or_edit_topic: function(topic_id){
        var edit_mode = false;
        if(Ext.isNumber(topic_id)){
            edit_mode = true;
            var edit_load = {method: 'GET', url: '/forums/' + this.topic_grid.getStore().forumId + '/topics/' + topic_id  + '/edit.json',
                success: function(){
                    topic_window.loadMask.hide();
                },
                failure: function(){
                    alert("There was an issue loading this topic's details.");
                    topic_window.close();
                }
            };
        }

        var topic_window = new Ext.Window({
            title: edit_mode ? 'Edit Topic' : 'New Topic',
            height: 500,
            width: 600,
            layout: 'fit',
            modal: true,
            items: {xtype: 'form',
                url: '/forums/' + this.topic_grid.getStore().forumId + '/topics' + (edit_mode ? '/' + topic_id : '') + '.json',
                method: edit_mode ? 'PUT' : 'POST',
                itemId: 'new_topic_form',
                border: false,
                monitorValid: true,
                padding: '5',
                items: [
                    {xtype: 'textfield', fieldLabel: 'Topic Title', anchor: '100%', name: 'topic[name]', allowBlank: false},
                    {xtype: 'textarea', fieldLabel: 'Topic Content', anchor: '100% -50', name: 'topic[content]'},
                    {xtype: 'container', layout: 'hbox', hideLabel: true, anchor: '100%', layoutConfig: {pack: 'center'}, items:[
                        {xtype: 'checkbox', boxLabel: 'Pinned', name: 'topic[sticky]', inputValue: '1', plugins:[new Ext.ux.form.SubmitFalse({uncheckedValue: '0'})]},
                        {xtype: 'checkbox', boxLabel: 'Hidden', margins:'0 5 0 5', name: 'topic[hide]', inputValue: '1', plugins:[new Ext.ux.form.SubmitFalse({uncheckedValue: '0'})]},
                        {xtype: 'checkbox', boxLabel: 'Closed', name: 'topic[locked]', inputValue: '1', plugins:[new Ext.ux.form.SubmitFalse({uncheckedValue: '0'})]}
                    ]},
                    {xtype: 'hidden', name:'topic[lock_version]', value: '0'}
                ],
                buttons:[
                    {text:'Save', formBind: true, scope: this, handler: function(){
                        if(!topic_window.saveMask) topic_window.saveMask = new Ext.LoadMask(topic_window.getLayoutTarget(), {msg: 'Saving...'});
                        topic_window.saveMask.show();
                        topic_window.getComponent('new_topic_form').getForm().submit({
                            scope: this,
                            success: function(){
                                topic_window.close();
                                this.refresh();
                            },
                            failure: function(form, action){
                                topic_window.saveMask.hide();
                                if(action.result && Ext.isArray(action.result)){
                                    var error = "The following validations failed, please correct and resubmit:\n" + "Field \t Error\n";
                                    Ext.each(action.result, function(el){error = error + el[0].toString() + " \t " + el[1].toString() + "\n";});
                                    alert(error);
                                }
                                else if(action.result && action.result.msg){
                                    alert(action.result.msg);
                                    if(action.result.retry && edit_mode){
                                        topic_window.loadMask.show();
                                        form.load(edit_load);
                                    }
                                    else if(!action.result.retry){
                                        topic_window.close();
                                    }
                                }
                                else if(action.responseText){
                                    alert(action.responseText);
                                }
                                else if(action.failureType == 'client'){
                                    alert("Please correct any validation errors");
                                }
                                else{
                                    alert("An unknown error occurred, please contact your adminsitrator");                                    
                                }
                            }
                        });
                    }},
                    {text: 'Cancel', handler: function(){topic_window.close();} }
                ]
            }
        });

        if(edit_mode){
            topic_window.on('afterrender', function(){
                topic_window.loadMask = new Ext.LoadMask(topic_window.getLayoutTarget());
                topic_window.loadMask.show();
            }, this, {delay: 10});

            var form = topic_window.getComponent('new_topic_form').getForm();
            form.load(edit_load);
        }
        
        topic_window.show();
    },

    refresh: function(){
        this.forum_grid.getStore().load();
        if(this.topic_grid) this.topic_grid.loadMask.show();//.getStore().load();            
    }
});

Talho.Forums.initialize = function(config) {
    var forums = new Talho.Forums(config);
    return forums.getPanel();
};

Talho.ScriptManager.reg('Talho.Forums', Talho.Forums, Talho.Forums.initialize);