Ext.ns('Talho.ux');

/*
 * D3Graph is a wrapper on top of the D3 drawing library. 
 */
Talho.ux.D3Graph = Ext.extend(Ext.BoxComponent, {
  /*
   * @cfg     {String}        xField          The store field that will indicate the x-value for all plotted series
   * @cfg     {Number}        [yMin]          Optional: The minimum y-value of the graph. This is calculated automatically, but is useful if you wish to
   *                                            normalize drawing for comparison
   * @cfg     {Number}        [yMax]          Optional: The maximum y-value of the graph. This is calculated automatically, but is useful if you wish to
   *                                            normalize drawing for comparison
   * @cfg     {Object/Array}  series          A series configuration object that identifies the fields and graphing types
   * @series  {String}        [type]          Optional: the type of data to plot. Default: 'line'. (No others implemented)
   * @series  {String}        yField          The store field that will indicate the y-value for this series
   * @series  {String}        [xField]        Optional: The store field that will indicate the x-value for this series. This is overriden by the base xField
   *                                            and is only valid for the first series.
   * @series  {String}        [displayName]   Optional: if set, will be used in the tooltip for the data value.
   * @series  {Object}        [style]         Optional: a configuration object to indicate how to draw the graph
   * @style   {String}        [stroke]        Optional: the color to use for this object's rendering. Accepts Hex or css color names. Default 'black'
   * @cfg     {String}        [yLabel]        Optional: the label for the y-axis, will be drawn if provided
   * @cfg     {String}        [xLabel]        Optional: the label for the x-axis, will be drawn if provided
   * @cfg     {String}        [xDisplayName]  Optional: a label for the tool tip of the x value
   */
  initComponent: function(){
    Talho.ux.D3Graph.superclass.initComponent.apply(this, arguments);
    
    if(!this.series){
      throw "D3Graph requires a series to be provided."
    }
    
    if(!Ext.isArray(this.series)){
      this.series = [this.series];
    }
    Ext.each(this.series, function(s){s.style = s.style || {}}, this);
    
    this.store.on('load', this.draw, this);
    this.on('resize', this.draw, this);
    if(this.store.getCount() > 0){
      this.on('afterrender', this.draw, this, {delay: 1});
    }    
  },
  
  draw: function(){    
    if(this.store.getCount() == 0){
      return;
    }
    
    var y_fields = Ext.pluck(this.series, "yField"), 
        x_field = this.xField || this.series[0].xField,
        y_max = this.yMax || this.store.max(y_fields),      
        h = this.getHeight(),
        w = this.getWidth(),
        padding = {
          top: 7 + (this.showLegend ? 15 : 0),
          right: 20,
          bottom: 20 + (this.xLabel ? 15 : 0),
          left: ((y_max > 5) ? (Math.log(y_max) / Math.LN10 | 0) + 1 : 3)*10 + 5 + (this.yLabel ? 15 : 0)
        },
        count = this.store.getCount(),
        x = this._getTimeScale([this.store.min(x_field), this.store.max(x_field)], [padding.left, w - padding.right]),
        y = this._getLinearScale([this.yMin || 0, y_max], [h - padding.bottom, padding.top]);
    
    var old_svg = d3.select("#" + this.id).select("svg");
    if(old_svg){old_svg.remove();}
    
    var svg = d3.select("#" + this.id).data([this.store.getRange()]).append("svg:svg").attr("width", w).attr("height", h).append("svg:g");
    
    if(this.showLegend){ this._drawLegend(svg); }
    
    this._drawRules(svg, x, y, padding, count);
      
    this._drawAxes(svg, x, y, padding, Math.min(count, 10), 6);
    
    if(this.yLabel){ this._drawYLabel(svg, padding); }
    if(this.xLabel){ this._drawXLabel(svg, padding); }
    
    Ext.each(this.series, function(series){
      this._drawLineGraph(svg, series, x, y, x_field);
    }, this);
  },
  
  /****************** Scaling ********************/
  _getTimeScale: function(domain, range){
    return d3.time.scale.utc().domain(domain).range(range);
  },
  
  _getLinearScale: function(domain, range){
    return d3.scale.linear().domain(domain).range(range);
  }, 
  
  /****************** Drawing ********************/
 
  _drawLegend: function(svg){
    var legend = svg.append("svg:g").attr('class', 'legend'),
        offset = 0;
        
    Ext.each(this.series, function(series){
      legend.append("svg:line").attr('x1', offset).attr('x2', offset + 15).attr('y1', '-1').attr('y2', '-1').attr('stroke', series.style.stroke || 'black');
      offset += 17
      var text = legend.append("text").text(series.displayName).attr('dy', '.5ex').attr('transform', 'translate(' + offset + ',0)');
      offset += text.node().getBBox().width + 10;
    });
    
    legend.attr('transform', 'translate(' + (this.getWidth() - offset)/2 + ',9)')
  },
  
  _drawRules: function(svg, x, y, padding, count){
    var rules = svg.selectAll("g.rule")
      .data(x.ticks(Math.min(count, 10)))
      .enter().append("svg:g")
      .attr("class", "rule"); 
      
    rules.append("svg:line")
      .attr("x1", x)
      .attr("x2", x)
      .attr("y1", padding.top)
      .attr("y2", this.getHeight() - padding.bottom)
      
    rules.append("svg:line")
      .data(y.ticks(6))
      .attr("y1", y)
      .attr("y2", y)
      .attr("x1", padding.left)
      .attr("x2", this.getWidth() - padding.right)
  },
  
  _drawAxes: function(svg, x, y, padding, x_ticks, y_ticks){
    svg.append("svg:g")
      .attr("class", "x axis")
      .call(
        d3.svg.axis().scale(x).orient('bottom').ticks(x_ticks || 10).tickFormat(d3.time.format.utc('%m-%d'))
      )
      .attr("transform", "translate(0," + (this.getHeight() - padding.bottom).toString() + ")");
      
    svg.append("svg:g")
      .attr('class', 'y axis')
      .call(
        d3.svg.axis().scale(y).orient('left').ticks(y_ticks || 6)
      )
      .attr('transform', "translate(" + padding.left + ",0)")
  },
  
  _drawLineGraph: function(svg, series, x, y, x_field){
    svg.append("svg:path")
      .attr("class", "trace")
      .attr('stroke', series.style.stroke || 'black')
      .attr("d", d3.svg.line()
        .x(function(d){ return x(d.get(x_field)); })
        .y(function(d){ return y(d.get(series.yField)); }))
        
    svg.selectAll("circle.line")
      .data(this.store.getRange()).enter()
      .append("svg:circle")
      .attr('class', 'point')
      .attr('stroke', series.style.stroke || 'black')
      .attr("cx", function(d) {return x(d.get(x_field));})
      .attr("cy", function(d) {return y(d.get(series.yField));})
      .attr("r", 3.5)
      .attr("ext:qtip", series.qtip || function(d){
        var x_val = d.get(x_field);
        return '<div class="d3-tip-row"><span>' + (this.xDisplayName || x_field) + ':</span><span>' + (Ext.isDate(x_val) ? d3.time.format.utc('%m-%d-%y')(x_val) : x_val) + '</span></div>' +
               '<div class="d3-tip-row"><span>' + (series.displayName || series.yField) + ':</span><span>' + d.get(series.yField) + '</span></div>'; 
       }.createDelegate(this));
  },
  
  /****************** Labels *********************/
  _drawXLabel: function(svg, padding){
    svg.append("text")
      .attr("class", "y label")
      .attr("text-anchor", "middle")
      .attr("transform", "translate("+ (padding.left + (this.getWidth() - padding.left - padding.right)/2) + "," + this.getHeight() + ")")
      .text(this.xLabel);
  },
 
  _drawYLabel: function(svg, padding){
    svg.append("text")
      .attr("class", "y label")
      .attr("text-anchor", "middle")
      .attr("dy", ".75em")
      .attr("transform", "translate(0," + (padding.top + (this.getHeight() - padding.top - padding.bottom)/2) + ") rotate(-90)")
      .text(this.yLabel);
  },
  
});
