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
        // We don't really care what they sent in, we're going to redefine the items and layout and a bunch of other config options
        this.ajaxPanel = new Ext.Panel({
            maxWidth: 1024,
            bodyCssClass: 'content',
            listeners:{
                'afterrender': this.loadAJAX,
                scope: this}
        });

        Ext.apply(this, {
            layout: 'mwhbox',
            layoutConfig:{
            },
            items: [
                {flex:1},
                this.ajaxPanel,
                {flex:1}
            ]});

        Ext.AjaxPanel.superclass.initComponent.call(this);

        this.addEvents(
            /**
             * @event ajaxloadcomplete
             * Fires after the ajax document has loaded
             * @param {Ext.Component} this
             */
                'ajaxloadcomplete'
                );

        this.addListener('show', function(){this.doLayout();});
        // do any special initialization events here
        this.url = this.url || '';
    },

    onRender: function(ct, position)
    {
        Ext.AjaxPanel.superclass.onRender.call(this, ct, position);
        if (this.getWidth() > 1024)
        {
            this.setWidth(1024);
        }
    },

    loadAJAX: function()
    {
        var updater = this.ajaxPanel.getUpdater();

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
        this.doLayout();
        // this.findParentByType('panel').doLayout();

        var currentDomain = window.location.host;
        var domainRegex = new RegExp(currentDomain);

        var els = el.select('a');
        els.each(function(a) {
            var href = a.dom.href;
            if (!href.match(domainRegex) || href.match(/(\.doc|\.pdf)$/))
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

        }, this);

        this.fireEvent('ajaxloadcomplete', this);
    }
});

Ext.reg('ajaxpanel', Ext.AjaxPanel);