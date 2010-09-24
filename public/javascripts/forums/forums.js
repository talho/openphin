Ext.namespace('Talho');

Talho.Forums = Ext.extend(Ext.util.Observable, {
  constructor: function(config)
  {
    Ext.apply(this, config);

    Talho.Forums.superclass.constructor.call(this, config);

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
              {name: 'is_moderator', type: 'boolean'}
            ],
            autoLoad: true
          }),
          colModel: new Ext.grid.ColumnModel({
            defaults: {
              width: 325
            },
            columns: [
              {header: ' ', sortable: true, dataIndex: 'is_moderator', renderer: this.render_edit_icon, width: 16},
              {header: 'Name', sortable: true, dataIndex: 'name'},
              {header: 'Created', sortable: true, dataIndex: 'created_at'}
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
          title: 'Forums'
        }),
        {
          id: 'main-container',
          region: 'center',
          title: 'Topics',
          split: true,
          border: true,
          frame: true,
          margins: '0 5 5 0'
        }
      ]
    });

    this.getPanel = function(){ return panel; }
  },
  render_edit_icon: function(value, metaData, record, rowIndex, colIndex, store){
    if(value === true)
      metaData.css = 'edit_cell';
    return '&nbsp;';
  },
  getForumData: function(grid, rowIndex, columnIndex, e) {
    var record = grid.getStore().getAt(rowIndex);
    var panel = this.getPanel();
    var grid_obj = new Ext.grid.GridPanel({
      id: 'main-view',
      store: new Ext.data.JsonStore({
        storeId: 'topicStore',
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
          'id'
        ]
      }),
      colModel: new Ext.grid.ColumnModel({
        columns: [
          {header: 'Name', sortable: true, dataIndex: 'name'},
          {header: 'Created', sortable: true, dataIndex: 'created_at'}
        ]
      }),
      viewConfig: {
        forceFit: true
      },
      sm: new Ext.grid.RowSelectionModel({
        singleSelect:true
      }),
      autoWidth: true,
      autoHeight: true
    });
    panel.getComponent('main-container').add(grid_obj);
    //panel.getComponent('main-container').getComponent('main-view').bindStore(new_store);
    panel.getComponent('main-container').doLayout();
  }
});

Talho.Forums.initialize = function(config){
    var forums = new Talho.Forums(config);
    return forums.getPanel();
}