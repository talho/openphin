Ext.namespace('Talho');

Talho.Article3Panel = Ext.extend(Ext.util.Observable, {
    constructor: function(config)
    {
        Ext.apply(this, config);

        Talho.Article3Panel.superclass.constructor.call(this, config);

        this.linksPanel = new Ext.Panel({
            flex: 1,
            autoHeight:true,
            html: window.Application.rails_environment == "cucumber" ? "" : "  <div class='article'>\
  <h2>Q&amp;A for Mercury Poisoning Cluster Associated with Use of Aguamary Creams</h2>\
  <p class='date'>September 6, 2011</p>\
  <div class='lede'>\
    <p>Please click below to download the Q&amp;A</p>\
    <p class='article_link'><a href='http://www.txphin.org/faq/Mercury_Q_A.doc' target='_blank' title='Mercury Q&amp;A'>Mercury Q&amp;A</a></p>\
 </div>\
  <br/>\
</div>\
<div class='article'>\
  <h2>HEAT STRESS SAFETY - Emphasis and Behavior Modification</h2>\
  <p class='date'>August 3, 2011</p>\
  <div class='lede'>\
    <p>DSHS continues to urge Texans to take precautions against the extremely high temperatures and heat indexes that have prevailed throughout the state for several weeks with no immediate let-up projected.  For more information please see the following very important and helpful links:</p>\
    <p class='article_link'><a href='http://www.texasprepares.org/English/information-ex-heat.shtml' target='_blank' title='DSHS Extreme Heat Info'>DSHS Extreme Heat Info</a></p>\
    <p class='article_link'><a href='http://www.bt.cdc.gov/disasters/extremeheat/heat_guide.asp' target='_blank' title='CDC Extreme Heat Info'>CDC Extreme Heat Info</a></p>\
    <p class='article_link'><a href='http://www.osha.gov/SLTC/heatstress/index.html' target='_blank' title='OSHA Heat Stress Info'>OSHA Heat Stress Info</a></p>\
  </div>\
  <br/>\
</div>\
<div class='article'>\
  <h2>Disaster Preparedness</h2>\
  <p class='date'>January 9, 2011</p>\
  <div class='lede'>\
    <p class='article_link'><a href='http://www.dshs.state.tx.us/preparedness/' target='_blank' title='Public Health Preparedness'>Public Health Preparedness</a></p>\
    <p class='article_link'><a href='http://www.dhs.gov/files/prepresprecovery.shtm' target='_blank' title='Preparedness, Response & Recovery'>Preparedness, Response & Recovery</a></p>\
  </div>\
</div>\
<br/>\
<div>\
  <p>\
    <img src=\"/assets/CDC-HHST.png\" align=\"left\"/><b>Tip of the Week:</b> Be informed about how to protect your health and safety after a hurricane strikes.<br/><br/>For additional tips, fact sheets, and podcasts, see <a href=\"http://emergency.cdc.gov/disasters/hurricanes/recovery.asp?source=govdelivery\">CDC's Hurricanes website</a>.\
  </p>\
</div>\
<br/>\
<!-- ############################# --> <!-- WIDGET EMBED CODE STARTS HERE --> <div>\
  <h3 id=\"start-widget-focus\">\
    <a href=\"http://emergency.cdc.gov/disasters/hurricanes/readiness.asp\">Hurricane Health & Safety Tips </a>\
  </h3>\
  <p>\
  <br />\
  <!--[if!IE]><!-->\
    <object tabindex=\"0\" id=\"widgetID\" data=\"http://www.cdc.gov/widgets/HurricaneTip/HurricaneTip.swf\" width=\"170\" height=\"340\" type=\"application/x-shockwave-flash\" title=\"Hurricane Health & Safety Tips Widget\">\
      <param name=\"quality\" value=\"high\"/>\
      <param name=\"AllowScriptAccess\" value=\"always\"/>\
      <param name=\"FlashVars\" value=\"bg=ffffff\"/>\
      <param name=\"pluginurl\" value=\"http://get.adobe.com/flashplayer/\"/>\
      <div style=\"width:auto\">\
        <img src=\"http://www.cdc.gov/widgets/HurricaneTip/HurricaneTip.jpg\" width=\"170\" height=\"340\" alt=\"Hurricane Health & Safety Tips Widget. Flash Player 9 is required.\"/>\
        <br />Hurricane Health & Safety Tips Widget. <br />\
        <a href=\"http://get.adobe.com/flashplayer/\">Flash Player 9 is required.</a>\
      </div>\
    </object>\
  <!--><![endif]-->\
  <!--[if IE]>\
    <object tabindex=\"0\" id=\"widgetID\" classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" codebase=\"http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0\" width=\"170\" height=\"340\" title=\"widgetTitle\">\
      <param name=\"movie\" value=\"http://www.cdc.gov/widgets/HurricaneTip/HurricaneTip.swf\"/>\
      <param name=\"quality\" value=\"high\"/>\
      <param name=\"AllowScriptAccess\" value=\"always\"/>\
      <param name=\"FlashVars\" value=\"bg=ffffff\"/>\
      <div style=\"width:auto\">\
        <img src=\"http://www.cdc.gov/widgets/HurricaneTip/HurricaneTip.jpg\" width=\"170\" height=\"340\" alt=\"Hurricane Health & Safety Tips Widget. Flash Player 9 is required.\"/>\
        <br />Hurricane Health & Safety Tips Widget.<br />\
        <a href=\"http://get.adobe.com/flashplayer/\">Flash Player 9 is required.</a>\
      </div>\
    </object>\
  <![endif]-->\
  <a id=\"end-widget-focus\"></a>\
  </p>\
</div> <!-- WIDGET EMBED CODE ENDS HERE --> <!-- ############################# -->"
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
