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
            panel.findParentByType('panel').doLayout();
        });
        els.addClass('inlineBtn');

        var alerts = panelEl.select('li.alert');

        alerts.each(function(alert){
            var alertDom = Ext.getDom(alert.dom);
            var idString = Ext.DomQuery.selectNode('.alertid', alertDom).childNodes[1].wholeText;
            var id = idString.match(/[0-9]*$/);

            var title = Ext.DomQuery.selectNode('span.title', alertDom).textContent;

            // rewrite the view elements to launch a new window
            var viewLink = Ext.get(Ext.DomQuery.selectNode('a:nodeValue(View)', alertDom));
            var updateLink = Ext.get(Ext.DomQuery.selectNode('a:nodeValue(Update)', alertDom));
            var cancelLink = Ext.get(Ext.DomQuery.selectNode('a:nodeValue(Cancel)', alertDom));
            var userLink = Ext.get(Ext.DomQuery.selectNode('.created_at a', alertDom));

            Ext.each(Ext.clean([viewLink, updateLink, cancelLink]), function(link){
                link.removeAllListeners();
                link.removeClass('inlineLink').addClass('inlineBtn');
            }, this);
            userLink.removeAllListeners(); // we want to leave this as an inline link so we don't run it through the list;

            if(viewLink) viewLink.on('click', this.viewLink_clicked, this, {id: id, title: title});
            if(updateLink) updateLink.on('click', this.updateLink_clicked, this, {id: id, title: title});
            if(cancelLink) cancelLink.on('click', this.cancelLink_clicked, this, {id: id, title: title});
            if(userLink) userLink.on('click', this.userLink_clicked, this);
        }, this);
    },

    viewLink_clicked: function(evt, elem, options){
        var url = Ext.get(elem).getAttribute('url');
        Application.fireEvent('opentab', {title: 'Alert Detail - ' + options.title, url: url, id: 'alert_detail_for_' + options.id});
    },

    updateLink_clicked: function(evt, elem, options){
        var url = Ext.get(elem).getAttribute('url');
        Application.fireEvent('opentab', {title: 'Alert Update - ' + options.title, url: url, mode: 'update', initializer: 'Talho.SendAlert', alertId: options.id});
    },

    cancelLink_clicked: function(evt, elem, options){
        var url = Ext.get(elem).getAttribute('url');
        Application.fireEvent('opentab', {title: 'Cancel Alert - ' + options.title, url: url, mode: 'cancel', initializer: 'Talho.SendAlert', alertId: options.id});
    },

    userLink_clicked: function(evt, elem){
        // open the user tab
        var url = Ext.get(elem).getAttribute('url');
        Application.fireEvent('opentab', {title: 'User Profile - ' + elem.textContent, url: url, id: 'user_profile_for_' + url.match(/[0-9]*(?=\/profile)/) });
    }
});

Talho.Alerts.initialize = function(config){
    var alerts = new Talho.Alerts(config);
    return alerts.getPanel();
}