Ext.ns('Talho');

Talho.HelpWindow = Ext.extend(Ext.Window, {
  modal: true,
  width: 500,
  height: 200,
  draggable: false,
  constructor: function(config){
    this.dshsEmailButton = new Ext.Button({
      text: 'Email TXPHIN Admin',
      handler: function(){
        window.location = 'mailto:phinadmin@dshs.state.tx.us?body=\'TxPHIN help request\'';
      }
    });
    this.talhoEmailButton = new Ext.Button({
      text: 'Email TALHO Support',
      handler: function(){
        window.location = 'mailto:phin@talho.org?body=\'TxPHIN help request\'';
      }
    });

    var innerItems = [];
    if(config.user_has_app_roles){     // RollCall or VMS or etc User
      innerItems.push([
        {xtype: 'box', autoEl: 'h1', html: 'For support, please email phin@talho.org, or click this button.', style: 'padding: 5px 0px;'},
        this.talhoEmailButton
      ]);
    } else {      // Normal Phin User
      innerItems.push([
        {xtype: 'box', autoEl: 'h1', html: 'If you are with a Local Health Department, please email phin@talho.org ', style: 'padding: 5px 0px;'},
        this.talhoEmailButton,
        {xtype: 'box', autoEl: 'h1', html: '<br><br>All other users, please send an email request to phinadmin@dshs.state.tx.us ', style: 'padding: 5px 0px;'},
        this.dshsEmailButton
      ]);
    }
    innerItems = Ext.flatten(innerItems);

    this.innerContainer = new Ext.Container({    // Need an inner container so that CSS will apply to the content
       style: {
         width: '100%',
         height: '100%',
         backgroundColor: 'white',
         padding: '20px'
       },
       items: innerItems
    });

    Ext.apply(config, {
      items: this.innerContainer
    });
    Talho.HelpWindow.superclass.constructor.call(this, config);
  }
});

Talho.HelpWindow.initialize = function(config){
   return new Talho.HelpWindow(config);
};

Talho.ScriptManager.reg('Talho.HelpWindow', Talho.HelpWindow, Talho.HelpWindow.initialize);