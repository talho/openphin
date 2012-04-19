Ext.namespace('Talho.Dashboard.Portlet');

Talho.Dashboard.Portlet.RSS = Ext.extend(Talho.Dashboard.Portlet, {
  fields: ['numEntries', 'urls'],
  numEntries: 10,

  initComponent: function() {
    this.rss_store = new Ext.data.JsonStore({
      url: '/rss_feed.json',
      baseParams: {
        'urls[]': this.urls,
        'num_entries': this.numEntries
      },
      autoLoad: true,
      fields: ['content', 'summary', 'title', {name: 'date', type: 'date'}, 'url', 'feed_title']
    });
    
    this.items = [{
      xtype: 'dataview',
      store: this.rss_store,
      tpl: [
        '<tpl for=".">',
        '<div class="rss-node dash-rss-entry t_boot">',
          '<table>',
            '<tr>',
              '<td class="tf">{feed_title}:</td>',
              '<td class="ts rss-title">{title} ({[fm.date(values.date, "n/d/y, g:i A")]})</td>',
              '<td class="tt"><a href="{url}" target="_blank" qtip="Open in New Tab" class="rss-launch"></a></td>',
            '</tr>',
          '</table>',
        '</div>',
        '</tpl>'
      ],
      loadingText: 'Loading RSS Feed...',
      itemSelector: 'td.rss-title',
      listeners: {
        scope: this,
        click: this.feed_click
      }}
    ]
    
    this.tools = [{ id:'refresh', qtip: 'Refresh', handler: function(){this.rss_store.load({params:{'urls[]': this.urls,'num_entries': this.numEntries}});}, scope: this}]
    
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
        '<div class="t_boot">',
          '<a href="{url}" target="_blank">Open original item in new tab</a>',
          '<div class="dash-rss-entry">',
            '<div class="dash-rss-body">{[values.content || values.summary || ""]}</div>',
          '</div>',
        '</div>'
      ],
      data: {
        url: r.get('url'),
        content: r.get('content'),
        summary: r.get('summary')
      },
      title: r.get('title'),
      cls: "t_boot",
      maxWidth: 500,
      constrainPosition: true,
      closable: true,
      renderTo: dv.ownerCt.ownerCt.getEl()
    });
    this.tip.showBy(n);
  },
  
  showEditWindow: function(){
    var win = new Ext.Window({
      title: 'Edit RSS Portlet',
      layout: 'border',
      items: [{ xtype: 'container', region: 'north', layout: 'form', itemId: 'north', height: 60, margins: '5px 5px 0px', items: [
          {xtype: 'textfield', fieldLabel: 'Portlet title', itemId: 'titleField', value: this.title, anchor: '100%'},
          {xtype: 'numberfield', fieldLabel: 'Entries to show', itemId: 'num_entries', anchor: '100%', value: this.numEntries}
        ]},
        {xtype: 'editorgrid',
         itemId: 'grid',
         region: 'center',
         title: 'Feed URLs. (Do not include http://)',
         store: new Ext.data.ArrayStore({
           fields: [{name: 'url', type: 'string', convert: function(v, r){return r;}}],
           data: this.urls || []
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
    this.numEntries = win.getComponent('north').getComponent('num_entries').getValue();
    this.title = win.getComponent('north').getComponent('titleField').getValue();
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