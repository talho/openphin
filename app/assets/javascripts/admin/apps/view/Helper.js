
Ext.ns("Talho.Admin.Apps.view");

/**
 * Adds events to classes that derive to communicate back up to the show view and through that to the controller.
 * Add handlers to automate throwing these events 
 */
Talho.Admin.Apps.view.Helper = Ext.extend(Ext.Panel, {
  constructor: function(){
    Talho.Admin.Apps.view.Helper.superclass.constructor.apply(this, arguments);
    
    this.addEvents('change');
  },
  
  field_change: function(field, newVal, oldVal){
    // Get value, name
    var val = newVal,
        name = field.getName();
        
    this.fireEvent('change', name, val);
  }
});
