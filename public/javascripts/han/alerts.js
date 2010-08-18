Ext.namespace('Talho');

Talho.Alerts = Ext.extend(Ext.util.Observable, {
    constructor: function(config)
    {
        Ext.apply(this, config);

        Talho.Alerts.superclass.constructor.call(this, config);

        var panel = new Ext.CenteredAjaxPanel({
            url: this.url,
            title: this.title,
            itemId: this.id,
            closable: true,
            hideBorders:true,
            autoScroll:true,
            listeners:{
                scope: this,
                'ajaxloadcomplete': this.panelLoaded
            }
        });

        this.getPanel = function(){ return panel; }
    },

    panelLoaded: function(panel){
        var panelEl = panel.getEl();
        var els = panelEl.select('a.view_more, a.view_less');
        els.addListener('click', function(evt){
            var elem = Ext.get(evt.getTarget('li.alert'));
            elem.toggleClass('more');
            panel.doLayout();
        });

        els.addClass('inlineBtn');
    }
});

Talho.Alerts.initialize = function(config){
    var alerts = new Talho.Alerts(config);
    return alerts.getPanel();
}