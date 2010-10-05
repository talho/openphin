Ext.ns("Talho");

Talho.ProfileBase = Ext.extend(function(){}, {
  constructor: function(config){
    Ext.apply(this, config);

    // Add flash msg at top and buttons at the bottom
    var panel_items = [
      {xtype: 'container', defaults:{width:this.form_config.form_width,padding:'10'}, items:[
        {xtype: 'box', html: '<p id="flash-msg" class="flash">&nbsp;</p>'},
        {xtype: 'container', layout: 'hbox', defaults:{padding:'10'}, items: this.form_config.item_list},
        {xtype: 'container', layout: 'hbox', items:[
          {xtype: 'button', text: 'Save', handler: this.save, scope: this, width:'auto'},
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
      autoScroll: true,
      url: this.form_config.save_url, method: this.form_config.save_method,
      listeners: {scope: this, 'actioncomplete': this.submit_success, 'actionfailed': this.submit_failure},
      items: panel_items
    });
    panel.on('render', this.show_loadmask, this, {single: true, delay: 1});

    this.getPanel = function(){ return panel; }
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
    //alert(obj.toSource());
    for (var prop in obj) {
      var elem_list = p.find("name", "user[" + prop + "]");
      if (elem_list.length > 0) elem_list[0].setValue(obj[prop]);
    }
  },

  // Button callbacks
  save: function(){ this.getPanel().getForm().submit(); },
  close: function(){ this.getPanel().ownerCt.remove(this.getPanel()); },
  save_close: function(){ this.save(); this.close(); },

  // Form callbacks
  submit_success: function(form, action){
    var json = action.result;
    //alert(json.toSource());
    var fm = this.getPanel().getEl().select("#flash-msg").first();
    if (json.type != null)
      fm.addClass(json.type).update(json.flash).show();
    fm.parent().parent().parent().parent().scrollTo("top", 0);
    this.getPanel().doLayout();
  },
  submit_failure: function(form, action){
    Ext.Msg.maxWidth = 1000;
    if (action.failureType === Ext.form.Action.CONNECT_FAILURE)
      Ext.Msg.alert('Error',
        '<b>Status: ' + action.response.status + ' => ' + action.response.statusText + '</b><br><br>' +
        '<div style="height:400px;overflow:scroll;">' + action.response.responseText + '<\div>');
    if (action.failureType === Ext.form.Action.SERVER_INVALID) {
      if (action.result.errormsg != null)
        Ext.Msg.alert('Invalid!!!', action.result.errormsg);
      else {
        var json = action.result;
        var msg = "";
        jQuery.each(json.errors, function(i,e){
          var item = (jQuery.isArray(e)) ? e.join(" ") : e;
          msg += item[0].toUpperCase() + item.substr(1) + "\n";
        });
        Ext.Msg.alert('Error', '<pre>' + msg + '<\pre>');
      }
    }
  },
});
