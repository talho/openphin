
Ext.ns('Talho');

Talho.ManageGroups = Ext.extend(Ext.util.Observable, {
    constructor: function(config){

        Ext.apply(this, config);

        Talho.ManageGroups.superclass.constructor.call(this, config);

        this.primary_panel = new Ext.Panel({
            layout:'card',
            itemId: config.id,
            layoutOnCardChange: true,
            items: [this._getGroupView(), this._getCreateView()],
            activeItem: 0,
            closable: true,
            defaults:{
                border:false
            },
            title: "Manage Groups"
        });

        this.primary_panel.canGoBack = this.canGoBack.createDelegate(this);
        this.primary_panel.canGoForward = this.canGoForward.createDelegate(this);
        this.primary_panel.back = this.back.createDelegate(this);
        this.primary_panel.forward = this.forward.createDelegate(this);
        
        this.primary_panel.addEvents('afternavigation');

        this.getPanel = function(){ return this.primary_panel; }
    },

    _getGroupView: function(){
        var store = new Ext.data.JsonStore({
            restful: true,
            url: '/admin_groups.json',
            root: 'groups',
            idProperty: 'id',
            remoteSort: 'true',
            totalProperty: 'count',
            fields:['name', 'scope', {name: "owner", mapping: "owner.display_name"}, {name: "owner_id", mapping: "owner.id"}]
        });

        this.group_list = new Ext.list.ListView({
            store: store,
            border: true,
            width: 500,
            height: 300,
            columns: [
                {header: 'Name', dataIndex: 'name'},
                {header: 'Owner', dataIndex: 'owner'},
                {header: 'Scope', dataIndex: 'scope'},
                {tpl: '<span>e</span><span>d</span>'}
            ],
            plugins: ['viewloadmask']
        });

        this.group_display_panel = new Ext.Panel({
            layout:'vbox',
            layoutConfig: {
                padding: '30 0',
                align: 'center'
            },
            defaults:{border:false},
            items:[
                    {xtype:'button', text:'Create New Group', handler: this.showNewGroup, scope: this},
                    {xtype:'panel', border:true, items:[this.group_list]},
                    {xtype:'button', text:'Create New Group', handler: this.showNewGroup, scope: this}
                ],
            listeners:{
                'show': function(){ this.group_list.getStore().load(); },
                scope:this
            }
        });

        return this.group_display_panel;
    },

    _getCreateView: function(){

        var jurisdiction_store = new Ext.data.JsonStore({
            restful: true,
            url: '/jurisdictions/user_alerting',
            idProperty: 'jurisdiction.id',
            fields: [{name: 'name', mapping: 'jurisdiction.name'}, {name: 'id', mapping: 'jurisdiction.id'}]
        });

        jurisdiction_store.load();
        
        this.create_group_form_panel = new Ext.form.FormPanel({
            itemId: 'create_group_form',
            items:[
                {fieldLabel: 'Group Name', xtype:'textfield', name: 'group[name]'},
                {fieldLabel: 'Scope', xtype:'combo', store:['Personal', 'Jurisdiction', 'Global', 'Organization'], editable: false, forceSelection: true},
                {fieldLabel: 'Owner Jurisdition', xtype: 'combo', editable: false, forceSelection: true, store: jurisdiction_store, mode: 'local', valueField: 'id', displayField: 'name', triggerAction: 'all'},
                {items:{xtype:'audiencepanel', width: 500, height: 300, showJurisdictions: true}, border: false}
            ]
        });

        var panel = new Ext.Panel({
            items: [this.create_group_form_panel]
        });
        
        return panel;
    },

    showNewGroup: function(){
        this.primary_panel.layout.setActiveItem(1);
        this.primary_panel.fireEvent('afternavigation', this.primary_panel);
        this.primary_panel.setTitle('Create New Group');
    },

    forward: function(){},

    back: function(){
        if(this.canGoBack())
        {
            this.primary_panel.layout.setActiveItem(0);
            this.primary_panel.fireEvent('afternavigation', this.primary_panel);
            this.primary_panel.setTitle('Manage Groups');
        }
    },

    canGoForward: function(){ return false; },

    canGoBack: function(){
        return this.primary_panel.items.indexOf(this.primary_panel.layout.activeItem) === 1
    }
});

Talho.ManageGroups.initialize = function(config)
{
    var manage_groups = new Talho.ManageGroups(config);
    return manage_groups.getPanel();
};