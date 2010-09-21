Ext.ns("Talho");

Talho.ProfileBase = Ext.extend(function(){}, {
  mode: 'new',

  constructor: function(config, item_list){
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
      url: '/alerts.json',
      method: 'POST',
      listeners: {scope: this, 'actioncomplete': this.submit_success, 'actionfailed': this.save_failure},
      items: item_list
    });

    this.getPanel = function(){ return panel; }
  },

  save: function(){ this.getPanel().getForm().submit(); },
  close: function(){ this.getPanel().ownerCt.remove(this.getPanel()); },
  save_close: function(){ this.save(); this.close(); },

  submit_success: function(form, action){
    if (action.type == 'submit') {
    }
  },

  save_failure: function(form, action){
    Ext.Msg.alert('Error', action.response.responseText);
  }
});
