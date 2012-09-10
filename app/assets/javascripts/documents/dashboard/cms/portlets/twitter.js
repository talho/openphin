Ext.namespace('Talho.Dashboard.Portlet');

Talho.Dashboard.Portlet.Twitter = Ext.extend(Talho.Dashboard.Portlet, {
  fields: ['autoRefresh', 'terms', 'numTweets'],
  autoRefresh: false,

  initComponent: function() {
    this.tweet_store = new Ext.data.JsonStore({
      fields: [{name: 'user', mapping: 'from_user'}, {name: 'text', convert: this.markupText}, 'id_str', 'profile_image_url', 'entities'],
      root: 'results'
    });
    
    this.items = [
      {
        xtype: 'dataview',
        store: this.tweet_store,
        tpl: [
          '<tpl for=".">',
            '<div class="dash-twitter-entry t_boot">',
              '<img src="{profile_image_url}" class="dash-twitter-image" height="32" width="32"/>',
              '<a href="http://twitter.com/#!/{user}/status/{id_str}" target="_blank">@{user}</a>: {text}',
              '<div class="x-clear"></div>',
            '</div>',
          '</tpl>'
        ],
        loadingText: 'Loading Twitter Feed...'
      }
    ];
    
    this.tools = [{ id:'refresh', qtip: 'Refresh', handler: function(){
      this.loadTwitter();
    }, scope: this}]
    
    Talho.Dashboard.Portlet.Twitter.superclass.initComponent.apply(this, arguments);
    
    this.loadTwitter();
    
    this.on('destroy', function(){
      if(this.timer){
        clearTimeout(this.timer);
      }
    }, this);
  },
  
  markupText: function(text, r){
    var entities = r['entities'],
        replacements = [],
        out_text = '',
        end_i;
    
    if(!entities){
      return text;
    }
    
    for(var k in entities){
      Ext.each(entities[k], function(en){
        var start = en.indices[0],
            end = en.indices[1],
            entity_text = text.substring(start, end),
            entity_url;
        
        switch(k){
          case 'user_mentions': entity_url = '<a href="http://twitter.com/#!/' + en.screen_name + '/" target="_blank">' + entity_text + '</a>';
            break;
          case 'hashtags': entity_url = '<a href="http://twitter.com/#!/search?q=%23' + en.text + '" target="_blank">' + entity_text + '</a>';
            break;
          case 'urls': entity_url = '<a href="' + en.url + '" target="_blank">' + en.display_url + '</a>';
            break;
          default:
            entity_url = entity_text;
        }
        
        replacements.push({start:start, end:end, url:entity_url})
      }, this);
    }
    
    if(replacements.length == 0){
      return text;
    }
    
    replacements.sort(function(a, b){
      return a.start - b.start;
    });
    
    out_text = text.substring(0,replacements[0].start);
    for(var i = 0; i < replacements.length; i++){
      end_i = replacements[i+1] ? replacements[i+1].start : text.length;
      out_text += replacements[i].url + text.substring(replacements[i].end, end_i);
    }
    
    return out_text;  
  },
  
  loadTwitter: function(){
    if(this.timer){
      clearTimeout(this.timer);
    }
    
    var query_arr = [];
    Ext.each(this.terms, function(term){
      query_arr.push((term.type === 'user' ? 'from:' : '') + term.term);
    });
    
    if(query_arr.length === 0){
      return;
    }
    
    Ext.ux.JsonP.request({
      url: 'https://search.twitter.com/search.json',
      params: {
        q:query_arr.join(' OR '),
        include_entities:1,
        rpp: this.numTweets
      },
      callback: this.loadTwitter_callback,
      scope: this
    });
    
    if(this.autoRefresh){
      this.timer = setTimeout(Ext.createDelegate(this.loadTwitter, this), 60000);
    }
  },
  
  loadTwitter_callback: function(json){
    if(typeof(json) === String){
      var json = Ext.decode(jsonString);
    }
    this.tweet_store.loadData(json);
  },
  
  showEditWindow: function(){
    var win = new Ext.Window({
      title: 'Edit Twitter Portlet',
      layout: 'border',
      items: [{ xtype: 'container', region: 'north', layout: 'form', itemId: 'north', height: 80, margins: '5px 5px 0px', items: [
          {xtype: 'textfield', fieldLabel: 'Portlet title', itemId: 'titleField', value: this.title, anchor: '100%'},
          {xtype: 'numberfield', fieldLabel: 'Tweets to show', itemId: 'num_tweets', anchor: '100%', value: this.numTweets},
          {xtype: 'checkbox', itemId: 'auto_refresh', hideLabel: true, boxLabel: 'Auto Refresh', checked: this.autoRefresh}
        ]},
        {xtype: 'editorgrid',
         itemId: 'grid',
         region: 'center',
         title: 'Search terms (choose User or Hashtag from drop-down)',
         store: new Ext.data.JsonStore({
           fields: ['term', { name: 'type', defaultValue: 'user'}],
           data: this.terms || []
         }),
         hideHeaders: true,
         columns: [{dataIndex: 'term', name: 'Term', id: 'term', editor: Ext.form.TextField},
                   {dataIndex: 'type', name: 'Type', id: 'type', editor: {xtype: 'combo', editable: false, mode: 'local', triggerAction: 'all', store: [['user', 'User'], ['hashtag', 'Hashtag']]}}, 
                   {xtype: 'xactioncolumn', icon: '/assets/cross-circle.png', handler: function(grid, row){
                     grid.getStore().removeAt(row);
                   }, scope: this}],
         autoExpandColumn: 'term',
         clicksToEdit: 1,
         bbar: {
           items: [
             {text: 'Add Source', scope: this, handler: function(){
               var grid = win.getComponent('grid'),
                   store = grid.getStore();
               store.add([new store.recordType({type: 'user'})]);
               grid.startEditing(store.getCount() - 1, 0);
             }}
           ]
         }
        }
      ],
      buttons: [
        {text: 'OK', scope: this, handler: function(){
          this.editWindow_save(win);
        }},
        {text: 'Cancel', scope: this, handler: function(){win.close();}}
      ],
      width: 600,
      height: 400
    });
    win.show();
  },
  
  editWindow_save: function(win){
    this.numTweets = win.getComponent('north').getComponent('num_tweets').getValue();
    this.title = win.getComponent('north').getComponent('titleField').getValue();
    this.autoRefresh = win.getComponent('north').getComponent('auto_refresh').getValue();
    this.terms = []
    win.getComponent('grid').getStore().each(function(r){
      if(!Ext.isEmpty(r.get('term'))){
        if(r.get('type') === 'hashtag' && r.get('term').trim()[0] !== '#'){
          r.set('term', '#'+r.get('term').trim());
        }
        this.terms.push({term: r.get('term').trim(), type: r.get('type')});
      }
    }, this);
    win.close();
    this.loadTwitter();
  },
  
  isModified: function() {
    return true;
  },

  revert: function() {
    return true;
  },

  title: 'Twitter Portlet'
});

Ext.reg('dashboardtwitterportlet', Talho.Dashboard.Portlet.Twitter);