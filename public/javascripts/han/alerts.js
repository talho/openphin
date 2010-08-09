Ext.namespace('Talho');

Talho.Alerts = Ext.extend(Ext.util.Observable, {
    constructor: function()
    {
        var panel = new Ext.AjaxPanel({
            url: '/han',
            title: 'HAN',
            xtype:'ajaxpanel',
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
        var els = panelEl.select('a.view_more, a.view_less')
        els.addListener('click', function(evt){
            var elem = Ext.get(evt.getTarget('li.alert'));
            elem.toggleClass('more');
            panel.doLayout();
        });

        els.addClass('inlineBtn');
    }
});

Talho.Alerts.initialize = function(){
    var alerts = new Talho.Alerts();
    return alerts.getPanel();
}