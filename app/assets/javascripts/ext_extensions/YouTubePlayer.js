dominoes('http://swfobject.googlecode.com/svn/trunk/swfobject/swfobject.js')

Ext.ux.YouTubePlayer = Ext.extend(Ext.panel, {
  autoPlay: true,
  playerHeight: 500,
  playerWidth: 500,
  
  initComponent: function () {    
    this.playerId = 'player' + Math.floor((Math.random()*10000) + 1);
    this.html = '<object id="' + this.playerId + '"></object>';
    
    if (this.videoUrl) {
      //do the load video after render
    }
    
    Ext.ux.YouTubePlayer.superclass.initComponent.call(this);
  },
  
  loadVideo: function (videoUrl, auto) {
    if (!auto) { 
      auto = this.autoPlay 
    }
    swfobject.embedSWF(videoUrl + '&rel=1&border=0&fs=1&autoplay=' + (auto ? 1 : 0), this.playerId,
      this.playerWidth, this.playerHeight, '9.0.0', false, false, {allowfullscreen: 'true'}) ;
  }
});