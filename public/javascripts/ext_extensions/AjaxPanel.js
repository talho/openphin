/**
 * @constructor
 * @param {object}    config        the Panel configuration
 * @config {string}   url           the url of the html document that will be loaded into this panel
 */
Ext.define('Ext.AjaxPanel',
    /**
     * @lends Ext.AjaxPanel.prototype
     */
{
    extend: 'Ext.Panel',
    alias: ['widget.ajaxpanel'],
    initComponent: function()
    {
      this.loader = {
        ajaxOptions: {method: 'GET'},
        callback: this.handleAJAXLoad,
        scope: this,
        renderer: 'html'
      };
      
      Ext.AjaxPanel.superclass.initComponent.call(this);

      this.addEvents(
          /**
           * @event ajaxloadcomplete
           * Fires after the ajax document has loaded
           * @param {Ext.Component} this
           */
              'ajaxloadcomplete',
              'fatalerror',
              'afternavigation'
              );

      this.addListener('afterrender', this.loadAJAX, this);
      // do any special initialization events here
      this.url = this.initialUrl = this.url || '';
      this.history = [];
      this.forward_stack = [];
      this.formPanels = [];
    },

    loadAJAX: function()
    {
        if (this.url === '')
        {
          return;
        }
        
        var updater = this.getLoader();
        
        updater.load({
          url: this.url
        });
    },

   /**
     * This is called after the updater completes. It should parse and hookup links
     * and forms and should call the specific callback
     */
    handleAJAXLoad: function(loader, success, response, options)
    {
        var el = this.getEl();
        if(!success)
        {
            (new Ext.Window({title: 'Error', html: response.responseText})).show();
            if(this.canGoBack())
                this.back();
            else
                this.fireEvent('fatalerror', this, this);
            return;
        }

        //this.doLayout();
        if(options && (this.history.length === 0 || this.history[this.history.length-1].url != options.url))
            this.history.push({url: options.url, title: this.title});

        var currentDomain = window.location.host;
        var domainRegex = new RegExp(currentDomain);

        var els = el.select('a');
        els.each(function(a) {
            var href = a.dom.href;
            if (!href.match(domainRegex) || href.match(/(\.doc|\.pdf|\.csv)(?:\?.*)?$/))
            {
                a.set({target:'_blank'});
            }
            else
            {
                $(a.dom).removeAttr('href');

                if (href !== undefined && href !== '' && href !== '#' && href !== location.href && href !== location.href + '#')
                {
                    a.addClass('inlineLink').set({url: href});

                    a.addListener('click', function(evt, target, href)
                    {
                        this.url = href;
                        this.loadAJAX();
                    }, this, href);
                }
            }
        }, this);

        var forms = el.select('form');
        forms.each(function(form)
        {
            var formPanel = new Ext.ux.HtmlFormPanel({
                htmlForm: form,
                border: false,
                keys:{
                    key: Ext.EventObject.ENTER,
                    fn: function(){ formPanel.getForm().submit();}
                }
            });

            var completeCb = function(form, action){
                this.update(action.response.responseText, false, function(){this.handleAJAXLoad(this.getEl(), true);}.bind(this));
                this.findParentByType('panel').doLayout();
            };
            var failedCb = function(form, action){
                Ext.Msg.alert('Error', action.response.responseText);
                this.loadAJAX();
            };

            formPanel.getForm().on({
                'actioncomplete': completeCb,
                'actionfailed': failedCb,
                scope:this
            });

            formPanel.getForm().removeAllListeners = function(){
                var form = formPanel.getForm();
                form.un('actioncomplete', completeCb);
                form.un('actionfailed', failedCb);
            };

            var formHolder = form.replaceWith({tag: 'div', cls: 'extFormHolder'});
            formPanel.render(formHolder);
            this.formPanels.push(formPanel);
        }, this);

        this.findParentByType('panel').doLayout();
        this.fireEvent('ajaxloadcomplete', this);
        this.fireEvent('afternavigation', this);
    },

    reset: function(force){
        if(force || this.url != this.initialUrl)
        {
            this.url = this.initialUrl;
            this.setTitle(this.initialConfig.title);
            this.history = [];
            this.forward_stack = [];
            this.loadAJAX();
        }
    },
    
    back: function(){
        if(this.history.length > 1)
        {
            this.forward_stack.push(this.history.pop());
            var historyItem = this.history[this.history.length - 1];
            this.url = historyItem.url;
            this.setTitle(historyItem.title);
            this.loadAJAX();
        }
    },

    forward: function(){
        if(this.forward_stack.length > 0)
        {
            var historyItem = this.forward_stack.pop();
            this.url = historyItem.url;
            this.setTitle(historyItem.title);
            this.history.push(historyItem); // Just in case it fails, we still want the forward record to be in the history stack
            this.loadAJAX();
        }
    },

    canGoBack: function(){
        return this.history.length > 1
    },

    canGoForward: function(){
        return this.forward_stack.length > 0
    },

    getFormPanels: function(){
      return this.formPanels;
    }
});
