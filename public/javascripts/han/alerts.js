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
        var els = panelEl.select('li.han_alert');
        els.addListener('click', function(evt){
            if ( !( $(evt.target).hasClass("submit") || (evt.target.nodeName=="A") ) ) {
                var elem = Ext.get(evt.getTarget('li.han_alert'));
                elem.toggleClass('more');
                panel.findParentByType('panel').doLayout();
            }
        });
        els.addClass('inlineBtn');

        var alerts = panelEl.select('li.han_alert');

        alerts.each(function(alert){
            var alertDom = Ext.getDom(alert.dom);
            var alertIdNode = Ext.DomQuery.selectNode('.alertid', alertDom);
            if(alertIdNode)
            {
                var idString = alertIdNode.childNodes[1].wholeText;
                var id = idString.match(/[0-9]*$/);
            }

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
            if(userLink) userLink.removeAllListeners(); // we want to leave this as an inline link so we don't run it through the list;

            if(viewLink) viewLink.on('click', this.viewLink_clicked, this, {id: id, title: title});
            if(updateLink) updateLink.on('click', this.updateLink_clicked, this, {id: id, title: title});
            if(cancelLink) cancelLink.on('click', this.cancelLink_clicked, this, {id: id, title: title});
            if(userLink) userLink.on('click', this.userLink_clicked, this);
        }, this);

        // The only forms that should be coming through on this page are the forms for acknowledgement. We're going to re-write
        // the form's actioncomplete and actionfailed methods to reset the panel on both actioncomplete and actionfailed.
        Ext.each(this.getPanel().getFormPanels(), function(formPanel){
            var form = formPanel.getForm();
            if(form.removeAllListeners) form.removeAllListeners();
            form.on('actioncomplete', this.acknowledgement_complete, this);
            form.on('actionfailed', this.acknowledgement_complete, this);
            form.on('beforeaction', function(form, action){
                var values = form.getValues();
                if(values['alert_attempt[call_down_response]'] !== undefined){
                    if(values['alert_attempt[call_down_response]'] === ''){
                        if(this.getPanel().saveMask) this.getPanel().saveMask.hide();
                        this.getPanel().cancelMask = true;
                        Ext.Msg.alert('Error', 'Please select an alert response before acknowledging');
                        return false;
                    }
                }
                this.getPanel().cancelMask = false;
                return true;
            }, this);

            // We're also going to overload the submit button to show a mask on the entire page.

            var submitBtn = formPanel.getEl().select('input[type="submit"]');
            if(submitBtn)
            {
                submitBtn.on('click', function(){
                    if(!this.getPanel().saveMask){
                        this.getPanel().saveMask = new Ext.LoadMask(this.getPanel().getEl(), {msg: 'Saving...'});
                    }
                    if(!this.getPanel().cancelMask) this.getPanel().saveMask.show();
                }, this);
            }
        }, this)
    },

    acknowledgement_complete: function(){
        if(this.getPanel().saveMask) this.getPanel().saveMask.hide();
        this.getPanel().reset(true);
    },

    viewLink_clicked: function(evt, elem, options){
        var url = Ext.get(elem).getAttribute('url');
        Application.fireEvent('opentab', {title: 'Alert Detail - ' + options.title, url: url, id: 'alert_detail_for_' + options.id, alertId: options.id,  initializer: 'Talho.AlertDetail'});
    },

    updateLink_clicked: function(evt, elem, options){
        var url = Ext.get(elem).getAttribute('url');
        Application.fireEvent('opentab', {title: 'Create an Alert Update', url: url, mode: 'update', initializer: 'Talho.SendAlert', alertId: options.id});
    },

    cancelLink_clicked: function(evt, elem, options){
        var url = Ext.get(elem).getAttribute('url');
        Application.fireEvent('opentab', {title: 'Create an Alert Cancellation', url: url, mode: 'cancel', initializer: 'Talho.SendAlert', alertId: options.id});
    },

    userLink_clicked: function(evt, elem){
        // open the user tab
        var url = Ext.get(elem).getAttribute('url');
        var user_id = url.match(/[0-9]*(?=\/profile)/);
        Application.fireEvent('opentab', {title: 'Profile: ' + elem.textContent, user_id: user_id, id: 'user_profile_for_' + user_id, initializer: 'Talho.ShowProfile'});
    }
});

Talho.Alerts.initialize = function(config){
    var alerts = new Talho.Alerts(config);
    return alerts.getPanel();
};

Talho.ScriptManager.reg('Talho.Alerts', Talho.Alerts, Talho.Alerts.initialize);
