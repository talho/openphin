/**
 * @constructor
 * @param {object}    config        the Panel configuration
 * @config {string}   url           the url of the html document that will be loaded into this panel
 */
Ext.AjaxPanel = Ext.extend(Ext.Panel,
    /**
     * @lends Ext.AjaxPanel.prototype
     */
{
    initComponent: function()
    {
        Ext.AjaxPanel.superclass.initComponent.call(this);

        this.addEvents(
            /**
             * @event ajaxloadcomplete
             * Fires after the ajax document has loaded
             * @param {Ext.Component} this
             */
                'ajaxloadcomplete'
                );

        this.addListener('afterrender', this.loadAJAX, this);
        // do any special initialization events here
        this.url = this.initialUrl = this.url || '';
        this.history = [];
    },

    loadAJAX: function()
    {
        var updater = this.getUpdater();

        if (this.renderer != null)
        {
            updater.setRenderer(this.renderer);
        }

        if (this.url !== '')
        {
            updater.update({
                url: this.url,
                method: 'GET',
                callback: this.handleAJAXLoad,
                scope: this
            });
        }
    },

   /**
     * This is called after the updater completes. It should parse and hookup links
     * and forms and should call the specific callback
     */
    handleAJAXLoad: function(el, success, response, options)
    {
        //this.doLayout();
        if(this.history[this.history.length-1] != options.url)
            this.history.push(options.url);

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
                    a.addClass('inlineLink');

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

            formPanel.getForm().on({
                'actioncomplete': function(form, action){
                    this.update(action.result, false, function(){this.handleAJAXLoad(this.getEl());}.createDelegate(this));
                },
                'actionfailed': function(form, action){
                    (new Ext.Window({title: 'Error', html: action.response.responseText})).show();
                    this.loadAJAX();
                },
                scope:this
            });

            var formHolder = form.replaceWith({tag: 'div', cls: 'extFormHolder'});

            formPanel.render(formHolder);
        }, this);

        this.findParentByType('panel').doLayout();
        this.fireEvent('ajaxloadcomplete', this);
    },

    reset: function(){
        this.url = this.initialUrl;
        this.history = [];
        this.forward = [];
        this.loadAJAX();
    },
    
    back: function(){

    },

    forward: function(){

    }
});

Ext.reg('ajaxpanel', Ext.AjaxPanel);