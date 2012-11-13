
Ext.ux.YouTubeList = Ext.extend(Ext.Panel, {
  channel: 'googledevelopers',  
  autoScroll: true,
  cls: 'youtubelist',
  
  initComponent: function () {
    this.addListener('afterrender', this.loadVideos) 
        
    Ext.ux.YouTubeList.superclass.initComponent.call(this);
  },
  
  loadVideos: function () {
    var url = 'http://gdata.youtube.com/feeds/users/' + this.channel + '/uploads?alt=json-in-script&callback=?';
    
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
    var itemsPerRow = Math.floor(this.context.dom.clientWidth / 280);
    if (itemsPerRow == 0) { itemsPerRow = 1 } 
    
    var html = "<table style='margin-left: auto;margin-right: auto;'>";
    Ext.each(entries, function (entry, index) {
      var title = entry.title.$t;
      var thumbnail = entry.media$group.media$thumbnail[0].url;
      var url = entry.media$group.media$content[0].url;
      
      if ((index + 1) % itemsPerRow == 1 || itemsPerRow == 1) { html += "<tr>"; }
        
      html += "<td width=280 height=220 style='vertical-align:top;'>" + 
              "<div style='text-align: center;'><img width=240, height=180, src='" + 
              thumbnail + "' /><p width=240 style='font-weight: bolder;'>" + title + 
              "</p></div></td>";
              
      if ((index + 1) % itemsPerRow == 0 || itemsPerRow == 1) { html += "</tr>"; }
    });
    html += "</table>";
        
    list.update(html);
  }
});

