
(function(){ // wrapped in a function to not pollute the global scope
    var orig_application_config = window.Application || {};

    var appClass = Ext.extend(Ext.util.Observable, {
        constructor: function(config){
            this.addEvents('opentab');
        }
    });
    window.Application = new appClass();
    
    Ext.apply(Application, orig_application_config);
})();