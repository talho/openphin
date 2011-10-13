/**
 * @constructor
 * @param {object}    config        the Panel configuration
 * @config {string}   url           the url of the html document that will be loaded into this panel
 */
Ext.define('Ext.CenteredAjaxPanel',
    /**
     * @lends Ext.AjaxPanel.prototype
     */
{
    extend: 'Ext.panel.Panel',
    alias: ['widget.centeredajaxpanel'],
    initComponent: function()
    {
        // We don't really care what they sent in, we're going to redefine the items and layout and a bunch of other config options
        this.ajaxPanel = new Ext.AjaxPanel({
            maxWidth: 1024,
            bodyCls: 'content',
            listeners:{
                'ajaxloadcomplete': function(){ this.fireEvent('ajaxloadcomplete', this.ajaxPanel);},
                'afternavigation': function(){ this.fireEvent('afternavigation', this);},
                'fatalerror': function(panel){ this.fireEvent('fatalerror', this, this);},
                scope: this
            },
            url: this.url
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
                'ajaxloadcomplete',
                'afternavigation',
                'fatalerror'
                );

        this.addListener('show', function(){this.doLayout();});
    },

    onRender: function(ct, position)
    {
        Ext.AjaxPanel.superclass.onRender.call(this, ct, position);
        if (this.getWidth() > 1024)
        {
            this.setWidth(1024);
        }
    },

    back: function(){this.ajaxPanel.back();},
    forward: function(){this.ajaxPanel.forward();},
    reset: function(force){this.ajaxPanel.reset(force);},
    canGoBack: function(){return this.ajaxPanel.canGoBack();},
    canGoForward: function(){return this.ajaxPanel.canGoForward();},
    getFormPanels: function(){return this.ajaxPanel.getFormPanels();}
});