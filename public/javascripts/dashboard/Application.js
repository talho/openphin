
(function(){ // wrapped in a function to not pollute the global scope
    var orig_application_config = window.Application || {};

    var appClass = Ext.extend(Ext.util.Observable, {
        constructor: function(config){
            this.addEvents('opentab');
            this.addEvents('openwindow');
            this.addEvents('forumtopicdeleted');
        }
    });
    window.Application = new appClass();
    
    Ext.apply(Application, orig_application_config);
})();

// Override default window configuration to constrain header
Ext.override(Ext.Window, {
  constrainHeader: true
});
