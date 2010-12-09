Ext.ns("Talho");

Talho.ProfileBase = Ext.extend(function(){}, {
  constructor: function(config){
    Ext.apply(this, config);

    // Add flash msg at top and buttons at the bottom
    var panel_items = [
      {xtype: 'container', defaults:{width:this.form_config.form_width,padding:'10'}, items:[
        {xtype: 'box', html: '<p id="flash-msg" class="flash">&nbsp;</p>'},
        {xtype: 'container', layout: 'hbox', defaults:{padding:'10'}, items: this.form_config.item_list},
        {xtype: 'spacer', height: '15'},
        {xtype: 'container', layout: 'hbox', items:[
          {xtype: 'button', text: 'Save', name: 'save_button', handler: this.save, scope: this, width:'auto'},
          //{xtype: 'button', text: 'Save & Close', handler: this.save_close, scope: this, width:'auto'},
          {xtype: 'button', text: 'Cancel', handler: this.close, scope: this, width:'auto'}
        ]}
      ]}
    ];

    // Create the ext form panel
    var panel = new Ext.form.FormPanel({
      title: this.title,
      border: false,
      layout: 'hbox', layoutConfig: {defaultMargins:'10',pack:'center'},
      closable: true,
      autoWidth: true,
      autoScroll: true,
      url: this.form_config.save_url, method: this.form_config.save_method,
      baseParams: {'authenticity_token': FORM_AUTH_TOKEN},
      trackResetOnLoad: true,
      listeners: {scope: this,
        'beforeaction': function(){ panel.loadMask.show() },
        'actioncomplete': this.form_submit_success,
        'actionfailed': this.form_submit_failure},
      items: panel_items
    });
    panel.on('render', this.show_loadmask, this, {single: true, delay: 1});
    panel.addListener("beforeclose", this.closeOrPrompt, this);

    this.getPanel = function(){ return panel; }
  },

  // Load form values via ajax
  show_loadmask: function(panel){
    panel.loadMask = new Ext.LoadMask(panel.getEl(), {msg:"Loading...", removeMask: true});
    if (this.form_config.load_url == null) return;
    panel.loadMask.show();
    this.load_json();
  },
  load_json: function(options){
    var defaults = {url: this.form_config.load_url, method: 'GET', success: this.load_complete_cb, failure: this.load_fail_cb, scope: this};
    var args = Ext.apply(defaults, options);
    Ext.Ajax.request(args);
  },
  load_complete_cb: function(response, options){
    this.getPanel().loadMask.hide();
    var json = Ext.decode(response.responseText, true);
    this.load_data(json);  // derived class must have load_data method defined
    this.getPanel().doLayout();
  },
  load_fail_cb: function(response, options){
    this.getPanel().loadMask.hide();
    Ext.Msg.alert('Error loading user info', 'Status:' + response.status + ': ' + response.statusText);
  },

  // Button callbacks
  save: function(){
    this.save_data();  // derived class must have save_data method defined
  },
  close: function(){ this.getPanel().ownerCt.remove(this.getPanel()); },
  save_close: function(){ this.save(); this.close(); },
  is_dirty: function(p){ return p.getForm().isDirty(); },

  // Save via AJAX callbacks
  save_json: function(url, json){
    this.getPanel().loadMask.show();
    var json_auth = Ext.apply({'authenticity_token': FORM_AUTH_TOKEN}, json);
    Ext.Ajax.request({ url: url, method: "PUT", params: json_auth,
      success: this.ajax_save_success_cb, failure: this.ajax_save_err_cb, scope: this });
  },
  ajax_save_success_cb: function(response, opts) {
    (this.form_config.load_url != null) ? this.load_json() : this.getPanel().loadMask.hide();
    this.show_message(Ext.decode(response.responseText));
  },
  ajax_save_err_cb: function(response, opts) {
    this.getPanel().loadMask.hide();
    this.show_ajax_error(response);
  },

  // Save form callbacks
  form_submit_success: function(form, action){
    (this.form_config.load_url != null) ? this.load_json() : this.getPanel().loadMask.hide();
    var json = action.result;
    this.show_message(json);
  },
  form_submit_failure: function(form, action){
    this.getPanel().loadMask.hide();
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

  // Prompt if changes are present
  closeOrPrompt: function(p){
    var dirty = this.is_dirty(p);
    if (dirty)
      Ext.Msg.confirm("Save Is Needed", "Changes need to be saved.  Press 'Yes' to close and abandon your changes.",
        function(id){  if (id == "yes") p.destroy(); });
    return !dirty;
  },

  // Flash message utils
  show_message: function(json){
    var fm = this.getPanel().getEl().select("#flash-msg").first();
    var msg = "";
    if (json.flash != null) {
      msg += json.flash;
    } else if (json.errors != null) {
      jQuery.each(json.errors, function(i,e){
        var item = (jQuery.isArray(e)) ? e.join(" - ") : e;
        msg += item[0].toUpperCase() + item.substr(1) + "<br>";
      });
    } else {
      var w = 300;
      var msg = '<b>Server Error:</b> ' + json.error + '<br>';
      if (json.exception != null) {
        w = 900;
        msg += '<b>Exception:</b> ' + json.exception + '<br><br>';
        msg += '<div style="height:400px;overflow:scroll;">';
        for (var i = 0; i < json.backtrace.length; i++)
          msg += '&nbsp;&nbsp;' + json.backtrace[i] + '<br>';
        msg += '<\div>';
      }
      Ext.Msg.show({title: 'Error', msg: msg, minWidth: w, maxWidth: w, buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR});
    }
    if (json.type != null) {
      jQuery(fm.dom).removeClass(); // remove all classes
      fm.addClass("flash").addClass(json.type).update(msg).show();
    }
    fm.parent().parent().parent().parent().scrollTo("top", 0);
    this.getPanel().doLayout();
  },
  show_ajax_error: function(response){
    var msg = '<b>Status: ' + response.status + ' => ' + response.statusText + '</b><br><br>' +
      '<div style="height:400px;overflow:scroll;">' + response.responseText + '<\div>';
    Ext.Msg.show({title: 'Error', msg: msg, minWidth: 900, maxWidth: 900, buttons: Ext.Msg.OK, icon: Ext.Msg.ERROR});
  }
});
