Ext.ns('Talho.Alert');

Talho.Alert.AcknowledgementController = Ext.extend(function(){}, {
  constructor: function(config){
    this.ack_list = Ext.get(Ext.DomQuery.selectNode('.acknowledgement_list'));
    if(this.ack_list){
      Ext.each(this.ack_list.query('li'), function(ack){
        Ext.get(ack).on('click', this.acknowledgement_clicked, this);
      }, this);
    }
  },
  
  acknowledgement_clicked: function(ev, el, op){
    el = Ext.get(el);
    if(el.hasClass('selected')){
      return;
    }
    
    var index = el.getAttribute('index');
    if(!this.load_mask){
      this.load_mask = new Ext.LoadMask(Ext.getBody(), {msg:'Saving...'});
    }
    this.load_mask.show();
    
    // call the server with the selection
    Ext.Ajax.request({
      url: window.callback_url,
      method: 'PUT',
      params: {
        response: index
      },
      scope: this,
      success: function(resp){
        this.ack_list.select('li').removeClass('selected');
        this.ack_list.select('li[index=' + index + ']').addClass('selected');
        this.load_mask.hide();
      },
      failure: function(resp){
        alert(resp.responseText);
        this.load_mask.hide();
      }
    });
  }
});

Ext.onReady(function(){
  new Talho.Alert.AcknowledgementController();
});

Ext.QuickTips.init();
