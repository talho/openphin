/**
 * @class Talho.ux.tab.DraggablePanel
 * @extends Ext.tab.Bar
 * <p>Creates a drag zone for the tab bar so tabs can be dragged onto different targets.</p>
 * <p>Further versions of this may allow for tab reordering and such.
 */
Ext.define('Talho.ux.tab.DraggablePanel', {
  extend : 'Ext.tab.Panel',
  alias : ['widget.draggablepanel'],
  initComponent : function() {
    Talho.ux.tab.DraggablePanel.superclass.initComponent.apply(this, arguments);
    this.on('render', function(tp) {
      // set up drag zone
      this.dragZone = Ext.create('Ext.dd.DragZone', tp.getTabBar().getEl(), {
        ddGroup: this.ddGroup,
        getDragData : function(e) {
          var tab = e.getTarget('.x-tab', 10);

          if(tab) {
            d = tab.down().cloneNode(true);
            d.id = Ext.id();
            return {
              ddel : d,
              sourceEl : tab,
              repairXY : Ext.fly(tab.down()).getXY(),
              item : tab.card
            }
          }
        },
        getRepairXY: function() {
          return this.dragData.repairXY;
        }
      });
    }, this, {delay: 1});
  }
})