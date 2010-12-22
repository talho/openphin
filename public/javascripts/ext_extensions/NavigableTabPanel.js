
Ext.ns('Ext.ux');

Ext.ux.NavigableTabPanel = Ext.extend(Ext.TabPanel, {
    constructor: function(){
        this.addEvents('back', 'forward', 'refresh');
        Ext.ux.NavigableTabPanel.superclass.constructor.apply(this, arguments);
    },

    onRender: function(){
        Ext.ux.NavigableTabPanel.superclass.onRender.apply(this, arguments);

        var st = this[this.stripTarget];
        st.addClass('ux-navigable-tab-panel-header');
        this.stripWrap.addClass('ux-strip-wrap-for-navigation');

        this.navigationList = st.createChild({tag: 'ul', cls: 'ux-navigation-wrap'}, this.stripWrap);

        this.backButton = this.navigationList.createChild({tag: 'li', cls: 'ux-navigation-button ux-navigation-disabled', qtip: 'back', cn:{
            tag: 'span', cls: 'ux-back-button'}
        });
        this.forwardButton = this.navigationList.createChild({tag: 'li', cls: 'ux-navigation-button ux-navigation-disabled', qtip: 'forward', cn:{
            tag: 'span', cls: 'ux-forward-button'}
        });
        this.refreshButton = this.navigationList.createChild({tag: 'li', cls: 'ux-navigation-button ux-navigation-disabled', qtip: 'refresh', cn:{
            tag: 'span', cls: 'ux-refresh-button'}
        });

        var enable = function(){ this.removeClass('ux-navigation-disabled'); };
        var disable = function(){ this.addClass('ux-navigation-disabled'); };
        var setDisabled = function(dis){
            if(dis){
                this.disable();
            }
            else{
                this.enable();
            }
        };

        this.backButton.enable = enable;
        this.backButton.disable = disable;
        this.backButton.setDisabled = setDisabled;
        this.forwardButton.enable = enable;
        this.forwardButton.disable = disable;
        this.forwardButton.setDisabled = setDisabled;
        this.refreshButton.enable = enable;
        this.refreshButton.disable = disable;
        this.refreshButton.setDisabled = setDisabled;

        var clickEvent = function(e, htmlEle, options){
            var ele = new Ext.Element(htmlEle);
            if(!ele.hasClass('x-navigation-disabled')){
                this.fireEvent(options.evt);
            }
        };

        this.backButton.on('click', clickEvent, this, {evt: 'back'});
        this.forwardButton.on('click', clickEvent, this, {evt: 'forward'});
        this.refreshButton.on('click', clickEvent, this, {evt: 'refresh'});
    },

    delegateUpdates : function(){
        Ext.ux.NavigableTabPanel.superclass.delegateUpdates.apply(this, arguments);

        if(!this.enableTabScroll && this.rendered){
            this.stripWrap.setWidth(this.stripWrap.getWidth() - 80);
        }
    },

     // private
    autoScrollTabs : function(){
        this.pos = this.tabPosition=='bottom' ? this.footer : this.header;
        var count = this.items.length,
            ow = this.pos.dom.offsetWidth,
            tw = this.pos.dom.clientWidth - 80,
            wrap = this.stripWrap,
            wd = wrap.dom,
            cw = wd.offsetWidth,
            pos = this.getScrollPos(),
            l = this.edge.getOffsetsTo(this.stripWrap)[0] + pos;

        if(!this.enableTabScroll || cw < 20){ // 20 to prevent display:none issues
            return;
        }
        if(count == 0 || l <= tw){
            // ensure the width is set if there's no tabs
            wd.scrollLeft = 0;
            wrap.setWidth(tw);
            if(this.scrolling){
                this.scrolling = false;
                this.pos.removeClass('x-tab-scrolling');
                this.scrollLeft.hide();
                this.scrollRight.hide();
                // See here: http://extjs.com/forum/showthread.php?t=49308&highlight=isSafari
                if(Ext.isAir || Ext.isWebKit){
                    wd.style.marginLeft = '';
                    wd.style.marginRight = '';
                }
            }
        }else{
            if(!this.scrolling){
                this.pos.addClass('x-tab-scrolling');
                // See here: http://extjs.com/forum/showthread.php?t=49308&highlight=isSafari
                if(Ext.isAir || Ext.isWebKit){
                    wd.style.marginLeft = '18px';
                    wd.style.marginRight = '18px';
                }
            }
            tw -= wrap.getMargins('lr');
            wrap.setWidth(tw > 20 ? tw : 20);
            if(!this.scrolling){
                if(!this.scrollLeft){
                    this.createScrollers();
                }else{
                    this.scrollLeft.show();
                    this.scrollRight.show();
                }
            }
            this.scrolling = true;
            if(pos > (l-tw)){ // ensure it stays within bounds
                wd.scrollLeft = l-tw;
            }else{ // otherwise, make sure the active tab is still visible
                this.scrollToTab(this.activeTab, false);
            }
            this.updateScrollButtons();
        }
    }
});