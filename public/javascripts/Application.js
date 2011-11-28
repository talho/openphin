
(function(){
  Ext.Loader.setConfig({
    enabled:true,
    paths: {
      'Ext': '/javascripts/ext/src'
    },
    disableCaching: false
  });
  
  Ext.application({
    name: 'Talho',
    appFolder: '/javascripts',
    autoCreateViewport: true,
    views: [
      'favorites.Bar',
      'application.TabPanel',
      'dashboard.View'
    ],
    controllers: [
      'Menu',
      'Tab'
    ],
    launch: function(){
      console.log('launched!');
    }
  });
})();
