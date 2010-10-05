Ext.namespace('Talho');

Talho.Forums = Ext.extend(Ext.util.Observable, {
  constructor: function(config)
  {
    Ext.apply(this, config);

    Talho.Forums.superclass.constructor.call(this, config);

    var grid_panel = new Ext.grid.GridPanel({
      id: 'main-view',
      hidden: true,
      viewConfig: {
        forceFit: true
      },
      sm: new Ext.grid.RowSelectionModel({
        singleSelect:true
      }),
      cm: new Ext.grid.ColumnModel({
        defaults: {
          width: 75
        },
        columns: [
          {header: ' ', sortable: false, dataIndex: 'user_avatar', renderer: this.render_user_avatar, width: 65},
          {header: 'Name', sortable: true, dataIndex: 'name'},
          {header: 'Created', sortable: true, dataIndex: 'created_at'},
          {header: 'Updated', sortable: true, dataIndex: 'updated_at'},
          {header: 'Posts', sortable: true, dataIndex: 'posts'},
          {header: ' ', sortable: true, dataIndex: 'is_moderator', renderer: this.render_edit_icon, width: 16},
          {header: ' ', sortable: true, dataIndex: 'is_super_admin', renderer: this.render_delete_icon, width: 16},
        ]
      }),
      store: new Ext.data.JsonStore({
        autoLoad: false,
        fields:[]
      }),
      autoWidth: true
    });

    var create_forum_win = new Ext.Window({
      title: 'New Forum',
      layout:'fit',
      width:600,
      autoHeight:true,
      closeAction:'hide',
      plain: true,
      items: new Ext.Panel({
        autoTabs:true,
        activeTab:0,
        deferredRender:false,
        border:false,
        items:[
          new Ext.ux.AudiencePanel({
            showGroups: true,
            width: 600,
            height: 400
          })
        ]
      }),
      buttons: [
        {
          text:'Submit',
          disabled:true
        },
        {
          text: 'Close',
          handler: function(){
            this.hide();
          }
        }
      ]
    });
    
    var panel = new Ext.Panel({
      url: this.url,
      title: this.title,
      itemId: this.id,
      closable: true,
      hideBorders:true,
      autoScroll:true,
      listeners:{
        scope: this
      },
      layout: 'border',
      items:[
        new Ext.grid.GridPanel({
          id: 'forum-grid',
          region: 'west',
          split: true,
          collapsible: true,
          margins: '0 0 5 5',
          listeners:{
            'cellclick': this.getForumData,
            scope: this
          },
          store: new Ext.data.JsonStore({
            url: '/forums.json',
            storeId: 'forumStore',
            restful: true,
            root: 'forums',
            idProperty: 'id',
            fields: [
              'name',
              {name:'hidden_at', type: 'date'},
              {name:'created_at', type:'date'},
              {name:'updated_at', type:'date'},
              'lock_version',
              'id',
              {name: 'is_moderator', type: 'boolean'},
              'threads'
            ],
            autoLoad: true
          }),
          colModel: new Ext.grid.ColumnModel({
            defaults: {
              //width: 325
            },
            columns: [
              {header: ' ', sortable: true, dataIndex: 'is_moderator', renderer: this.render_edit_icon, width: 16, hideable: false},
              {header: 'Name', sortable: true, dataIndex: 'name'},
              {header: 'Created', sortable: true, dataIndex: 'created_at', width: 65, renderer: Ext.util.Format.dateRenderer('m-d-Y')},
              {header: 'Updated', sortable: true, dataIndex: 'updated_at', width: 65, renderer: Ext.util.Format.dateRenderer('m-d-Y')},
              {header: 'Threads', sortable: true, dataIndex: 'threads', width: 55}
            ]
          }),
          viewConfig: {
            forceFit: true
          },
          sm: new Ext.grid.RowSelectionModel({
            singleSelect:true
          }),
          width: 325,
          height: 600,
          autoHeight: false,
          frame: true,
          title: 'Forums',
          tbar: [{
            iconCls:'add_forum',
            text:'Add Forum',
            handler: this.open_create_forum_window,
            scope: this,
            id: 'create_forum_button'
          }]
        }),
        new Ext.Panel({
          id: 'main-container',
          region: 'center',
          title: 'Topics',
          split: true,
          border: true,
          frame: true,
          layout: 'fit',
          margins: '0 5 5 0',
          items: grid_panel
        })
      ]
    });

    this.getCreateForumWindow = function() { return create_forum_win; }
    this.getPanel = function(){ return panel; }
    this.getGrid  = function(){ return grid_panel; }
  },
  open_create_forum_window: function(button_element, click_event){
    this.getCreateForumWindow().show(this);
  },
  render_edit_icon: function(value, metaData, record, rowIndex, colIndex, store){
    if(value === true)
      metaData.css = 'edit_cell';
    return '&nbsp;';
  },
  render_delete_icon: function(value, metaData, record, rowIndex, colIndex, store){
    if(value === true)
      metaData.css = 'delete_cell';
    return '&nbsp;';
  },
  render_user_avatar: function(value, metaData, record, rowIndex, colIndex, store){
    return '<img style="width:65px;height:65px" src="'+value+'" />';
  },
  getForumData: function(grid, rowIndex, columnIndex, e) {
    var record          = grid.getStore().getAt(rowIndex);
    var grid_panel      = this.getGrid();
    var data_store      = new Ext.data.JsonStore({
      restful: true,
      root: 'topics',
      idProperty: 'id',
      url: '/forums/'+record.id+'/topics.json',
      autoLoad: true,
      fields: [
        'forum_id',
        'comment_id',
        'sticky',
        'locked_at',
        'name',
        'content',
        'poster_id',
        {name:'hidden_at', type: 'date'},
        {name:'created_at', type:'date'},
        {name:'updated_at', type:'date'},
        'lock_version',
        {name:'is_moderator',type:'boolean'},
        {name:'is_super_admin',type:'boolean'},
        'id',
        'posts',
        'user_avatar'
      ]
    });
    grid_panel.show();
    grid_panel.reconfigure(data_store,grid_panel.getColumnModel());
  }
});

Talho.Forums.initialize = function(config){
    var forums = new Talho.Forums(config);
    return forums.getPanel();
}