Ext.ns("Talho");

Talho.ProfileBase = Ext.extend(function(){}, {
  constructor: function(config, item_list, url, method){
    Ext.apply(this, config);

    // Add buttons at the bottom of the form
    var buttons = {xtype: 'container', layout: 'hbox', items:[
      {xtype: 'button', text: 'Save', handler: this.save, scope: this, width:'auto'},
      {xtype: 'button', text: 'Save & Close', handler: this.save_close, scope: this, width:'auto'},
      {xtype: 'button', text: 'Cancel', handler: this.close, scope: this, width:'auto'}
    ]};
    item_list[0].items.push(buttons);

    // Create the ext form panel
    var panel = new Ext.form.FormPanel({
      title: this.title,
      border: false,
      layout: 'hbox',
      layoutConfig: {defaultMargins: '10', pack: 'center'},
      closable: true,
      autoScroll: true,
      url: url, method: method,
      listeners: {scope: this, 'actioncomplete': this.submit_success, 'actionfailed': this.submit_failure},
      items: item_list
    });
    panel.on('render', this.show_loadmask, this, {single: true, delay: 1});

    this.load_url = config.url + "/edit.json";
    this.getPanel = function(){ return panel; }
    this.load_form_values();
  },

  // Load form values via ajax
  show_loadmask: function(panel){
    panel.loadMask = new Ext.LoadMask(panel.getEl(), {msg:"Loading...", removeMask: true});
    panel.loadMask.show();
  },
  load_form_values: function(){
    Ext.Ajax.request({ url: this.load_url, method: 'GET',
      success: this.load_complete_cb, failure: this.load_fail_cb, scope: this });
  },
  load_complete_cb: function(response, options){
    var p = this.getPanel();
    p.loadMask.hide();
    var json = Ext.decode(response.responseText, true);
    this.set_field_values(p, json.model.user);
    this.set_field_values(p, json.extra);
  },
  load_fail_cb: function(response, options){
    this.getPanel().loadMask.hide();
    Ext.Msg.alert('Error loading user info', 'Status:' + response.status + ': ' + response.statusText);
  },
  set_field_values: function(p, obj){
    for (var prop in obj) {
      var elem_list = p.find("name", "profile[" + prop + "]");
      if (elem_list.length > 0) elem_list[0].setValue(obj[prop]);
    }
  },

  // Button callbacks
  save: function(){ this.getPanel().getForm().submit(); },
  close: function(){ this.getPanel().ownerCt.remove(this.getPanel()); },
  save_close: function(){ this.save(); this.close(); },

  // Form callbacks
  submit_success: function(form, action){
    if (action.type == 'submit') {
    }
  },
  submit_failure: function(form, action){
    if (action.failureType === Ext.form.Action.CONNECT_FAILURE)
      Ext.Msg.alert('Error', 'Status:' + action.response.status + ': ' + action.response.statusText);
    if (action.failureType === Ext.form.Action.SERVER_INVALID)
      Ext.Msg.alert('Invalid', action.result.errormsg);
  }
});
