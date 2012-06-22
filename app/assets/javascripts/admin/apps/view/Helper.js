
Ext.ns("Talho.Admin.Apps.view");

/**
 * Adds events to classes that derive to communicate back up to the show view and through that to the controller.
 * Add handlers to automate throwing these events 
 */
Talho.Admin.Apps.view.Helper = Ext.extend(Ext.Panel, {
  autoScroll: true,
  constructor: function(){
    Talho.Admin.Apps.view.Helper.superclass.constructor.apply(this, arguments);
    
    this.addEvents('change');
  },
  
  initComponent: function(){
    Talho.Admin.Apps.view.Helper.superclass.initComponent.apply(this, arguments);
    
    if(this.ownerCt && this.load_data){
      this.ownerCt.on('loadcomplete', this.load_data, this);
    }
  },
  
  field_change: function(field, newVal, oldVal){
    // Get value, name
    var val = newVal,
        name = field.getName();
        
    this.fireEvent('change', name, val);
  },
  
  load_data: function(data){
    this.data = data;
    var form = this.getComponent('form') || this;
    for(var k in data){
      var field = form.getComponent(k);
      if(field){
        field.setValue(data[k]);
      }
    }
  }
});
