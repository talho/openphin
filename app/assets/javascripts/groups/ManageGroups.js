//= require audience/AudienceDisplayPanel
//= require ext_extensions/xActionColumn
//= require_tree ./view
//= require_self

Ext.ns('Talho');

/**
 * Talho.ManageGroups creates a card layout panel that manages a set of 3 panels: Group Lists, Create Group, and Group Detail
 * @param  {Object}  config  configuration for Manage Groups - In this case, for now, it's empty
 */
Talho.ManageGroups = Ext.extend(Ext.util.Observable, {
    /**
      * @lends Talho.ManageGroups.prototype
      */
    constructor: function(config){

        Ext.apply(this, config);

        Talho.ManageGroups.superclass.constructor.call(this, config);

        this.primary_panel = new Ext.Panel({
            layout:'card',
            itemId: config.id,
            layoutOnCardChange: true,
            items: [this._getGroupView(), this._getCreateView(),
                this._getGroupDetailView()],
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

    /**
         * Creates the group view for listing a user's groups
         */
    _getGroupView: function(){
        return this.group_display_panel = new Talho.Groups.View.List({
          listeners: {
            scope: this,
            'newgroup': this.showNewGroup,
            'groupdetail': this.showGroupDetail
          }
        });
    },

    /**
         * Creates the create/edit view fields: name, scope, owner jurisdiction, and the audience panel
         */
    _getCreateView: function(){
        return this.create_group_container = new Talho.Groups.View.CreateEdit({itemId: 'create_group_form_holder',
          listeners:{
            scope: this,
            'savecomplete': this.showGroupDetail,
            'cancel': this.back
          }
        });
    },

    /**
         * Create the group detail view which displays the same information as is in the create/edit form except is not editable from this page
         */
    _getGroupDetailView: function(){
      return this.group_detail_pane = new Talho.Groups.View.Detail({
        listeners: {
          scope: this,
          'back': this.back
        }
      });
    },
    
    /**
         * Shows the create group form
         */
    showNewGroup: function(groupId){
        if(Ext.isNumber(groupId))
        {
          this.create_group_container.prepareEdit(groupId);
          this.primary_panel.setTitle('Edit Group');
        }
        else
        {
          this.create_group_container.prepareCreate();
          this.primary_panel.setTitle('Create New Group');
        }

        this.primary_panel.layout.setActiveItem(1);
        this.primary_panel.fireEvent('afternavigation', this.primary_panel);
    },

    /**
         * Shows the group detail form
         * @param   {Object/Int}    group   Either an object representation of the group or the group ID that we will be looking up
         */
    showGroupDetail: function(group){
      this.group_detail_pane.showGroupDetail(group);
      this.primary_panel.layout.setActiveItem(2);
      this.primary_panel.fireEvent('afternavigation', this.primary_panel);
      this.primary_panel.setTitle('Group Detail');
    },

    /**
         * You can never go forward, only back
         */
    forward: function(){},

    /**
         * Handler for the back method, always goes to the Group List card
         */
    back: function(){
        if(this.canGoBack())
        {
            this.primary_panel.layout.setActiveItem(0);
            this.primary_panel.fireEvent('afternavigation', this.primary_panel);
            this.primary_panel.setTitle('Manage Groups');
        }
    },

    /**
         * You can never go forward
         */
    canGoForward: function(){ return false; },

    /**
         * If we're not on the group list card, we can go back
         */
    canGoBack: function(){
        return this.primary_panel.items.indexOf(this.primary_panel.layout.activeItem) !== 0
    }
});

/**
 * Initializer for the ManageGroup object. Returns a panel
 * @param   {Ojbect}    config  Configuration for the ManageGroups panel
 */
Talho.ManageGroups.initialize = function(config)
{
    var manage_groups = new Talho.ManageGroups(config);
    return manage_groups.getPanel();
};

Talho.ScriptManager.reg('Talho.ManageGroups', Talho.ManageGroups, Talho.ManageGroups.initialize);
