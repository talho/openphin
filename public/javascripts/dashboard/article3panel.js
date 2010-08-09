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
            html: stormPulseHTML
        });

        this.newsFeedPanel = new Ext.Panel({
            flex: 1,
            html: 'News Feed'
        });

        this.staticNewsPanel = new Ext.Panel({
            flex: 1,
            html: 'Articles'
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
    }

});

Talho.Article3Panel.initialize = function()
{
    return (new Talho.Article3Panel).getPanel();
}
