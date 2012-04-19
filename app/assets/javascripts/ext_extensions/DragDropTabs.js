Ext.ns("Ext.plugin");

Ext.plugin.DragDropTabs = (function() {
    var TabProxy = Ext.extend(Ext.dd.StatusProxy, {
        constructor: function(config) {
            TabProxy.superclass.constructor.call(this, config);
            // Custom class needed on the proxy so the tab can
            // be dropped in and retain its styles
            this.el.addClass("dd-tabpanel-proxy");
        },
        reset: function(config) {
            TabProxy.superclass.reset.apply(this, arguments);
            this.el.addClass("dd-tabpanel-proxy");
            this.ghost.removeClass(["x-tab-strip-top","x-tab-strip-bottom"]);
        }
    }),
            TabDragZone = Ext.extend(Ext.dd.DragZone, {
                constructor: function(tp, config) {
                    this.tabpanel = tp;
                    this.ddGroup = tp.ddGroup;
                    this.proxy = new TabProxy();
                    TabDragZone.superclass.constructor.call(this, tp.strip, config);
                },
                getDragData: function(e) {
                    var t = this.tabpanel.findTargets(e);
                    if (t.el && ! t.close) {
                        return {
                            ddel: t.el,
                            tabpanel: this.tabpanel,
                            repairXY: Ext.fly(t.el).getXY(),
                            item: t.item,
                            index: this.tabpanel.items.indexOf(t.item)
                        }
                    }
                    return false;
                },
                onInitDrag: function() {
                    TabDragZone.superclass.onInitDrag.apply(this, arguments);
                    var strip = this.tabpanel.strip,
                            ghostClass;
                    // In order for the tab to appear properly within the
                    // ghost, we need to add the correct class from the
                    // tab strip
                    if (strip.hasClass("x-tab-strip-top")) {
                        ghostClass = "x-tab-strip-top";
                    } else if (strip.hasClass("x-tab-strip-bottom")) {
                        ghostClass = "x-tab-strip-bottom";
                    }
                    this.proxy.getGhost().addClass(ghostClass);
                    return true;
                },
                getRepairXY: function() {
                    return this.dragData.repairXY;
                }
            }),
            TabDropTarget = Ext.extend(Ext.dd.DropTarget, {
                constructor: function(tp, config) {
                    this.tabpanel = tp;
                    this.ddGroup = tp.ddGroup;
                    TabDropTarget.superclass.constructor.call(this, tp.strip, config);
                },
                notifyDrop: function(dd, e, data) {
                    var tp = this.tabpanel,
                            t = tp.findTargets(e),
                            i = tp.items.indexOf(t.item),
                            activeTab = tp.getActiveTab();
                    if (tp === data.tabpanel) {
                        tp.suspendEvents();
                    }
                    data.tabpanel.remove(data.item, false);
                    tp.insert(i, data.item);
                    tp.setActiveTab(activeTab);
                    if (tp === data.tabpanel) {
                        tp.resumeEvents();
                        tp.fireEvent("tabmove", tp, i, data.index);
                    }
                    return true;
                }
            }),
        // Methods attached to the TabPanel
            onTabPanelRender = function() {
                this.dragZone = new TabDragZone(this);
                this.dropTarget = new TabDropTarget(this);
            },
            onTabPanelInitEvents = function() {
                this.mun(this.strip, "mousedown", this.onStripMouseDown, this);
                this.mon(this.strip, "click", this.onStripMouseDown, this);
            },
            onTabPanelDestroy = function() {
                Ext.destroy(this.dragZone, this.dropTarget);
                if (this.dragZone) {
                    this.dragZone.destroy();
                }
                if (this.dropTarget) {
                    this.dropTarget.destroy();
                }
            };

    return {
        init: function(tp) {
            Ext.applyIf(tp, {
                ddGroup:"TabPanelDD",
                tabSwitchOnClick: false
            });
            tp.addEvents("tabmove");
            tp.afterMethod("onRender", onTabPanelRender);
            if (tp.tabSwitchOnClick) {
                tp.afterMethod("initEvents", onTabPanelInitEvents);
            }
            tp.afterMethod("onDestroy", onTabPanelDestroy);
        }
    };
})();

Ext.preg('dragdroptabs', Ext.plugin.DragDropTabs);
