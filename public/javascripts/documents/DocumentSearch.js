Ext.ns('Talho');

Talho.DocumentSearch = Ext.extend(Ext.Panel, {
    layout: 'border',
    closable: true,

    constructor: function(config){
        Talho.DocumentSearch.superclass.constructor.call(this, config);
    },

    initComponent: function(){
        this.file_actions = new Talho.ux.Documents.FileActions({});

        this.on('afterrender', function(){this.file_actions.download_frame_target = this.getEl();}, this, {delay: 1});

        this.file_store = new Talho.ux.Documents.FileStore({
            url: '/documents/search.json',
            autoLoad: false
        });

        var check_fn = function(){
            this.run_search(this.getComponent('search_form').getComponent('search_box').getValue());
        };

        this.items = [{frame: true,
            itemId: 'search_form',
            layout: 'form',
            region: 'west',
            margins: '5 0 5 5',
            width: 200,
            title: 'Search',
            labelAlign: 'top',
            items: [
                {fieldLabel: 'Search Text', xtype: 'textfield', itemId: 'search_box', enableKeyEvents: true,
                    listeners:{
                        scope: this,
                        'keypress':{
                            fn: function(tf, evt) {
                                var val = tf.getValue();
                                this.run_search(val);
                            },
                            delay: 50
                        }
                    }
                },
                {boxLabel: 'My Files', xtype: 'checkbox', itemId: 'my_files', checked: true, hideLabel: true, scope: this, handler: check_fn },
                {boxLabel: 'Shared Files', xtype: 'checkbox', itemId: 'shared_files', checked: true, hideLabel: true, scope: this, handler: check_fn }
            ]
        },{
            xtype: 'container',
            itemId: 'center_container',
            region: 'center',
            margins: '5 5 5 5',
            layout: 'border',
            items:[{ region:'center',
                itemId: 'result_container',
                title: 'Results',
                frame: true,
                layout: 'fit',
                items: {
                    xtype: 'document-fileiconview',
                    store: this.file_store,
                    listeners: {
                        scope: this,
                        'selectionchange': this.show_selection_detail
                    }
                }
            }, {
                region: 'east', xtype: 'document-filecontrols', itemId: 'file_controls', file_actions: this.file_actions
            }]
        }];

        Talho.DocumentSearch.superclass.initComponent.call(this);
    },

    run_search: function(val){
        if (!Ext.isEmpty(val) && val.length >= 2){
            var own = this.getComponent('search_form').getComponent('my_files').checked;
            var shared = this.getComponent('search_form').getComponent('shared_files').checked;
            if(own || shared){ // We only want to do this if the file is either owned or shared.
                this.file_store.load({
                    params: {
                        text: val,
                        own: own,
                        shared: shared
                    }
                });
            }
        }
    },

    show_selection_detail: function(control){
        var selections = control.getSelectedRecords();
        this.file_actions.current_selections = selections;
        if(selections.length < 1)
            return;

        var sel = selections[0];

        // show download for all, copy when is_owner is false
        var show = ['file_reader_action_container', 'file_detail_container', 'file_search_detail_container'];

        if(!sel.get('is_owner')){
            show.push('copy_action_container');
        }

        if(!this._fileControls)
            this._fileControls = this.getComponent('center_container').getComponent('file_controls');

        this._fileControls.applySectionDetails('file_search_detail_container', {
            'owner': sel.json.owner ? sel.json.owner.display_name : ''
        });

        this._fileControls.applySectionDetails('file_detail_container', {
            'type': Talho.ux.Documents.translateMimeType(sel.get('type')),
            'size': Ext.util.Format.fileSize(sel.get('size')),
            'created_at': Ext.util.Format.date(sel.get('created_at'), 'n/j/y h:i A'),
            'updated_at': Ext.util.Format.date(sel.get('updated_at'), 'n/j/y h:i A')
        });

        this._fileControls.setSectionVisibilities(show);

        this.doLayout();
    }
});

Talho.DocumentSearch.initialize = function(config){
   return new Talho.DocumentSearch(config); 
};

Talho.ScriptManager.reg('Talho.DocumentSearch', Talho.DocumentSearch, Talho.DocumentSearch.initialize);