

(function(){
    Ext.override(Ext.ux.maximgb.tg.GridView, {
        renderCellTreeUI : function(record, store)
        {
            if(store.isFiltered())
            {
                return this.templates.treeui.apply({});
            }

            var tpl = this.templates.treeui,
                line_tpl = this.templates.elbow_line,
                tpl_data = {},
                rec, parent,
                depth = level = store.getNodeDepth(record);

            tpl_data.wrap_width = (depth + 1) * 16;
            if (level > 0) {
                tpl_data.elbow_line = '';
                rec = record;
                left = 0;
            }
            if (!store.isLeafNode(record)) {
                tpl_data.cls = 'ux-maximgb-tg-elbow-active ';
                if (store.isExpandedNode(record)) {
                    if (store.hasNextSiblingNode(record)) {
                        tpl_data.cls += this.expanded_icon_class;
                    }
                    else {
                        tpl_data.cls += this.last_expanded_icon_class;
                    }
                }
                else {
                    if (store.hasNextSiblingNode(record)) {
                        tpl_data.cls += this.collapsed_icon_class;
                    }
                    else {
                        tpl_data.cls += this.last_collapsed_icon_class;
                    }
                }
            }
            tpl_data.left = 1 + depth * 16;

            return tpl.apply(tpl_data);
        },
        
        // Private - Overriden
        doRender : function(cs, rs, ds, startRow, colCount, stripe)
        {
            var filtered = ds.isFiltered();
            var ts = this.templates, ct = ts.cell, rt = ts.row, last = colCount-1;
            var tstyle = 'width:'+this.getTotalWidth()+';';
            // buffers
            var buf = [], cb, c, p = {}, rp = {tstyle: tstyle}, r;
            for (var j = 0, len = rs.length; j < len; j++) {
                r = rs[j]; cb = [];
                var rowIndex = (j+startRow);

                var row_render_res = this.renderRow(r, rowIndex, colCount, ds, this.cm.getTotalWidth());

                if (row_render_res === false) {
                    for (var i = 0; i < colCount; i++) {
                        c = cs[i];
                        p.id = c.id;
                        p.css = i == 0 ? 'x-grid3-cell-first ' : (i == last ? 'x-grid3-cell-last ' : '');
                        p.attr = p.cellAttr = "";
                        p.value = c.renderer.call(c.scope, r.data[c.name], p, r, rowIndex, i, ds);
                        p.style = c.style;
                        if(Ext.isEmpty(p.value)){
                            p.value = "&#160;";
                        }
                        if(this.markDirty && r.dirty && typeof r.modified[c.name] !== 'undefined'){
                            p.css += ' x-grid3-dirty-cell';
                        }
                        // ----- Modification start
                        if (c.id == this.grid.master_column_id) {
                            p.treeui = this.renderCellTreeUI(r, ds);
                            ct = ts.mastercell;
                        }
                        else {
                            ct = ts.cell;
                        }
                        // ----- End of modification
                        cb[cb.length] = ct.apply(p);
                    }
                }
                else {
                    cb.push(row_render_res);
                }

                var alt = [];
                if (stripe && ((rowIndex+1) % 2 == 0)) {
                    alt[0] = "x-grid3-row-alt";
                }
                if (r.dirty) {
                    alt[1] = " x-grid3-dirty-row";
                }
                rp.cols = colCount;
                if(this.getRowClass){
                    alt[2] = this.getRowClass(r, rowIndex, rp, ds);
                }
                rp.alt = alt.join(" ");
                rp.cells = cb.join("");
                // ----- Modification start
                if (!filtered && !ds.isVisibleNode(r)) {
                    rp.display_style = 'display: none;';
                }
                else {
                    rp.display_style = '';
                }
                rp.level = ds.getNodeDepth(r);
                // ----- End of modification
                buf[buf.length] =  rt.apply(rp);
            }
            return buf.join("");
        }
    });

    var oldSetActiveNode = Ext.ux.maximgb.tg.AbstractTreeStore.prototype.setActiveNode;
    Ext.override(Ext.ux.maximgb.tg.AbstractTreeStore, {
        setActiveNode : function()
        {
            if(!this.isFiltered()){
                oldSetActiveNode.apply(this, arguments);
            }
        },

        getNodeDescendants: function(rc)
        {
            if(!this.hasChildNodes(rc)) // if there are no child nodes
                return [];              // return an empty array

            var arr = this.getNodeChildren(rc);
            var desc = [];
            Ext.each(arr, function(node){desc = desc.concat(this.getNodeDescendants(node))}, this);

            return arr.concat(desc);
        }
    });

    var original_gridview_dorender = Ext.ux.maximgb.tg.GridView.prototype.doRender;
    Ext.override(Ext.ux.maximgb.tg.GridView, {
        doRender: function(){
            var ret = original_gridview_dorender.apply(this, arguments);

            var sel = this.grid.getSelectionModel().getSelections();

            if(sel.length > 0)
            {
                setTimeout(function(){
                        var store = this.grid.getStore();
                        Ext.each(sel, function(sel){
                            var row = store.indexOf(sel);
                            if(row === -1) row = store.indexOfId(sel.id);
                            if(row >= -1) this.onRowSelect(row);
                        }, this);
                }.bind(this), 1);
            }

            return ret;
        }
    });
})();