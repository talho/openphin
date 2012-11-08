
Ext.ux.YouTubeList = Ext.extend(Ext.panel, {
  defaultMargins: {
    top: 25,
    right: 25,
    bottom: 25,
    left: 25
  },
  layout: 'hbox',
  channel: 'texaslocalhealth',
  
  initComponent: function () {
    this.loadVideos();
    
    Ext.ux.YouTubeList.superclass.initComponent.call(this);
  },
  
  loadVideos: function () {
    var url = 'http://gdata.youtube.com/feeds/users/' + this.channel + '/uploads?alt=json-in-script&callback=?';
    var feedData = null;
    
    $.getJSON(url, function (data) {
      feedData = data;
    });
    
    this._makeVideos(data);
  },
  
  _makeVideos: function (data) {
    var feed = data.feed;
    var entries = feed.entry || [];
    this.items = [];
    
    Ext.each(entries, function (entry, index) {
      var title = entry.title.$t;
      var thumnbail = entry.media$group.media$thumbnail[0].url;
      var url = entry.media$group.media$content[0].url;
      var item = {xtype: container, title: title, html: "<img src='" + this.thumbnail + "' />", 
        onclick: function () { this.fireEvent('videoclicked', url); }, scope: this }
      
      this.items.push(item);
    });
    
    this.doLayout();
  }
});

