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
                {xtype: 'container', itemId: 'topic_grid_holder', region: 'center', layout: 'fit', margins: '5 5 5 0', items: {xtype: 'panel', title:'Topics', frame: true}}
            ],
            reset: this.refresh.createDelegate(this)
        });

        this.getPanel = function() {
            return panel;
        };

        Application.on('forumtopicdeleted', function(){this.refresh();}, this);
    },

    _create_forum_list_grid: function(){
        var store = new Ext.data.JsonStore({
            url: '/forums.json',
            restful: true,
            root: 'forums',
            idProperty: 'id',
            fields: ['name', {name:'hidden_at', type: 'date'}, {name:'created_at', type:'date', dateFormat: 'Y-m-d\\Th:i:sP'}, {name:'updated_at', type:'date', dateFormat: 'Y-m-d\\Th:i:sP'},
                'lock_version', 'id', {name: 'is_moderator', type: 'boolean'}, 'threads'
            ],
            autoLoad: true,
            listeners:{
                scope: this,
                'load': function(store){
                    if(store.reader.getBaseProperty('is_super_admin')){
                        this.forum_grid.getBottomToolbar().getComponent('add_forum_button').show();
                        this.forum_grid.doLayout();
                    }
                }
            }
        });

        var layout_config = {
            region: 'west',
            width: 300,
            margins: '5 0 5 5',
            frame: true,
            split: true,
            title: 'Forums',
            collapsible: true,
            bbar: [{ iconCls:'add_forum', text:'Add Forum', handler: this.create_or_edit_forum,  scope: this, hidden: true, itemId: 'add_forum_button'}]
        };

        var rowActionConfig = {xtype: 'xactioncolumn', icon: '/stylesheets/images/pencil.png', showField: 'is_moderator', handler: function(grid, row){this.create_or_edit_forum(grid.getStore().getAt(row).id);}, scope:this, tooltip: 'Edit'}

        var grid_config = {
            loadMask: true,
            store: store,
            colModel: new Ext.grid.ColumnModel({
                columns: [
                    {id: 'name_column', header: 'Name', sortable: true, dataIndex: 'name', renderer: function(value, p, record){
                        var tip = '' + (record.get("created_at") ? "Created: " + record.get("created_at").format('m-d-Y') + '<br/>' : '' ) +
                                  (record.get("updated_at") ? "Last Post: " + record.get('updated_at').format('m-d-Y') : '');
                        p.attr = 'qtip="' + tip + '" qtitle="' + value + '"';
                        return value;
                    }},
                    {header: 'Created', sortable: true, dataIndex: 'created_at', renderer: Ext.util.Format.dateRenderer('m-d-Y'), hidden: true},
                    {header: 'Updated', sortable: true, dataIndex: 'updated_at', renderer: Ext.util.Format.dateRenderer('m-d-Y'), hidden: true},
                    {header: 'Threads', sortable: true, dataIndex: 'threads', width: 55},
                    rowActionConfig
                ]
            }),
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
        var iconConfig = [
            {icon: '/stylesheets/images/pencil.png', tooltip: 'Edit Topic', showField: 'is_moderator', handler: function(grid, row){this.create_or_edit_topic(grid.getStore().getAt(row).id);}, scope: this },
            {icon: '/stylesheets/resources/images/default/layout/collapse.gif', tooltip: 'Move Topic', showField: 'is_super_admin', handler: function(grid, row){this.move_topic(grid.getStore().getAt(row).id);}, scope: this},
            {icon: '/stylesheets/images/cross-circle.png', tooltip: 'Delete Topic', showField: 'is_super_admin', scope: this, handler: function(grid, row){
                var store = grid.getStore();
                Ext.Msg.confirm("Delete Record", 'Are you sure you wish to delete the topic "' + store.getAt(row).get("name") + '"', function(btn){
                    if(btn === 'yes'){
                        store.removeAt(row);
                    }
                });
            }}
        ];

        var leadIconConfig = [
            {icon: '/images/yellow_thumbtack.png', tooltip: 'Pinned', showField: 'sticky'},
            {icon: '/stylesheets/resources/images/default/grid/hmenu-lock.png', tooltip: 'Closed', showField: 'locked'}
        ];

        var ptoolbar = new Ext.PagingToolbar({
            store: store,
            pageSize: 8,
            buttons:['->', { iconCls:'add_forum', text:'New Topic', handler: function(){this.create_or_edit_topic();}, scope: this}],
            listeners:{
                scope: this,
                'beforechange': function(tb, options){
                    options['page'] = Math.floor(options.start / options.per_page) + 1; 
                    return true;
                }
            }
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
                    {xtype: 'xactioncolumn', items: leadIconConfig, vertical: true},
                    {header: ' ', sortable: false, dataIndex: 'user_avatar', renderer: this.render_user_avatar, width: 75},
                    {id: 'name_column', header: 'Name', sortable: true, dataIndex: 'name', renderer: function(val){
                        return '<span class="inlineLink">' + val + '</span>';
                    }},
                    {header: 'Replies', sortable: true, dataIndex: 'posts', width: 55},
                    {header: 'Poster', sortable: true, dataIndex: 'poster_name', width: 100, renderer: function(val){
                        return '<span class="inlineLink">' + val + '</span>';
                    }},
                    {header: 'Created At', sortable: true, dataIndex: 'created_at', renderer: Ext.util.Format.dateRenderer('n/j/Y h:i:s A'), width: 135},
                    {header: 'Last Updated', sortable: true, dataIndex: 'updated_at', renderer: Ext.util.Format.dateRenderer('n/j/Y h:i:s A'), width: 135},
                    {xtype: 'xactioncolumn', items: iconConfig}
                ]
            }),
            listeners:{
                'cellclick': function(grid, row, column, event){
                    var target = event.getTarget(null, null, true);
                    var fieldName = grid.getColumnModel().getDataIndex(column);
                    var record = grid.getStore().getAt(row);
                    if(target.hasClass('inlineLink') && fieldName == 'name'){
                        Application.fireEvent('opentab', {title: record.get('name'), topic_id: record.id, forum_id: grid.getStore().forumId, initializer: "Talho.Topic", id: 'forum_topic_' + record.id});
                    }
                    else if(target.hasClass('inlineLink') && fieldName == 'poster_name'){
                        Application.fireEvent('opentab', {title: 'User Profile - ' + record.get('poster_name'), url: 'users/' + record.get('poster_id') + '/profile', id: 'user_profile_for_' + record.get('poster_id') });
                    }
                }
            },
            autoExpandColumn: 'name_column',
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
            paramNames:{
                start: 'start',
                limit: 'per_page'
            },
            autoLoad: true,
            fields: ['forum_id', 'comment_id', {name: 'sticky', type:'boolean'}, 'locked_at', {name: 'locked', mapping: 'locked_at', convert: function(val){return val ? true : false;}, type: 'boolean'},
                'name', 'content', 'poster_id', {name:'hidden_at', type: 'date', dateFormat: 'Y-m-d\\Th:i:sP'}, {name: 'poster_name', mapping:'poster.display_name'},
                {name:'created_at', type:'date', dateFormat: 'Y-m-d\\Th:i:sP'}, {name:'updated_at', type:'date', dateFormat: 'Y-m-d\\Th:i:sP'},
                'lock_version', {name:'is_moderator', type:'boolean'}, {name:'is_super_admin', type:'boolean'}, 'id', 'posts', 'user_avatar'
            ],
            url: '/forums/' + record.id + '/topics.json',
            writer: {},
            listeners:{
                scope: this,
                'beforesave': function(){
                    if(!this.topic_grid.saveMask) this.topic_grid.saveMask = new Ext.LoadMask(this.topic_grid.getEl(), {msg: 'Saving...'});
                    this.topic_grid.saveMask.show();
                    return true;
                },
                'save': function(){
                    if(this.topic_grid.saveMask) this.topic_grid.saveMask.hide();
                    this.refresh();
                }
            }
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

        var is_super_admin = this.forum_grid.getStore().reader.getBaseProperty('is_super_admin');
        var items = [];
        if(is_super_admin) items.push({xtype: 'checkbox', boxLabel: 'Pinned', name: 'topic[sticky]', inputValue: '1', plugins:[new Ext.ux.form.SubmitFalse({uncheckedValue: '0'})]});
        items.push({xtype: 'checkbox', boxLabel: 'Hidden', margins:'0 5 0 5', name: 'topic[hide]', inputValue: '1', plugins:[new Ext.ux.form.SubmitFalse({uncheckedValue: '0'})]});
        items.push({xtype: 'checkbox', boxLabel: 'Closed', name: 'topic[locked]', inputValue: '1', plugins:[new Ext.ux.form.SubmitFalse({uncheckedValue: '0'})]});

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
                    {xtype: 'container', layout: 'hbox', hideLabel: true, anchor: '100%', layoutConfig: {pack: 'center'}, items: items},
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

    move_topic: function(topic_id){
        var forum_store = this.forum_grid.getStore();

        var store = new Ext.data.Store({
            reader: new Ext.data.DataReader({}, forum_store.recordType)
        });

        var selected_forum = this.forum_grid.getSelectionModel().getSelected();
        var forums = forum_store.getRange();
        forums.remove(selected_forum);
        store.add(forums);

        var move_topic_window = new Ext.Window({
            title: 'Move Topic',
            width: 300,
            padding: '5',
            modal: true,
            layout: 'form',
            labelAlign: 'top',
            items:[{xtype: 'label', text: this.topic_grid.getStore().getById(topic_id).get('name'), fieldLabel: 'Topic Name'},
                {xtype:'combo', itemId: 'move_window_combo', fieldLabel: 'Forum to move topic to', mode: 'local', triggerAction: 'all', editable: false, store: store, displayField: 'name', valueField: 'id', anchor: '100%'}],
            buttons: [{text: 'Save', scope: this, handler: function(){
                var selected = move_topic_window.getComponent('move_window_combo').getValue();
                if(selected === ''){
                    alert("Please select a forum to move this topic to.");
                    return;
                }

                if(!move_topic_window.saveMask) move_topic_window.saveMask = new Ext.LoadMask(move_topic_window.getLayoutTarget(), {msg: 'Saving...'});
                move_topic_window.saveMask.show();

                Ext.Ajax.request({
                    url: '/forums/' + selected_forum.id + '/topics/' + topic_id + '.json',
                    method: 'PUT',
                    params: {'topic[dest_forum_id]': selected},
                    scope: this,
                    callback: function(options, success, response){
                        move_topic_window.saveMask.hide();
                        if(success){
                            move_topic_window.close();
                            this.refresh();
                        }
                        else
                        {
                            Ext.Msg.alert("Error", response.responseText);
                        }
                    }
                })
            }},
                {text: 'Cancel', handler: function(){move_topic_window.close();}}
            ]
        });

        move_topic_window.show();
    },

    refresh: function(){
        this.forum_grid.getStore().load();
        if(this.topic_grid) this.topic_grid.getStore().load();            
    }
});

Talho.Forums.initialize = function(config) {
    var forums = new Talho.Forums(config);
    return forums.getPanel();
};

Talho.ScriptManager.reg('Talho.Forums', Talho.Forums, Talho.Forums.initialize);