
(function(){ // wrapped in a function to not pollute the global scope
    var orig_application_config = window.Application || {};

    var appClass = Ext.extend(Ext.util.Observable, {
        constructor: function(config){
            this.addEvents('opentab', 
                           'openwindow', 
                           'forumtopicdeleted',
                           'mapready'
                           );
        },
        
        mapReady: function(){
          window.Application.fireEvent('mapready');
        }
    });
    window.Application = new appClass();
    
    Ext.apply(window.Application, orig_application_config);
})();
