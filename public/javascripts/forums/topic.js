Ext.ns("Talho");

Talho.Topic = Ext.extend(Ext.util.Observable, {
    constructor: function(config){
        this.addEvents('quotecomment');

        Talho.Topic.superclass.constructor.call(this, config);

        this.tab_config = config;

        var panel_config = {};
        Ext.copyTo(panel_config, this.tab_config, 'forum_id,topic_id,title');

        var store = new Ext.data.JsonStore({
            url: '/forums/' + config.forum_id + '/topics/' + config.topic_id + '.json',
            restful: true,
            autoLoad: false,
            root: 'comments',
            idProperty: 'id',
            fields: ['id', 'content', 'formatted_content', {name: 'user_name', mapping: 'poster.display_name'}, {name: 'user_id', mapping: 'poster.id'}, 'user_avatar', {name: 'created_at', type: 'date', dateFormat: 'Y-m-d\\Th:i:sP'},
                {name: 'updated_at', type: 'date', dateFormat: 'Y-m-d\\Th:i:sP'}, {name: 'is_moderator', type: 'boolean'}, 'comment_id'
            ],
            listeners:{
                scope: this,
                'load': function(){
                    this.getPanel().doLayout();
                },
                'exception':function(proxy, type, action, options, response){
                    if(response.status == 404){
                        alert('This forum topic could not be found and was probably deleted, please refresh your forum list and remove any bookmarked links to it.');
                    }
                    else{
                        alert('There was an issue with loading this topic. Please try again.');
                    }
                    this.getPanel().ownerCt.remove(this.getPanel());
                }
            },
            paramNames:{
                limit: 'per_page'
            }
        });

        var ptoolbar = new Ext.PagingToolbar({
            store: store,
            prependButtons: false,
            pageSize: 20,
            buttons:[
                '->',
                {text: 'Add Reply', iconCls: 'topic-add-comment-button', scope: this,
                    handler: function(){
                        if(!this.comment_window_open){
                            this.show_comment_window();
                        }
                    }
                }
            ],
            listeners:{
                scope: this,
                'beforechange': function(tb, options){
                    options['page'] = Math.floor(options.start / options.per_page) + 1;
                    return true;
                }
            }
        });

        Ext.apply(panel_config, {
            closable: true,
            padding: '5 100 5 100',
            layout: 'hbox',
            autoScroll: true,
            items: [
                {
                    xtype: 'grid',
                    itemId: 'topic_grid',
                    autoHeight: true,
                    flex: 1,
                    store: store,
                    title: this.tab_config.title,
                    frame: true,
                    columns: [
                        {xtype:'templatecolumn', width: 165, tpl: '<div class="topic-user-info-column"><div class="topic-user-name">{user_name}</div><div><img height="100" width="100" src="{user_avatar}"</div><div>Posted: {created_at:date("n/j/y g:i:s A")}</div></div>'},
                        {id: 'post_content_column', xtype: 'templatecolumn', tpl: '<div class="topic-content">{formatted_content}</div>'}
                    ],
                    autoExpandColumn: 'post_content_column',
                    autoExpandMax: 5000,
                    tbar: {
                        items:[
                            '->',
                            {text: 'Add Reply', iconCls: 'topic-add-comment-button', scope: this,
                                handler: function(){
                                    if(!this.comment_window_open){
                                        this.show_comment_window();
                                    }
                                }
                            }
                        ]
                    },
                    bbar: ptoolbar,
                    loadMask: true,
                    viewConfig:{
                        scrollOffset: 0,
                        headersDisabled: true,
                        enableRowBody: true,
                        masterTpl: new Ext.Template(
                            '<div class="x-grid3" hidefocus="true">',
                                '<div class="x-grid3-viewport">',
                                    '<div class="x-grid3-header" style="display:none;">',
                                        '<div class="x-grid3-header-inner">',
                                            '<div class="x-grid3-header-offset" style="{ostyle}">{header}</div>',
                                        '</div>',
                                        '<div class="x-clear"></div>',
                                    '</div>',
                                    '<div class="x-grid3-scroller">',
                                        '<div class="x-grid3-body" style="{bstyle}">{body}</div>',
                                        '<a href="#" class="x-grid3-focus" tabIndex="-1"></a>',
                                    '</div>',
                                '</div>',
                                '<div class="x-grid3-resize-marker">&#160;</div>',
                                '<div class="x-grid3-resize-proxy">&#160;</div>',
                            '</div>'
                        ),
                        getRowClass: function(record, index, rowParams, store){
                            rowParams.body = '<div class="topic-additional-row x-toolbar">&nbsp; <div class="topic-control-buttons">';
                            if(record.get('is_moderator')) rowParams.body += '<span class="topic-delete-comment-button">Delete</span><span class="topic-edit-comment-button">Edit</span>';
                            rowParams.body += '<span class="topic-quote-comment-button">Quote</span></div></div>';
                            return "topic-result-grid";
                        }
                    },
                    listeners:{
                        scope: this,
                        'rowbodyclick': this.topic_row_click
                    }
                }
            ],
            reset: function(){
                this.getPanel().getComponent('topic_grid').getStore().load();
            }.createDelegate(this)
        });
        
        var panel = new Ext.Panel(panel_config);

        panel.on('afterrender', function(){store.load();}, this, {delay: 10});

        this.getPanel = function(){
            return panel;
        }
    },

    topic_row_click: function(grid, rowIndex, e){
        var elem = e.getTarget(null, null, true);
        if(elem.hasClass('topic-edit-comment-button')){
            if(!this.comment_window_open){
                var editRecord = grid.getStore().getAt(rowIndex);
                this.show_comment_window(editRecord);
            }
        }
        else if(elem.hasClass('topic-quote-comment-button')){
            if(!this.comment_window_open){
                this.show_comment_window();
            }
            var quoteRecord = grid.getStore().getAt(rowIndex);
            this.fireEvent('quotecomment', quoteRecord);
        }
        else if(elem.hasClass('topic-delete-comment-button')){
            var deleteRecord = grid.getStore().getAt(rowIndex);

            if(deleteRecord.id == this.tab_config.topic_id){
                var deleteThreadMode = true;
            }

            if(!confirm("Are you sure you want to delete this " + (deleteThreadMode ? 'topic' : 'comment') + "? This action cannot be undone."))
                return;

            if(!grid.saveMask) grid.saveMask = new Ext.LoadMask(grid.getEl(), {msg: 'Saving...'});
            grid.saveMask.show();

            if(!deleteThreadMode){
                Ext.Ajax.request({
                    url: '/forums/' + this.tab_config.forum_id + '/topics/' + this.tab_config.topic_id + '.json',
                    method: 'PUT',
                    params: {
                        'topic[comment_attributes][id]': deleteRecord.id,
                        'topic[comment_attributes][_destroy]': 1
                    },
                    scope: this,
                    callback: function(){
                        grid.saveMask.hide();
                        grid.getStore().load();
                    }
                });
            }
            else{
                Ext.Ajax.request({
                    url: '/forums/' + this.tab_config.forum_id + '/topics/' + this.tab_config.topic_id + '.json',
                    method: 'DELETE',
                    scope: this,
                    callback: function(options, success){
                        grid.saveMask.hide();
                        if(success){
                            this.getPanel().ownerCt.remove(this.getPanel());
                            Application.fireEvent('forumtopicdeleted');
                        }
                        else{
                            alert("We were unable to delete the thread. An administrator has been notified.");
                        }
                    }
                });
            }
        }
    },

    show_comment_window: function(record){
        if(record){
            var edit_mode = true;
        }

        var win = new Ext.Window({
            title: edit_mode ? "Edit Comment" : "New Comment",
            height: 300,
            width: 400,
            layout: 'fit',
            items: [{xtype: 'form',
                itemId: 'comment_form',
                layout: 'anchor',
                border: false,
                items: [{xtype: 'textarea', itemId: 'comment_contents', anchor: '100% -20', hideLabel: true, name: 'topic[comment_attributes][content]'},
                    {xtype:'box', anchor: '100% b', autoEl:{tag: 'a', href: 'http://redcloth.org/hobix.com/textile/quick.html'}, html: 'Textile Quick Reference'}],
                buttons:[
                    {text: 'Save', scope: this, handler: function(){
                        var formPanel = win.getComponent('comment_form');
                        var form = formPanel.getForm();

                        var params = {
                            'topic[comment_attributes][forum_id]': this.tab_config.forum_id,
                            'topic[comment_attributes][name]': (new Date()).format('D M j G:i:s O Y')
                        };
                        if(edit_mode){
                            params['topic[comment_attributes][id]'] = record.id;
                        }

                        if(!win.saveMask) win.saveMask = new Ext.LoadMask(win.getLayoutTarget(), {msg: 'Saving...'});
                        win.saveMask.show();

                        form.submit({
                            url: '/forums/' + this.tab_config.forum_id + '/topics/' + this.tab_config.topic_id + '.json',
                            method: 'PUT',
                            params:params,
                            scope: this,
                            success: function(form, action){
                                win.saveMask.hide();
                                win.close();
                                this.getPanel().getComponent('topic_grid').getStore().load();
                            },
                            failure: function(form, action){
                                win.saveMask.hide();
                                var result = Ext.decode(action.responseText);
                                if(Ext.isArray(result)){
                                    alert('There was an error with validation: ' + Ext.flatten(result).join(', '));
                                }
                                else if(result && result.msg){
                                    alert(result.msg);
                                }
                                else{
                                    alert(action.responseText);
                                }
                            }
                        });
                    }},
                    {text: 'Cancel', handler: function(){win.close();}}
                ]
            }],
            listeners: {
                scope: this,
                'beforeaction': function(form, action){
                    action.params = action.params || {};


                    return true;
                }
            }
        });

        var add_quote = function(record){
            var form = win.getComponent('comment_form');
            var comment_area = form.getComponent('comment_contents');
            comment_area.setValue(comment_area.getValue() + 'bq.. __Originally posted by: ' + record.get('user_name') + '__\r\n\r\n' + record.get('content') + '\r\n\r\np. ');
            comment_area.focus(false, 10);
        };

        this.on('quotecomment', add_quote, this);

        win.on('close', function(){
            this.comment_window_open = false;
            this.un('quotecomment', add_quote, this)
        }, this);

        var form = win.getComponent('comment_form');
        var comment_area = form.getComponent('comment_contents');

        if(edit_mode){
            comment_area.setValue(record.get('content'));
        }
            
        win.show();
        this.comment_window_open = true;
        comment_area.focus(false, 10);
        comment_area.focus(false, 500);
    }
});

Talho.Topic.initialize = function(config){
    var topic = new Talho.Topic(config);
    return topic.getPanel();
};

Talho.ScriptManager.reg('Talho.Topic', Talho.Topic, Talho.Topic.initialize);