Ext.ns("Talho.Forums.view.Topics");

Talho.Forums.view.Topics.New = Ext.extend(Ext.form.FormPanel, {
  width: 940,
  autoHeight: true,
  constructor : function(config) {
    this.addEvents('cancel','savecomplete');

    if (config.mode == 'newTopic') {
      config.url = String.format('/forums/{0}/topics.json',config.forumId);
      config.edit = false;
      config.method = 'POST';      
    }
    if (config.mode ==  'newComment' || config.mode == 'quoteComment') {
      config.url = String.format('/forums/{0}/topics/{1}.json',config.forumId, config.topicId);
      config.edit = false;
      config.method = 'PUT';
    }
    if (config.mode == 'editTopic' || config.mode == 'editComment') {
      config.url = String.format('/forums/{0}/topics/{1}.json',config.forumId, config.topicId);
      config.edit = true;
      config.method = 'PUT';
    }
    
    config.isTopic = false;
    
    if (config.mode.indexOf("Topic") != -1)
    {
      config.isTopic = true;  
    }

    config.waitMsgTarget = true;
    
    Talho.Forums.view.Topics.New.superclass.constructor.apply(this, arguments);
  },
  initComponent : function() {
    if (this.mode == 'newTopic') {
      this.setTitle('New Topic');
    }
    else if (this.mode ==  'newComment' || this.mode ==  'quoteComment') {
      this.setTitle('New Comment');
    }
    else if (this.mode ==  'editTopic') {
      this.setTitle('Edit Topic');
    }
    else if (this.mode ==  'editComment') {
      this.setTitle('Edit Comment');
    }
    
    if (this.isTopic) {
      this.items = [
        {xtype: 'container', itemId: 'container', width: 940, layout: 'form', defaults: {anchor: '100%'}, items: [
          {xtype: 'textfield', fieldLabel: 'Topic Name', name:'topic[name]', allowBlank: false},
          {xtype: 'checkbox', itemId: 'sticky_checkbox', boxLabel: 'Sticky'},
          {xtype: 'checkbox', itemId: 'locked_checkbox', boxLabel: 'Locked'},
          [{xtype: 'textarea', itemId: 'comment_contents', anchor: '100% -30', hideLabel: true, name: 'topic[content]', allowBlank: false, height: 200},
            {xtype:'box', anchor: '100% b', autoEl:{tag: 'a', href: 'http://redcloth.org/hobix.com/textile/quick.html', target: '_blank'}, html: 'Textile Quick Reference'}],
          ]}
      ];    
    }
    else {
      this.items = [
        {xtype: 'container', itemId: 'container', width: 940, layout: 'form', defaults: {anchor: '100%'}, items: [          
          [{xtype: 'textarea', itemId: 'comment_contents', anchor: '100% -30', hideLabel: true, name: 'topic[comment_attributes][content]', allowBlank: false, height: 200},
            {xtype:'box', anchor: '100% b', autoEl:{tag: 'a', href: 'http://redcloth.org/hobix.com/textile/quick.html', target: '_blank'}, html: 'Textile Quick Reference'}],
        ]}
      ];      
    }
    
    this.listeners = {
      scope: this,
      'beforeaction': this.beforeSubmit
    }
    
    this.buttons = [
      '->',
      {text: 'Save', scope: this, handler: function(){this.getForm().submit({
        waitMsg: 'Saving...',
        scope: this,
        success: function(){this.fireEvent('savecomplete');},
        failure: function(form, action) {
          if (action.response && action.response.responseText) {
            var errors = {},
              res = Ext.decode(action.response.responseText);
            for (var k in res.errors){
              errors['topic[' + k + ']'] = res.erorrs[k];
            }
            form.markInvalid(errors);
          }
        }
      });}},
      {text: 'Cancel', scope: this, handler: function(){ this.fireEvent('cancel');}}
    ];
    
    Talho.Forums.view.Topics.New.superclass.initComponent.apply(this, arguments);
    
    if (this.edit || this.mode == 'quoteComment')
    {
      this.on('afterrender', function () {
        var f = this.getForm();
        f.load({
          url: String.format('/forums/{0}/topics/{1}/edit.json',this.forumId, this.topicId),
          method: 'GET',
          waitMsg: 'Loading...',          
          success: function(form,action){
            var data = action.result.data;            
            if (this.isTopic)
            {
              data['topic[name]'] = data.name;
              data['topic[content]'] = data.content;
              
              if (data.sticky)
              {
                this.getComponent('container').getComponent('sticky_checkbox').setValue(true);
              }
              if (data.locked)
              {
                this.getComponent('container').getComponent('locked_checkbox').setValue(true);
              }              
            }
            else {
              if (this.mode == 'quoteComment')
              {
                data.content = 'bq.. __Originally posted by: ' + data.poster_name + '__\r\n\r\n' + data.content + '\r\n\r\np. '
              }
              data['topic[comment_attributes][content]'] = data.content;
            }            
            this.getForm().setValues(data);
          },        
          scope: this
        });
      }, this, {delay:1});
    }
  },
  beforeSubmit: function(form, action){
    if(action.type == 'submit' && !this.isTopic){

      action.options.params = {        
        'topic[comment_attributes][forum_id]': this.forumId,
        'topic[comment_attributes][name]': (new Date()).format('D M j G:i:s O Y')
      };
      if (this.edit)
      {
        action.options.params ['topic[comment_attributes][id]'] = this.topicId;
      }
      else
      {
        action.options.params ['topic[comment_attributes][comment_id]'] = this.topicId;
      }
    }
    if (action.type == 'submit' && this.isTopic)
    {
      var sticky = (this.getComponent('container').getComponent('sticky_checkbox').getValue() ? "1" : "0");
      var locked = (this.getComponent('container').getComponent('locked_checkbox').getValue() ? "1" : "0");
      action.options.params = {
        'topic[sticky]': sticky,
        'topic[locked]': locked
      }
    }
  },
  border: false,  
  header: false
}); 