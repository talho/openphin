Ext.ns("Talho.Forums.view.Forums");

Talho.Forums.view.Forums.Index = Ext.extend(Ext.Panel, {
  autoHeight: true,  
  constructor: function(){
    this.addEvents('showtopic', 'editforum');
    this.on('activate', this.reload, this);
    this.on('reload', this.reload, this);
    Talho.Forums.view.Forums.Index.superclass.constructor.apply(this, arguments);
  },
  initComponent: function(){    
    if (!this.items){
      this.items = [];
    }
    
    this.buttons = this.buttons || ['->'];
    this.buttons.push(      
      {xtype: 'button', id: 'newForumButton', text: 'New Forum', handler: function(){ this.fireEvent('newforum');}, scope: this},
      {xtype: 'button', text: 'Refresh', handler: function(){ this.fireEvent('reload');}, scope: this });
        
    
    var store = new Ext.data.JsonStore({
        url: '/forums.json',
        root: 'forums',
        restful: true,
        idProperty: 'id',
        fields: ['name', {name:'hidden_at', type: 'date'}, {name:'created_at', type:'date', dateFormat: 'Y-m-d\\Th:i:sP'}, {name:'updated_at', type:'date', dateFormat: 'Y-m-d\\Th:i:sP'},
                'lock_version', 'id', {name: 'is_moderator', type: 'boolean'}, {name: 'is_super_admin', type: 'boolean'}, {name: 'is_forum_admin', type: 'boolean'}, 'threads', 'subforums'],        
        autoLoad: true
    });
    
    var forumTpl = new Ext.XTemplate(      
      '<div class="forum-wrap" forumid="{id}">',
        '<div class="forum-left" forumid="{id}"><table>',
          '<tr>',
            '<td><span class="forum-title" forum_name="{name}" forumid="{id}">{name}</span></td>',
          '</tr>',
          '<tr>',
            '<td>',
              '<tpl if="this.canEdit(values)">',
                '<span class="forum-edit forum-actions" forum_name="{name}" forumid="{id}">&laquo;Edit</span>',
              '</tpl>',
              '<tpl if="this.canManage(values)">',
                '<span class="forum-manage forum-actions" forum_name="{name}" forumid="{id}" alt="Manage Forum">&laquo;Manage</span>',
              '</tpl>',
            '<td>',
          '</tr>',
        '</table></div>',        
        '<div class="forum-reply-count">{threads}</div>',
        '<div class="forum-clear"></div>' ,       
      '</div>',
      {
        canEdit: function(values){
          return (this.isAdmin(values) || values.is_owner);
        },
        canManage: function(values){
          return this.isAdmin(values);
        },
        isAdmin: function (values){
          if (values.is_super_admin || values.is_forum_admin)
          {
            return true;
          }          
          return false;
        }
      }
    );
    
    var forumIndexTpl = new Ext.XTemplate(
      '<div class="forum-header">',
        '<span class="forum-header-title">My Forums</span>',
        '<span class="forum-header-threads">Threads</span>',
      '</div>',
      '<div class="forum-divider">&nbsp;</div>',
      '<ul class="forum-list">',
        '<tpl for=".">',
          '<li class="forum-index-selector" forumid="{id}">',      
            '{[ this.renderForum(values) ]}',                
          '</li>',          
        '</tpl>',
      '</ul>',
      {
        renderForum: function(values){
          return forumTpl.apply(values); 
        }
      }
    );
    
    var indexView = new Ext.DataView({
      id: 'forumsIndex',
      store: store,
      tpl: forumIndexTpl,
      emptyText: "No forums created",
      listeners: {
        'click': { 
          fn:  function(div, index, node, e) {
            if (node.classList.contains('forum-edit')) {            
              this.fireEvent('editforum', parseInt(node.attributes['forumid'].value), null);        
            }
            else if (node.classList.contains('forum-manage')) {
              this.fireEvent('manageforum', parseInt(node.attributes['forumid'].value));
            }
            else if (node.attributes['forumid']) {
              var forumId = node.attributes['forumid'].value;
              var forumName = Ext.DomQuery.selectValue(".forum-title[forumId=" + forumId + "]");
              this.fireEvent('showtopics', parseInt(forumId), forumName);
            }
        },
        scope: this }
      }
    });
    
    this.items.push(indexView);
    
    Ext.Ajax.request({
      url: '/users/' + Application.current_user + '/is_admin.json',
      method: 'GET',
      scope: this,
      success: function (resp) {
        var data = Ext.decode(resp.responseText);
        if (data.admin == false && data.superadmin == false) {
          Ext.ComponentMgr.get('newForumButton').addClass('x-hide-display');
        }
      }
    });
    
    Talho.Forums.view.Forums.Index.superclass.initComponent.apply(this, arguments);
  },
  reload: function () {    
    if (this.activated)
    {         
      for (i=0; i < this.items.getCount(); i++)
      {
        this.items.get(i).getStore().load();
        this.items.get(i).refresh();
      }
    }
    this.activated = true;
  },  
  border: false,
  title: 'Forums',
  header: false
});
