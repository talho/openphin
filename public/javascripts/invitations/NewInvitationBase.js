Ext.ns("Talho");

Talho.NewInvitationBase = Ext.extend(function(){}, {
  constructor: function(config){
    Ext.apply(this, config);

    // Add flash msg at top and buttons at the bottom
    var panel_items = [
      {xtype: 'container', defaults:{width:this.form_config.form_width,padding:'10'}, items:[
        {xtype: 'box', id: 'flashBox', html: '<p class="flash">&nbsp;</p>', hidden: true},
        {xtype: 'container', layout: 'hbox', defaults:{padding:'10'}, items: this.form_config.item_list},
        {xtype: 'spacer', height: '15'},
        {xtype: 'container', layout: 'hbox', items:[
          {xtype: 'button', id: 'invitation_submit', text: 'Send Invitation', name: 'save_button', handler: this.save, scope: this, width:'auto', disabled: true},
          //{xtype: 'button', text: 'Save & Close', handler: this.save_close, scope: this, width:'auto'},
          {xtype: 'button', text: 'Cancel', handler: this.close, scope: this, width:'auto'}
        ]}
      ]}
    ];

    // Create the ext form panel
    var formPanel = new Ext.form.FormPanel({
      layout: 'hbox', layoutConfig: {defaultMargins:'10',pack:'center'},
      url: this.form_config.save_url, method: this.form_config.save_method,
      border: false,
      listeners: {scope: this, 'actioncomplete': this.submit_success, 'actionfailed': this.submit_failure},
      items: panel_items
    });

    var panel = new Ext.Panel({
      title: this.title,
      border: false,
      closable: true,
      autoScroll: true,
      items: [formPanel]
    })

    panel.on('render', this.show_loadmask, this, {single: true, delay: 1});
    this.getPanel = function(){ return panel; }
    this.getFormPanel = function(){ return formPanel; }
  },

  // Load form values via ajax
  show_loadmask: function(panel){
    if (this.form_config.load_url == null) return;
    panel.loadMask = new Ext.LoadMask(panel.getEl(), {msg:"Loading...", removeMask: true});
    panel.loadMask.show();
    this.load_form_values();
  },
  load_form_values: function(){
    Ext.Ajax.request({ url: this.form_config.load_url, method: 'GET',
      success: this.load_complete_cb, failure: this.load_fail_cb, scope: this });
  },
  load_complete_cb: function(response, options){
    var p = this.getPanel();
    p.loadMask.hide();
    var json = Ext.decode(response.responseText, true);
    this.set_field_values(p, json.model.user);
    this.set_field_values(p, json.extra);
    p.doLayout();
  },
  load_fail_cb: function(response, options){
    this.getPanel().loadMask.hide();
    Ext.Msg.alert('Error loading user info', 'Status:' + response.status + ': ' + response.statusText);
  },
  set_field_values: function(p, obj){
    for (var prop in obj) {
      var elem_list = p.find("name", "user[" + prop + "]");
      if (elem_list.length > 0) elem_list[0].setValue(obj[prop]);
    }
  },

  // Button callbacks
  save: function(){
    var saveButton = this.getPanel().find("name", "save_button")[0];
    if (saveButton.disabled) return;
    saveButton.disable();
    this.getFormPanel().getForm().submit();
  },
  close: function(){ this.getPanel().ownerCt.remove(this.getPanel()); },
  save_close: function(){ this.save(); this.close(); },

  // Form callbacks
  submit_success: function(form, action){
    this.getPanel().find("name", "save_button")[0].enable();
    var json = action.result;
    this.show_message(json);
  },
  submit_failure: function(form, action){
    this.getPanel().find("name", "save_button")[0].enable();
    Ext.Msg.maxWidth = 1000;
    if (action.failureType === Ext.form.Action.CONNECT_FAILURE)
      this.show_ajax_error(action.response);
    if (action.failureType === Ext.form.Action.SERVER_INVALID) {
      if (action.result.errormsg != null)
        Ext.Msg.alert('Invalid!!!', action.result.errormsg);
      else
        this.show_message(action.result);
    }
  },

  // Flash message utils
  show_message: function(json){
    var fm = this.getPanel().getEl().select(".flash").first();
    var msg = "";
    if (typeof json.flash != "undefined") {
      msg += json.flash;
    } else {
      jQuery.each(json.errors, function(i,e){
        var item = (jQuery.isArray(e)) ? e.join(" - ") : e;
        msg += item[0].toUpperCase() + item.substr(1) + "<br>";
      });
    }
    fm.parent().parent().parent().parent().scrollTo("top", 0);
    if (msg != "") {
      fm.parent().removeClass('x-hide-display');; // remove all classes
      fm.addClass("flash").addClass(json.type).update(msg).show();
    }
    this.getPanel().doLayout();
    var task = new Ext.util.DelayedTask(function(){
      fm.parent().addClass('x-hide-display');; // remove all classes
    },fm.parent());
    task.delay(10000);
  },
  show_ajax_error: function(response){
    Ext.Msg.alert('Error',
      '<b>Status: ' + response.status + ' => ' + response.statusText + '</b><br><br>' +
      '<div style="height:400px;overflow:scroll;">' + response.responseText + '<\div>');
  }
});
