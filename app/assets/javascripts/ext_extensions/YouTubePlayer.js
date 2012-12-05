
Ext.ux.YouTubePlayer = Ext.extend(Ext.Panel, {
  autoPlay: true,
  playerHeight: 356,
  playerWidth: 425,
  cls: 'youtubeplayer',
  
  initComponent: function () {    
    this.playerId = 'player' + Math.floor((Math.random()*10000) + 1);
    this.html = '<object id="' + this.playerId + '"></object>';
    this.height = this.playerHeight;
    this.width = this.playerWidth;    
    
    dominoes('http://swfobject.googlecode.com/svn/trunk/swfobject/swfobject.js');
    Ext.ux.YouTubePlayer.superclass.initComponent.call(this);
  },
  
  loadVideo: function (videoUrl, auto) {    
    if (auto == null || auto == undefined) { 
      auto = this.autoPlay 
    }

    if (videoUrl)
    {
      swfobject.embedSWF(videoUrl + '&rel=1&border=0&fs=1&autoplay=' + (auto ? 1 : 0), this.playerId,
        this.playerWidth, this.playerHeight, '9.0.0', false, false, {allowfullscreen: 'true'}) ;
    }
  }
});