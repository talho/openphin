Ext.namespace('Talho.Dashboard.Portlet');

Talho.Dashboard.Portlet.Forum = Ext.extend(Talho.Dashboard.Portlet, {
  fields: ['numEntries', 'forums', 'postsOrTopics'],
  numEntries: 10,
  postsOrTopics: 'topics',

  initComponent: function() {
    if(this.admin){      
      this.forum_store = new Ext.data.JsonStore({
        fields: ['name', 'id'],
        autoLoad: true,
        url: '/forums.json',
        baseParams: {
          per_page: 0
        },
        root: 'forums',
        restful: true
      });
    }
    
    this.tools = [{ id:'refresh', qtip: 'Refresh', handler: function(){
      if(this.store){
        this.store.load({params:{'urls[]': this.urls,'num_entries': this.numEntries}});
      }
    }, scope: this}]
    
    Talho.Dashboard.Portlet.Forum.superclass.initComponent.apply(this, arguments);
    
    if(this.postsOrTopics == 'posts'){
      this.addPostsView();
    }
    else{ // defaults to topics
      this.addTopicsView();
    }
  },
  
  /**
   * Adds the posts view. Assumes that store is destroyed and able to be replaced with a new one and that the panel is empty
   */
  addPostsView: function(){
    this.store = new Ext.data.JsonStore({
      fields: ['id', 'name', 'content', 'poster_name', 'forum_name', 'poster_id', 'forum_id', {name: 'created_at', type: 'date'}, 'poster_avatar'],
      restful: true,
      url: '/forums/topics/recent_posts.json',
      baseParams: {
        num_entries: this.numEntries,
        'forums[]': this.forums
      },
      autoLoad: true
    });
    
    this.add({
      xtype: 'dataview',
      store: this.store,
      itemSelector: 'div.dash-forum-post',
      tpl: [
        '<tpl for=".">',
          '<div class="dash-forum-post">',
            '<img src="{poster_avatar}" class="dash-forum-image" height="32" width="32"/>',
            '<div class="dash-forum-post-details">',
              '<span class="dash-forum-poster-name">{poster_name}</span> posted to <span class="dash-forum-name">{forum_name}</span> - <span class="dash-forum-topic-name">{name}</span> on {[fm.date(values.created_at, "n/d/y, g:i A")]}',
            '</div>',
            '<div class="dash-forum-content">',
              '{[values.content.summarizeHtml(250) + (values.content.length > 250 ? "..." : "")]}',
            '</div>',
          '</div>',
          '</div>',
        '</tpl>'
      ],
      listeners: {
        'click': this.forum_click,
        scope: this
      }
    });
  },
  
  
  /**
   * Adds the topics view. Assumes that store is destroyed and able to be replaced with a new one and that the panel is empty
   */
  addTopicsView: function(){
    this.store = new Ext.data.JsonStore({
      fields: ['name', 'id', {name:'last_comment_time', type:'date'}, 'last_comment_poster_name', 'last_comment_poster_id', 'forum_name', 'forum_id'],
      restful: true,
      url: '/forums/topics/active_topics.json',
      baseParams: {
        num_entries: this.numEntries,
        'forums[]': this.forums
      },
      autoLoad: true
    });
    
    this.add({
      xtype: 'dataview',
      store: this.store,
      itemSelector: 'div.dash-forum-topic',
      tpl: [
        '<tpl for=".">',
          '<div class="dash-forum-topic">',
            '<span class="dash-forum-name">{forum_name}</span> - <span class="dash-forum-topic-name">{name}</span>: Last post by <span class="dash-forum-poster-name">{last_comment_poster_name}</span> on {[fm.date(values.last_comment_time, "n/d/y, g:i A")]}',
          '</div>',
        '</tpl>'
      ],
      listeners: {
        'click': this.forum_click,
        scope: this
      }
    });
  },
  
  showEditWindow: function(){
    var win = new Ext.Window({
      title: 'Edit Forum Portlet',
      layout: 'border',
      modal: true,
      items: [{ xtype: 'container', region: 'north', layout: 'form', itemId: 'north', height: 80, margins: '5px 5px 0px', items: [
          {xtype: 'textfield', fieldLabel: 'Portlet title', itemId: 'titleField', value: this.title, anchor: '100%'},
          {xtype: 'numberfield', fieldLabel: 'Entries to show', itemId: 'num_entries', anchor: '100%', value: this.numEntries},
          {xtype: 'radiogroup', layout: 'column', anchor: '100%', itemId: 'portlet_type', hideLabel: true, items: [
            {boxLabel: 'Active Topics', value: 'topics', columnWidth: .5, name: 'portlet_type', checked: this.postsOrTopics === 'topics'},
            {boxLabel: 'Recent Posts', value: 'posts', columnWidth: .5, name: 'portlet_type', checked: this.postsOrTopics === 'posts'}
          ]}
        ]},
        {xtype: 'editorgrid',
         itemId: 'grid',
         region: 'center',
         title: 'Forums (Leave empty for all forums)',
         store: new Ext.data.ArrayStore({
           fields: [{name: 'id', convert: function(v, r){return r;}}],
           data: this.forums || []
         }),
         hideHeaders: true,
         columns: [{dataIndex: 'id', name: 'Forum ID', id: 'id', renderer: {fn: function(value){
                     var val = this.forum_store.getById(value),
                         name = val ? val.get('name') : value;
                     return name;
                   }, scope: this} , editor: {
                     xtype: 'combo', editable: false, triggerAction: 'all', mode: 'local', store: this.forum_store, displayField: 'name', valueField: 'id'
                   }}, 
                   {xtype: 'xactioncolumn', icon: '/images/cross-circle.png', handler: function(grid, row){
                     grid.getStore().removeAt(row);
                   }, scope: this}],
         autoExpandColumn: 'id',
         clicksToEdit: 1,
         bbar: {
           items: [
             {text: 'Add Source', scope: this, handler: function(){
               var grid = win.getComponent('grid'),
                   store = grid.getStore();
               store.add([new store.recordType('')]);
               grid.startEditing(store.getCount() - 1, 0);
             }}
           ]
         }
        }
      ],
      buttons: [
        {text: 'OK', scope: this, handler: function(){
          this.editWindow_save(win);
        }},
        {text: 'Cancel', scope: this, handler: function(){win.close();}}
      ],
      width: 600,
      height: 300
    });
    win.show();
  },

  editWindow_save: function(win){
    this.numEntries = win.getComponent('north').getComponent('num_entries').getValue();
    this.title = win.getComponent('north').getComponent('titleField').getValue();
    
    this.forums = []
    win.getComponent('grid').getStore().each(function(r){
      this.forums.push(r.get('id'));
    }, this);
    
    this.postsOrTopics = win.getComponent('north').getComponent('portlet_type').getValue().value;
    this.store.destroy();
    this.removeAll();
    
    if(this.postsOrTopics == 'posts'){
      this.addPostsView();
    }
    else{ // defaults to topics
      this.addTopicsView();
    }
    
    this.doLayout(); 
    
    win.close();
  },
  
  forum_click: function(dv, i, n, e){
    var t = Ext.get(e.getTarget());
    var r = dv.getStore().getAt(i);
    if(t.hasClass('dash-forum-name')){
      Application.fireEvent('opentab', {id: 'forums', title:'Forums', forum_id: r.get('forum_id'), initializer: 'Talho.Forums'});
    }
    else if(t.hasClass('dash-forum-topic-name')){
      Application.fireEvent('opentab', {title: r.get('name'), topic_id: r.get('id'), forum_id: r.get('forum_id'), initializer: "Talho.Topic", id: 'forum_topic_' + r.get('id')});
    }
  },
  
  isModified: function() {
    return true;
  },

  revert: function() {
    return true;
  },

  title: 'Forum Portlet'
});

Ext.reg('dashboardforumportlet', Talho.Dashboard.Portlet.Forum);