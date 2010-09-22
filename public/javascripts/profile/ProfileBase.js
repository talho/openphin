Ext.ns("Talho");

Talho.ProfileBase = Ext.extend(function(){}, {
  constructor: function(config, item_list, url, method){
    Ext.apply(this, config);

    var buttons = {xtype: 'container', layout: 'hbox', items:[
      {xtype: 'button', text: 'Save', handler: this.save, scope: this, width:'auto'},
      {xtype: 'button', text: 'Save & Close', handler: this.save_close, scope: this, width:'auto'},
      {xtype: 'button', text: 'Cancel', handler: this.close, scope: this, width:'auto'}
    ]};
    item_list[0].items.push(buttons);

    var panel = new Ext.form.FormPanel({
      title: this.title,
      border: false,
      layout: 'hbox',
      layoutConfig: {defaultMargins: '10', pack: 'center'},
      closable: true,
      autoScroll: true,
      url: url, method: method,
      listeners: {scope: this, 'actioncomplete': this.submit_success, 'actionfailed': this.save_failure},
      items: item_list
    });
    panel.on('render', this.show_loadmask, this, {single: true, delay: 1});

    this.url = config.url + ".json";
    this.getPanel = function(){ return panel; }
    this.load_form_values();
  },

  show_loadmask: function(panel){
    panel.loadMask = new Ext.LoadMask(panel.getEl(), {msg:"Loading...", removeMask: true});
    panel.loadMask.show();
  },
  load_form_values: function(){
    //Ext.Ajax.on('beforerequest', this.showSpinner, this);
    Ext.Ajax.request({ url: this.url, method: 'GET',
      success: this.load_complete_cb, failure: this.load_fail_cb, scope: this });
  },
  load_complete_cb: function(response, options){
    this.getPanel().loadMask.hide();
    var p = this.getPanel();
    var user = Ext.decode(response.responseText, true).user;
    for (var prop in user) {
      var elem_list = p.find("name", "profile[" + prop + "]");
      if (elem_list.length > 0) elem_list[0].setValue(user[prop]);
    }
  },
  load_fail_cb: function(response, options){
    this.getPanel().loadMask.hide();
    alert("There was an issue loading the user info. Please try again.")
  },

  save: function(){ this.getPanel().getForm().submit(); },
  close: function(){ this.getPanel().ownerCt.remove(this.getPanel()); },
  save_close: function(){ this.save(); this.close(); },

  submit_success: function(form, action){
    if (action.type == 'submit') {
    }
  },

  save_failure: function(form, action){
    if (action.failureType === Ext.form.Action.CONNECT_FAILURE)
      Ext.Msg.alert('Error', 'Status:' + action.response.status + ': ' + action.response.statusText);
    if (action.failureType === Ext.form.Action.SERVER_INVALID)
      Ext.Msg.alert('Invalid', action.result.errormsg);
  }
});
