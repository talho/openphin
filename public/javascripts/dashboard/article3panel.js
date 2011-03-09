Ext.namespace('Talho');

Talho.Article3Panel = Ext.extend(Ext.util.Observable, {
    constructor: function(config)
    {
        Ext.apply(this, config);

        Talho.Article3Panel.superclass.constructor.call(this, config);

        this.linksPanel = new Ext.Panel({
            flex: 1,
            autoHeight:true,
            html: "  <div class='article'>\
    <h2>Flu Awareness</h2>\
    <p class='date'>January 9, 2011</p>\
    <div class='lede'>\
      <p class='article_link'><a href='http://www.texasflu.org' target='_blank' title='Texas Flu'>Texas Flu</a></p>\
      <p class='article_link'><a href='http://www.cdc.gov/flu/about/season/index.htm' target='_blank' title='2010-2011 Flu Season'>2010-2011 Flu Season</a></p>\
    </div>\
  </div>\
    <div class='article'>\
    <h2>Disaster Preparedness</h2>\
    <p class='date'>January 9, 2011</p>\
    <div class='lede'>\
      <p class='article_link'><a href='http://www.dshs.state.tx.us/preparedness/' target='_blank' title='Public Health Preparedness'>Public Health Preparedness</a></p>\
      <p class='article_link'><a href='http://www.dhs.gov/files/prepresprecovery.shtm' target='_blank' title='Preparedness, Response & Recovery'>Preparedness, Response & Recovery</a></p>\
    </div>\
  </div>"
        });

        this.newsFeedPanel = new Ext.Panel({
            flex: 1,
            autoHeight:true,
            items: window.Application.rails_environment == "cucumber" ? [] : new Ext.DataView({
                store: this.create_feed_store(),
                singleSelect: false,
                autoHeight: true,
                tpl: this.create_feed_template(),
                itemSelector: 'div.feedArticle',
                listeners: {
                    scope:this,
                    'click': function(view, index, node, evt){
                        var elem = Ext.get(node);
                        if(elem.hasClass('more_btn') || elem.hasClass('less_btn'))
                        {
                            elem.up('.feed_article').toggleClass('more');
                            this.getPanel().doLayout();
                        }
                    }
                }
            })
        });

        this.staticNewsPanel = new Ext.Panel({
            flex: 1,
            autoHeight:true,
            bodyCssClass:'news_articles',
            listeners:{
                'render':function(cpt){
                     if(window.Application.rails_environment != "cucumber") cpt.getUpdater().update({url:'/dashboard/news_articles'});
                }
            }
        });


        var panel = new Ext.Panel({
            title: 'Dashboard',
            itemId: this.itemId,
            layout:'hbox',
            layoutConfig: {defaultMargins:'15'},
            items: [this.linksPanel, this.newsFeedPanel, this.staticNewsPanel],
            autoScroll: true,
            hideBorders: true,
            listeners:{
                'show':function(panel){panel.doLayout();}
            }
        });

        this.getPanel = function(){
            return panel;
        }
    },

    create_feed_store: function(){
        return new Ext.data.JsonStore({
            url:"/dashboard/feed_articles.json",
            idProperty: "id",
            fields:["author", "title", {name:"published", type:"date"}, "url", "id", "summary"],
            autoLoad:true,
            listeners:{
                'load': function(ct){this.getPanel().doLayout();},
                scope:this
            }
        });
    },

    create_feed_template: function(){
        return new Ext.XTemplate(
                '<tpl for=".">',
                    '<div class="feed_article">',
                        '<h2><a href="{url}" target="_blank">{title}</a></h2>',
                        '<h4>{author}</h4>',
                        '<p class="date">{[values.published == null ? "" : values.published.toLocaleString()]}</p>',
                        '<p class="partArticle">{[this.shortSummary(values.summary)]} <tpl if="this.shortSummary(summary).length &gt;= 300"> <a class="more_btn inlineLink">(more)</a></tpl></p>',
                        '<p class="fullArticle">{summary} <a class="less_btn inlineLink">(less)</a></p>',
                    '</div>',
                '</tpl>',
        {
            compiled:true,
            shortSummary: function(summary){
                var cleanSummary = summary.stripTags(true, "'br'");
                if(cleanSummary.length > 300)
                {
                    cleanSummary = cleanSummary.substr(0, 300) + '...';
                }

                return cleanSummary;
            }
        });
    }
});

Talho.Article3Panel.initialize = function(config)
{
    return (new Talho.Article3Panel(config)).getPanel();
}
