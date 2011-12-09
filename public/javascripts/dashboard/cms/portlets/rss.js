Ext.namespace('Talho.Dashboard.Portlet');

Talho.Dashboard.Portlet.RSS = Ext.extend(Talho.Dashboard.Portlet, {
  fields: ['num_entries', 'urls'],

  initComponent: function() {
    //this.num_entries = 10;
    //this.urls = ['xkcd.com/rss.xml', 'www.statesman.com/section-rss.do?source=news&includeSubSections=true'];
    
    this.rss_store = new Ext.data.JsonStore({
      url: '/rss_feed.json',
      baseParams: {
        'urls[]': this.urls,
        'num_entries': this.num_entries
      },
      autoLoad: true,
      fields: ['content', 'summary', 'title', {name: 'date', type: 'date'}, 'url', 'feed_title']
    });
    
    this.items = [{
      xtype: 'dataview',
      store: this.rss_store,
      tpl: [
        '<tpl for=".">',
          '<div class="rss-node">',
            '<span>{feed_title}: <span class="rss-title">{title}</span> ({[fm.date(values.date, "n/d/y, g:i A")]})</span><a href="{url}" target="_blank" qtip="Open in New Tab" class="rss-launch"></a>',
          '</div>',
        '</tpl>'
      ],
      itemSelector: 'span.rss-title',
      listeners: {
        scope: this,
        'click': this.feed_click
      }}
    ]
    
    this.tools = [{ id:'refresh', qtip: 'Refresh', handler: function(){this.rss_store.load({params:{'urls[]': this.urls,'num_entries': this.num_entries}});}, scope: this}]
    
    Talho.Dashboard.Portlet.RSS.superclass.initComponent.apply(this, arguments);
  },
  
  feed_click: function(dv, i, n, e){
    var r = dv.getStore().getAt(i);
    if(this.tip && this.tip.isVisible()){
      this.tip.destroy();
    }
    
    this.tip = new Ext.Tip({
      defaultAlign: 'tl-bl?',
      tpl: [
        '<a href="{url}" target="_blank">Open original item in new tab</a>',
        '<div style="overflow:auto;">{[values.content || values.summary || ""]}</div>'
      ],
      data: {
        url: r.get('url'),
        content: r.get('content'),
        summary: r.get('summary')
      },
      title: r.get('title'),
      closable: true,
      maxWidth: 500,
      constrainPosition: true
    });
    this.tip.showBy(n);
  },
  
  showEditWindow: function(){
    var win = new Ext.Window({
      title: 'Edit RSS Portlet',
      layout: 'border',
      items: [{ xtype: 'container', region: 'north', layout: 'form', itemId: 'north', height: 30, items: [
          {xtype: 'numberfield', fieldLabel: 'Entries to show', itemId: 'num_entries', anchor: '100%', value: this.num_entries}
        ]},
        {xtype: 'editorgrid',
         itemId: 'grid',
         region: 'center',
         title: 'Feed URLs. (Do not include http://)',
         store: new Ext.data.ArrayStore({
           fields: [{name: 'url', type: 'string', convert: function(v, r){return r;}}],
           data: this.urls
         }),
         hideHeaders: true,
         columns: [{dataIndex: 'url', name: 'URL', id: 'url', editor: Ext.form.TextField}, 
                   {xtype: 'xactioncolumn', icon: '/images/cross-circle.png', handler: function(grid, row){
                     grid.getStore().removeAt(row);
                   }, scope: this}],
         autoExpandColumn: 'url',
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
    this.num_entires = win.getComponent('north').getComponent('num_entries');
    this.urls = []
    win.getComponent('grid').getStore().each(function(r){
      this.urls.push(r.get('url').replace('http://', ''));
    }, this);
    win.close();
  },
  
  isModified: function() {
    return true;
  },

  revert: function() {
    return true;
  },

  title: 'RSS Portlet'
});

Ext.reg('dashboardrssportlet', Talho.Dashboard.Portlet.RSS);