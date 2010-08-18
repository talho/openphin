Ext.ns('Talho');

Talho.AdvancedSearch = Ext.extend(Ext.util.Observable, {
    constructor: function(config)
    {
        Ext.apply(this, config);

        Talho.AdvancedSearch.superclass.constructor.call(this, config);

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
        var link_elem_style = {'margin-bottom': '15px'};

        var wildcard_explanation = panel.getEl().select('.search_user_explanation').first();
        if(wildcard_explanation)
        {
            // insert an inline link/button to show/hide the wildcard section. hide it now
            var newBtn = Ext.get(Ext.DomHelper.insertHtml('beforeBegin', wildcard_explanation.dom, '<div><a class="inlineLink">Willcard (*) Explanation</a></div>'));
            newBtn.setStyle(link_elem_style);

            var wildcard_panel = new Ext.Panel({contentEl:wildcard_explanation.dom, collapsed: true, border: false});
            wildcard_panel.render(newBtn.parent(), newBtn.next());

            newBtn.on('click', wildcard_panel.toggleCollapse, wildcard_panel);
        }

        var quick_search = panel.getEl().select('.quick_search_user').first();
        var advanced_search = panel.getEl().select('.advance_search_user').first();
        if(quick_search && advanced_search)
        {
            // insert an inline link/button between the quick search and the advanced search sections to show/hide the two sections. Hide advanced search now
            var advanced_search_btn = Ext.get(Ext.DomHelper.insertHtml('afterend', quick_search.dom, '<div><a class="inlineLink">Advanced Search</a></div>'));
            var quick_search_btn = Ext.get(Ext.DomHelper.insertHtml('afterend', advanced_search_btn.dom, '<div><a class="inlineLink">Quick Search</a></div>'));
            advanced_search_btn.setVisibilityMode(Ext.Element.DISPLAY);
            quick_search_btn.setVisibilityMode(Ext.Element.DISPLAY);
            advanced_search_btn.setStyle(link_elem_style);
            quick_search_btn.setStyle(link_elem_style);

            quick_search_btn.hide();

            var quick_search_panel = new Ext.Panel({contentEl: quick_search.dom, border: false});
            var advanced_search_panel = new Ext.Panel({contentEl: advanced_search.dom, collapsed: true, border: false});

            quick_search_panel.render(advanced_search_btn.parent(), advanced_search_btn);
            advanced_search_panel.render(quick_search_btn.parent(), quick_search_btn.next());

            quick_search_btn.on('click', function(){
                quick_search_btn.hide();
                advanced_search_btn.show();
                quick_search_panel.expand();
                advanced_search_panel.collapse();
            });

            advanced_search_btn.on('click', function(){
                quick_search_btn.show();
                advanced_search_btn.hide();
                quick_search_panel.collapse();
                advanced_search_panel.expand();
            })
        }
    }
});

Talho.AdvancedSearch.initialize = function(config)
{
    var as = new Talho.AdvancedSearch(config);
    return as.getPanel();
};