Ext.namespace('Talho');

Talho.Article3Panel = Ext.extend(Ext.util.Observable, {
    constructor: function()
    {
        var stormPulseHTML = '<div class="article">\
        <h2>2010 Hurricane Season Tracking Map</h2>\
        <p class="date">July 08, 2010</p>\
        <div class="lede">\
          <p>'
        if(window.rails_environment == "development" || window.rails_environment == "test" || window.rails_environment == "cucumber")
            stormPulseHTML += '<embed width="100%" height="590" flashvars="host=www.txphin.org&amp;key=2h9xhxuiksqthv5kaql5p84qmhz3gjygi6n70002" allowscriptaccess="always" quality="high" bgcolor="#000000" name="stormpulse" id="stormpulse" src="http://www.stormpulse.com/swf/stormpulse.swf?v=223&amp;env=API&amp;region=10" type="application/x-shockwave-flash">'
        else
            stormPulseHTML +=  '<script src="http://www.stormpulse.com/api/maps/current/?key=2h9xhxuiksqthv5kaql5p84qmhz3gjygi6n70002" type="text/javascript"></script>'

        stormPulseHTML +='</p>\
          <br/>\
          <p class="article_link"><a href="http://www.stormpulse.com" target="_blank" title="Via: www.stormpulse.com.  Click here for original.">Via: www.stormpulse.com. Click here for original.</a></p>\
        </div>\
      </div>'

        this.stormPulsePanel = new Ext.Panel({
            flex: 1,
            autoHeight:true,
            html: stormPulseHTML
        });

        this.newsFeedPanel = new Ext.Panel({
            flex: 1,
            autoHeight:true,
            items: new Ext.DataView({
                store: this.create_feed_store(),
                singleSelect: false,
                autoHeight: true,
                tpl: this.create_feed_template(),
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
                     cpt.getUpdater().update({url:'dashboard/news_articles'});
                }
            }
        });


        var panel = new Ext.Panel({
            title: 'Home',
            layout:'hbox',
            layoutConfig: {defaultMargins:'15'},
            items: [this.stormPulsePanel, this.newsFeedPanel, this.staticNewsPanel],
            autoScroll: true,
            hideBorders: true
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
                        '<p class="date">{[values.published.toLocaleString()]}</p>',
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

Talho.Article3Panel.initialize = function()
{
    return (new Talho.Article3Panel).getPanel();
}
