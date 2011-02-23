Ext.ns('Talho');

Talho.BetaWindow = Ext.extend(Ext.Window, {
  modal: true,
  width: 500,
  height: 200,
  draggable: false,
  constructor: function(config){

    var innerItems = [
      {xtype: 'box', autoEl: 'p', html: 'You are currently using the new TXPhin 2.0 Beta Test.  ', style: 'padding: 5px 0px;'},
      {xtype: 'button', text: 'Stay with the TXPhin 2.0 Beta', handler: function(){ Talho.BetaWindow.close() }},
      {xtype: 'box', autoEl: 'h1', html: '<br><br>Return to the old version of TXPhin:', style: 'padding: 5px 0px;'},
      {xtype: 'button', text: 'Leave the TXPhin 2.0 Beta', handler: function(){document.cookie = 'phin2beta=false;path=/'; window.location = '/' }}
    ];

    //innerItems = Ext.flatten(innerItems);

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
    Talho.BetaWindow.superclass.constructor.call(this, config);
  }
});

Talho.BetaWindow.initialize = function(config){
   return new Talho.BetaWindow(config);
};

Talho.ScriptManager.reg('Talho.BetaWindow', Talho.BetaWindow, Talho.BetaWindow.initialize);