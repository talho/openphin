
Ext.ux.YouTubeList = Ext.extend(Ext.Panel, {
  playlistId: 'PLIsSzqPkjhhw81AEm4ic0MDptK7-zzVVq', 
  channel: 'texaslocalhealth',
  mode: 'playlist',
  autoScroll: true,
  cls: 'youtubelist',
  layoutConfig: {
    align: 'center'
  },
  
  initComponent: function () {
    this.addListener('afterrender', this.loadVideos)
    this.addListener('resize', this.loadVideos)
    this.addEvents('loadvideo');
    if (this.getBubbleTarget) { this.enableBubble('loadvideo'); }
    Ext.ux.YouTubeList.superclass.initComponent.call(this);
        
  },
  
  loadVideos: function () {
    if (this.mode == 'channel') {
      var url = 'https://gdata.youtube.com/feeds/users/' + this.channel + '/uploads?alt=json-in-script&callback=?';
    }
    else if (this.mode == 'playlist') {
      var url = 'https://gdata.youtube.com/feeds/playlists/' + this.playlistId + '?alt=json-in-script&callback=?';
    }
    
    $.ajax({ 
      url: url,
      dataType: 'jsonp',
      crossDomain: true,
      context: this.getEl(),
      success: this._makeVideos
    })
  },
  
  _makeVideos: function (data) {
    var feed = data.feed;
    var entries = feed.entry || [];
    var list = Ext.getCmp(this.context.id)
    var columns = Math.floor(this.context.dom.clientWidth / 280);
    if (columns == 0) { itemsPerRow = 1 }         
    
    var items = [];
    var first = '';
    
    if (entries.length == 0) {
      items.push(new Ext.Panel({html: '<h2>No videos in this ' + list.mode + '</h2>'}));
    }
    
    Ext.each(entries, function (entry, index) {
      var title = entry.title.$t;
      var thumbnail = entry.media$group.media$thumbnail[0].url;
      var url = entry.media$group.media$content[0].url;
      
      if (index == 0) { first = url; }
      
      var item = new Ext.Panel({width: 240, height: 240, border: false, cls: 'youtubelistitem',
        html: "<div style='text-align: center;'><img width=240, height=180, src='" + thumbnail + "' /><p width=240 style='font-weight: bolder;'>" + title + "</p></div>",
        url: url
      });
      item.on('render', function (c) { c.el.on('click', function(c) { this.fireEvent('loadvideo', this.url, true) }, this); });
      item.getBubbleTarget(list);
      item.addEvents('loadvideo');
      item.enableBubble('loadvideo');      
      
      items.push(item);
    });
    
    var table = new Ext.Panel({layout: 'table', cls: 'youtubeplayertable', defaults: { bodyStyle: 'padding:20px' }, layoutConfig: { columns: columns }, items: items, border: false });
    
    list.add(table);
    list.doLayout();
    list.fireEvent('loadvideo', first, false)
  }
});

