
Ext.ns('Talho.Groups.View')

Talho.Groups.View.Detail = Ext.extend(Ext.Container, {
  layout: 'hbox',
  layoutConfig: {pack: 'center'},
  autoScroll: true,

  initComponent: function(){
    this.addEvents('back');

    this.group_detail_panel = new Ext.Panel({
      layout: 'form',
      border: false,
      width: 600,
      padding: '10 0 0',
      items: [
        {xtype: 'box', hideLabel: true, cls:'group_name', itemId:'group_name', style: 'font-size: 200%; padding-bottom: 5px; font-weight: bold;', html: 'NAME'},
        {xtype: 'box', cls: 'group_scope', itemId: 'group_scope', fieldLabel: 'Scope', style: 'font-size: 150%;', html: 'SCOPE'},
        {xtype: 'box', cls: 'group_owner_jurisdiction', itemId: 'group_jurisdiction', fieldLabel: 'Jurisdiction', style: 'font-size: 120%;', html: 'JURISDICTION'},
        new Ext.ux.AudienceDisplayPanel({itemId: 'group_audience_panel', hideLabel: true, anchor: '100%', height: 400})
      ],
      buttons: [
        {xtype: 'button', text: 'Back to Groups', scope: this, handler: function(){this.fireEvent('back');}}
      ]
    });

    this.group_detail_panel.on('render', function(panel){
      if(panel.mask === true){
        var showAfter = true;
      }

      panel.mask = new Ext.LoadMask(panel.ownerCt.getEl());
      if(showAfter){
        panel.mask.show();
      }
    });

    this.items = [this.group_detail_panel];

    Talho.Groups.View.Detail.superclass.initComponent.apply(this, arguments);
  },

  /**
         *  Fills in the details for the Group Detail page from the group that we either had the results from (after creation) or the group that we looked up on click
         * @param {Object} group    the group that we're going to show the details for
         */
  fillGroupDetail: function(group){
    this.group_detail_panel.mask.hide();

    this.group_detail_panel.getComponent('group_name').update(group.name);
    this.group_detail_panel.getComponent('group_scope').update(group.scope);
    if(group.owner_jurisdiction){ this.group_detail_panel.getComponent('group_jurisdiction').update(group.owner_jurisdiction.name); }

    this.group_detail_panel.getComponent('group_audience_panel').load(group);
  },

    /**
       * Shows the group detail form
       * @param   {Object/Int}    group   Either an object representation of the group or the group ID that we will be looking up
       */
  showGroupDetail: function(group){
    if(Ext.isObject(group))
    {
      this.group_id = (group.group || group).id;
      // we have the group already to go and just need to load the json here
      this.group_detail_panel.ownerCt.on('show', function(){this.fillGroupDetail(group.group || group)}, this, {delay: 10})
    }
    else
    {
      this.group_id = group;
      // we need to make an ajax request to get the group information
      if(this.group_detail_panel.mask && this.group_detail_panel.mask.show){
        this.group_detail_panel.mask.show();
      }
      else {
        this.group_detail_panel.mask = true;
      }

      Ext.Ajax.request({
        url: '/admin/groups/' + group + '.json',
        params: {no_page: true},
        method: 'GET',
        success: function(response, options){
          var group = Ext.decode(response.responseText);
          this.fillGroupDetail(group);
        },
        scope: this
      });
    }
  }
});
