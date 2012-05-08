Ext.ns("Talho.Forums");

Talho.Forums.Controller = Ext.extend(Ext.util.Observable, {
	constructor: function(config){
		Ext.apply(this, config);
		
		this.index = new Talho.Forums.view.Forums.Index({itemId: 'index'});
		var layout = new Talho.Forums.view.Layout({
			title: this.title || "Forums",
			itemId: this.itemId,
			items: [
				this.index
			]
		});
		
		this.index.on('reload', this.index.reload, this.index);
		this.index.on({
		   'editforum': this.newForum,
		   'newforum': this.newForum,
		   'showtopics': this.displayTopics,
		   'manageforum': this.manageForum,
		   scope: this
		});

		this.getPanel = function(){
			return layout;
		}		
	},
	
	newForum: function(id){	  
    var ic = this.getPanel().innerContainer;
    var nf = ic.add(new Talho.Forums.view.Forums.New({forumId: id}));      
    ic.layout.setActiveItem(ic.items.getCount() - 1);
    
    nf.on({
      'cancel': function(){this._removePanel(nf); this.index.fireEvent('reload');},
      'savecomplete': function(){this._removePanel(nf);},
      'deactivate': function(){this._removePanel(nf);},
      scope: this
    });
  },
  
  manageForum: function(id){
    var ic = this.getPanel().innerContainer;
    var manage = ic.add(new Talho.Forums.view.Forums.Edit({forumId: id}));
    ic.layout.setActiveItem(ic.items.getCount() - 1);
    
    manage.on({
      'cancel': function(){this._removePanel(manage);},
      'savecomplete': function(){this._removePanel(manage);},
      'deactivate': function(){this._removePanel(manage);},
      scope: this
    });
  },
  
  displayTopics: function(forumId, forumName){
    this._purgePanels('Forum:');
    this._purgePanels('Topic:');
    var ic = this.getPanel().innerContainer;
    var topic_list = ic.add(new Talho.Forums.view.Topics.Index({forumId: forumId, forumName: forumName}));
    ic.layout.setActiveItem(ic.items.getCount() - 1);
    
    topic_list.on({
      'showtopic': this.displayTopic,
      'newtopic': this.newTopic,
      'edittopic': this.editTopic,
      'deletetopic': this.deleteTopic,
      scope: this
    });    
  },
  
  displayTopic: function(forumId, topicId, topicName){
    this._purgePanels('Topic: ');
    var ic = this.getPanel().innerContainer; 
    var topic = ic.add(new Talho.Forums.view.Topics.Show({forumId: forumId, topicId: topicId, topicName: topicName}));    
    ic.layout.setActiveItem(ic.items.getCount() - 1);
    
    topic.on({
      'newcomment': this.newComment,
      'editcomment': this.editComment,
      'quotecomment': this.quoteComment,
      'deletetopic': this.deleteTopic,
      scope: this
    });
  },
  
  newTopic: function(forumId) {
    this.callNewTopic(forumId,null,'newTopic');
  },
  
  editTopic: function(forumId,topicId) {
    this.callNewTopic(forumId,topicId,'editTopic');
  },
  
  newComment: function(forumId, topicId) {
    this.callNewTopic(forumId,topicId,'newComment');
  },
  
  editComment: function(forumId, topicId) {
    this.callNewTopic(forumId,topicId,'editComment');
  },
  
  quoteComment: function(forumId, topicId) {
    this.callNewTopic(forumId,topicId,'quoteComment');
  },
  
  callNewTopic: function(forumId, topicId, mode) {
    var ic = this.getPanel().innerContainer;
    var new_topic = ic.add(new Talho.Forums.view.Topics.New({forumId: forumId, topicId: topicId, mode: mode}));
    ic.layout.setActiveItem(ic.items.getCount() - 1);
    
    new_topic.on({
      'cancel': function(){this._removePanel(new_topic);},
      'savecomplete': function(){this._removePanel(new_topic);},
      'deactivate': function(){this._removePanel(new_topic);},
      scope: this
    });
  },
  
  deleteTopic: function(forumId, topicId){
    Ext.Ajax.request({
      url: String.format('/forums/{0}/topics/{1}.json', forumId, topicId),
      method: 'DELETE',
      scope: this,
      callback: function(options, success){          
        if(success){
            alert('Successfully deleted');
        }
        else{
          alert("We were unable to delete the thread. An administrator has been notified.");
        }
      }
    });
  },
    
  _removePanel: function(panel){
    var ic = this.getPanel().innerContainer;
    var count = ic.items.getCount();
    if (!panel && count != 1)
    {       
       ic.items.itemAt(count - 1).destroy();
       ic.layout.setActiveItem(count - 2);
    }
    if (panel)
    {
      var panelIndex = ic.items.indexOf(panel);
      ic.items.itemAt(panelIndex).destroy();
      ic.layout.setActiveItem(count - 2);
    }    
  },
  
  _purgePanels: function(keyword){
    if (keyword)
    {
      var ic = this.getPanel().innerContainer;
      ic.items.each(function(item,i){
        if (item.title.indexOf(keyword) != -1)
        {
          item.destroy();
        }
      });
    }
  }
});

Talho.ScriptManager.reg('Talho.Forums',Talho.Forums.Controller, function(config) {
	var cont = new Talho.Forums.Controller(config);
	return cont.getPanel();
});
