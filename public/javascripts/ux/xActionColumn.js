
/**
 * @class Ext.ux.grid.xActionColumn
 * @extends Ext.grid.ActionColumn
 * <p>A Grid column type which renders an icon, or a series of icons in a grid cell, and offers a scoped click
 * handler for each icon. This expands on the Action column by including autoWidth and hideable buttons. Example usage:</p>
<pre><code>
new Ext.grid.GridPanel({
    store: myStore,
    columns: [
        {
            xtype: 'xactioncolumn',
            items: [
                {
                    icon     : 'sell.gif',                // Use a URL in the icon config
                    width    : 21,
                    height   : 10,
                    showField: 'quantity' // shows if record.get('quantity') is truthy (in this case if quantity > 0)
                },
                {
                    icon     : 'buy.gif',
                    hideField: 'no_money' // hides if record.get(hideField) is truthy
                }
            ]
        }
        //any other columns here
    ]
});
</pre></code>
 */
Ext.define('Talho.ux.xActionColumn', {
    alertnateClassName: ['Ext.ux.grid.xActionColumn'],
    extend: 'Ext.grid.ActionColumn',
    alias: ['widget.xactioncolumn'], 
    /**
     * @cfg {String} hideField
     * Optional. The record field that indicates if a button should be hidden. Hides whenever record.get(hideField) is truthy.
     */
    /**
     * @cfg {String} showField
     * Optional. The record field that indicates if a button should be hidden. Hides whenever record.get(showField) is not truthy.
     */
    /**
     * @cfg {Number} height
     * Optional. The height of the image, set on the image for image scaling
     */
    /**
     * @cfg {Number} width
     * Optional. The width of the image, used in calculating auto size and set on the image for image scaling. (default: 16)
     */
    /**
     * @cfg {Array} items An Array which may contain multiple icon definitions, each element of which may contain:
     * <div class="mdetail-params"><ul>
     * <li><code>icon</code> : String<div class="sub-desc">The url of an image to display as the clickable element
     * in the column.</div></li>
     * <li><code>iconCls</code> : String<div class="sub-desc">A CSS class to apply to the icon image.
     * To determine the class dynamically, configure the item with a <code>getClass</code> function.</div></li>
     * <li><code>getClass</code> : Function<div class="sub-desc">A function which returns the CSS class to apply to the icon image.
     * The function is passed the following parameters:<ul>
     *     <li><b>v</b> : Object<p class="sub-desc">The value of the column's configured field (if any).</p></li>
     *     <li><b>metadata</b> : Object<p class="sub-desc">An object in which you may set the following attributes:<ul>
     *         <li><b>css</b> : String<p class="sub-desc">A CSS class name to add to the cell's TD element.</p></li>
     *         <li><b>attr</b> : String<p class="sub-desc">An HTML attribute definition string to apply to the data container element <i>within</i> the table cell
     *         (e.g. 'style="color:red;"').</p></li>
     *     </ul></p></li>
     *     <li><b>r</b> : Ext.data.Record<p class="sub-desc">The Record providing the data.</p></li>
     *     <li><b>rowIndex</b> : Number<p class="sub-desc">The row index..</p></li>
     *     <li><b>colIndex</b> : Number<p class="sub-desc">The column index.</p></li>
     *     <li><b>store</b> : Ext.data.Store<p class="sub-desc">The Store which is providing the data Model.</p></li>
     * </ul></div></li>
     * <li><code>handler</code> : Function<div class="sub-desc">A function called when the icon is clicked.</div></li>
     * <li><code>scope</code> : Scope<div class="sub-desc">The scope (<code><b>this</b></code> reference) in which the
     * <code>handler</code> and <code>getClass</code> functions are executed. Fallback defaults are this Column's
     * configured scope, then this Column.</div></li>
     * <li><code>tooltip</code> : String<div class="sub-desc">A tooltip message to be displayed on hover.
     * {@link Ext.QuickTips#init Ext.QuickTips} must have been initialized.</div></li>
     * <li><code>width</code> : Number<div class="sub-desc">The width of the image, used in calculating auto size and set on the image for image scaling. (default: 16)</div></li>
     * <li><code>height</code> : Number<div class="sub-desc">The height of the image, set on the image for image scaling</div></li>
     * <li><code>hideField</code> : String<div class="sub-desc">The record field that indicates if a button should be hidden. Hides whenever record.get(hideField) is truthy.</div></li>
     * <li><code>showField</code> : String<div class="sub-desc">The record field that indicates if a button should be shows. Hides whenever record.get(showField) is not truthy.</div></li>
     * </ul></div>
     */

    /**
     * @cfg {Boolean} autoWidth calculates the width of the column. Overrides any width set in config. Defaults to <tt>'true'</tt>
     */
    autoWidth: true,

    /**
     * @cfg {Number} widthExtra Adds extra pixels to the width of the column. Defaults to <tt>8</tt>
     */
    widthExtra: 10,

    /**
     * @cfg {Number} widthScope The default width of each button image. Defaults to <tt>16</tt>
     */
    widthScope: 16,

    /**
     * @cfg {Number} widthExtra Adds extra pixels to the width of the column. Defaults to <tt>4</tt>
     */

    /**
     * @cfg {Boolean} fixed Optional. <tt>true</tt> if the column width cannot be changed.  Defaults to <tt>true</tt>.
     */
    fixed: true,

    /**
     * @cfg {Boolean} vertical Optional. <tt>true</tt> the images should be rendered vertically instead of horizontally.  Defaults to <tt>false</tt>.
     */
    vertical: false,
    constructor: function(cfg) {
        var me = this,
            items = cfg.items || (me.items = [me]),
            l = items.length,
            i,
            item;

        Talho.ux.xActionColumn.superclass.constructor.call(me, cfg);

        if(this.autoWidth && this.vertical){
            me.width = me.widthScope + this.widthExtra;
        }
        else if(this.autoWidth){
            if(!cfg.items)
                me.width = me.widthScope + this.widthExtra; // This is to fix and issue with the column width if we are providing an inline icon definition
            else{
                var totWidth = 0;
                for(i = 0; i < l; i++){
                    totWidth += items[i].width || this.widthScope;
                }
                this.width = totWidth + this.widthExtra;
            }
        }

//      Renderer closure iterates through items creating an <img> element for each and tagging with an identifying
//      class name x-action-col-{n}
        me.renderer = function(v, meta, record) {
//          Allow a configured renderer to create initial value (And set the other values in the "metadata" argument!)
            v = Ext.isFunction(cfg.renderer) ? cfg.renderer.apply(this, arguments)||'' : '';

            meta.css += ' x-action-col-cell';
            for (i = 0; i < l; i++) {
                item = items[i];
                // if this field should be hidden or not shown, we need to create a placeholder for the column. Since the css and everything expects and image, let's use the Ext blank image here and stretch it to fill the expected width.
                if((Ext.isString(item.hideField) && record.get(item.hideField)) || (Ext.isString(item.showField) && !record.get(item.showField)) )
                    v += '<img src="' + Ext.BLANK_IMAGE_URL + '" class="x-action-col-icon"' +
                        ' width="' + ((item.width) ?  item.width : me.widthScope) + '"' +
                        ' height="0"' + ' />';
                else{
                    if(this.vertical) v += '<div>';

                    v += '<img alt="' + me.altText + '" src="' + (item.icon || Ext.BLANK_IMAGE_URL) +
                        '" class="x-action-col-icon x-action-col-' + String(i) + ' ' + (item.iconCls || '') +
                        ' ' + (Ext.isFunction(item.getClass) ? item.getClass.apply(item.scope||this.scope||this, arguments) : '') + '"' +
                        ((item.width) ? ' width="' + (!cfg.items ? item.width - me.widthExtra : item.width) + '"' : '') +
                        ((item.height) ? ' height="' + item.height + '"' : '') +
                        ((item.tooltip) ? ' ext:qtip="' + item.tooltip + '"' : '') + ' />';

                    if(this.vertical) v += '</div>';
                }
            }
            return v;
        };
    }
});
