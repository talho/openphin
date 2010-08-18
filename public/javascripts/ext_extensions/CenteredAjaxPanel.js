/**
 * @constructor
 * @param {object}    config        the Panel configuration
 * @config {string}   url           the url of the html document that will be loaded into this panel
 */
Ext.CenteredAjaxPanel = Ext.extend(Ext.Panel,
    /**
     * @lends Ext.AjaxPanel.prototype
     */
{
    initComponent: function()
    {
        // We don't really care what they sent in, we're going to redefine the items and layout and a bunch of other config options
        this.ajaxPanel = new Ext.AjaxPanel({
            maxWidth: 1024,
            bodyCssClass: 'content',
            listeners:{
                'ajaxloadcomplete': function(){ this.fireEvent('ajaxloadcomplete', this.ajaxPanel);},
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
                'ajaxloadcomplete'
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
    }
});

Ext.reg('centeredajaxpanel', Ext.CenteredAjaxPanel);