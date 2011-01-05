(function(){ // wrapped in a function to not pollute the global scope
  var origConfig = window.DownloadFrame || {};

  var appClass = Ext.extend(Ext.util.Observable,{
    constructor: function(){
      if(!this._downloadFrame){
        this._downloadFrame = Ext.DomHelper.append(Ext.select('body').first().dom, {tag: 'iframe', style: 'width:0;height:0;border:none;'});
        Ext.EventManager.on(this._downloadFrame, 'load', function(){
          if(this._downloadFrame.src != ''){
            Ext.Msg.alert('Could Not Load File', 'There was an error downloading the file you have requested. Please contact an administrator');
          }
        }, this);
      }
    },
    download: function(uri){
      if(Application.rails_environment === 'cucumber')
      {
        Ext.Ajax.request({
          url: 'rollcall/export',
          method: 'GET',
          success: function(){
            alert("Success");
          },
          failure: function(){
            alert("File Download Failed");
          }
        })
      }else{
        this._downloadFrame.src = uri;
      }
    }
  });
  window.DownloadFrame = new appClass();
  Ext.apply(DownloadFrame, origConfig);
})();