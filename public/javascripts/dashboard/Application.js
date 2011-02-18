
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

// Override Ext.Container to add the findComponent function
Ext.override(Ext.Container, {
  /**
   * Perform a breadth first search using getComponent on all children until a component is found or there are no more children to search
   * @param  {String} id     The id or itemId of the component to search for
   * @return {Ext.Component} The first matching component
   */
  findComponent: function(id){
    var found = this.getComponent(id);
    var current_level = this.items.getRange();
    var next_level = new Ext.util.MixedCollection();
    while(found === undefined && current_level.length > 0){
      for(var i = 0; i < current_level.length; i++){
        var found = current_level[i].getComponent(id);
        if(found !== undefined)
          break;
        else
          next_level.addAll(current_level[i].items.getRange());
      }
      current_level = next_level.getRange();
      next_level.clear();
    }
    return found;
  }
});
