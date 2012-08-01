//TODO: Get file dependencies

Talho.ux.D3Graph = Ext.extend(Ext.BoxComponent, {
  height: 175,
  padding: {
    top: 20,
    right: 50,
    bottom: 20,
    left: 50
  },
  margin: {
    top: 20,
    right: 40,
    bottom: 20,
    left: 40
  },
  dateFormatParse: d3.time.format("%m-%d-%Y").parse,
  cls: 'ux-d3-graph',
  
  //TODO pull in D3 Graphs from ux on rollcall  
  initComponent: function () {
    this.width = this.width;
    this.xScale = d3.time.scale().range([0, this.width]);
    this.yScale = d3.scale.linear().range([this.height, 0]);
    
    Talho.ux.D3Graph.superclass.initComponent.apply(this, arguments);
        
    this.on('afterrender', this.drawGraph, this);
  },
  
  drawGraph: function () {
    // var data = [];
//     
    // this.store.each( function (record) {
      // data.push({
        // x: d3.time.format("%m-%d-%Y").parse(record.get('report_date')),
        // y: record.get('total')
      // });
    // });
//     
    // var x = d3.time.scale().domain([data[0].x, data[data.length - 1].x]).range([0, this.width - 10]);
    // var y = d3.scale.linear().domain([0, d3.max(data, function(d) { return d.y; })]).range([0, this.height]);
//     
    // var line = d3.svg.line()
      // .x(function (d) { 
        // return x(d.x); 
      // })
      // .y(function (d) { 
        // return y(d.y); 
      // });
//       
    // var graph = d3.select('#' + this.id)
      // .append("svg:svg")
        // .attr("width", this.width)
        // .attr("height", this.height)
      // .append("svg:g")
        // .attr("transform","translate(20)")
// 
    // var xAxis = d3.svg.axis().scale(x).orient("bottom");
//     
    // graph.append("svg:g")
      // .attr("class", "x axis")      
      // .call(xAxis);
//       
    // var yAxis = d3.svg.axis().scale(y).ticks(4).orient("left");
//     
    // graph.append("svg:g")
      // .attr("class", "y axis")      
      // .call(yAxis);
//       
    // graph.append("svg:path")
      // .attr("class", "line")
      // .attr("d", line(data));      
    
    this._getD3GraphData();
    this._getLinesFromData();    
    
    this.area = d3.svg.area().interpolate("monotone")
      .x(function(d) { return this.xScale(d.x); })
      .y0(this.height)
      .y1(function(d) { return this.yScale(d.y); });
      
    this.line = d3.svg.line()
      .x(function(d) { return this.xScale(d.x); })
      .y(function(d) { return this.yScale(d.y); });
      
    this.svg = d3.select('#' + this.id)
      .append("svg:svg")
        .attr("width", this.width + (this.padding.right * 2))
        .attr("height", this.height + (this.padding.top * 2))
      .append("svg:g")
        .attr("transform", "translate(" + (this.padding.top + 10) + "," + (this.padding.top - 15) + ")");
        
    this._buildSVG();
    this._addCircles();
    this._formatLines();
  },
  
  _getD3GraphData: function () {
    var loopData = new Array();
    this.store.each(function (record) {
      loopData.push({
        x:  record.get('report_date'),
        y:  record.get('total'),
        e:  record.get('enrolled'),
        a:  record.get("average"),
        d:  record.get('deviation'),
        a3: record.get('average30'),
        a6: record.get('average60'),
        c:  record.get('cusum')
      });
    });
    this.data = loopData;
  },
  
  _getLinesFromData: function () {
    this.lines = new Array();
    
    if (this.data[0].e > 0)
    {
      this.lines.push([
        d3.svg.line()
          .x(function(d) { return this.xScale(d.x); })
          .y(function(d) { return this.yScale(d.e); }),
        'e'
      ]);
    }
    if ("a" in this.data[0] && this.data[0].a != undefined)
    {
      this.lines.push([
        d3.svg.line()
          .x(function(d) { return this.xScale(d.x); })
          .y(function(d) { return this.yScale(d.a); }),
        'a'
      ]);
    }
    if ("a3" in this.data[0] && this.data[0].a3 != undefined)
    {
      this.lines.push([
        d3.svg.line()
          .x(function(d) { return this.xScale(d.x); })
          .y(function(d) { return this.yScale(d.a3); }),
        'a3'
      ]);
    }
    if ("a6" in this.data[0] && this.data[0].a6 != undefined)
    {
      this.lines.push([
        d3.svg.line()
          .x(function(d) { return this.xScale(d.x); })
          .y(function(d) { return this.yScale(d.a6); }),
        'a6'
      ]);
    }
    if ("d" in this.data[0] && this.data[0].d != undefined)
    {
      this.lines.push([
        d3.svg.line()
          .x(function(d) { return this.xScale(d.x); })
          .y(function(d) { return this.yScale(d.d); }),
        'd'
      ]);
    }
    if ("c" in this.data[0] && this.data[0].c != undefined)
    {
      this.lines.push([
        d3.svg.line()
          .x(function(d) { return this.xScale(d.x); })
          .y(function(d) { return this.yScale(d.c); }),
        'c'
      ]);
    }
  },
  
  _buildSVG: function () {
    var parser = this.dateFormatParse;
    
    this.data.forEach(function(d) {
      d.x = parser(d.x);
      d.y = +d.y;
    });
    
    this.svg
      .append("svg:clipPath")
        .attr("id", "clip")
      .append("svg:rect")
        .attr("width", this.width)
        .attr("height", this.height);
    
    this.svg.append("svg:path")
      .attr("class", "area")
      .attr("clip-path", "url(#clip)")
      .attr("d", this.area(this.data));            
      
    this.svg.append("svg:g")
      .attr("class", "x axis")
      .call(this._getXAxis());
    
    this.svg.append("svg:g")
      .attr("class", "y axis")      
      .call(this._getYAxis());
      
    this.svg.append("svg:path")
      .attr("class", "line")
      .attr("clip-path", "url(#clip)")
      .attr("d", this.line(this.data));
      
    //TODO: Add axis labels
  },
  
  _getXAxis: function () {
    min = this.data[0].x;
    max = this.data[this.data.length - 1].x;
    
    xAxis = d3.svg.axis()
      .scale(this.xScale.domain([min, max]))
      .tickSubdivide(true)
      .orient("bottom");      
    
    return xAxis;
  },
  
  _getYAxis: function () {
    var max = d3.max(this.data, function(d) { return d.y; });
    
    yAxis =  d3.svg.axis()
      .scale(this.yScale.domain([0, max]).nice())
      .ticks(4)
      .orient("left");      
      
    return yAxis;
  },
  
  _addCircles: function () {
    var xScale = this.xScale;
    var yScale = this.yScale;
    this.svg.selectAll(".line")
      .data(this.data).enter()
      .append("svg:circle")
        .attr("class", "line")
        .attr("cx", function(d) { return xScale(d.x) })
        .attr("cy", function(d) { return yScale(d.y) })
        .attr("ext:qtip", function(d) {
          return '<table><tr><td>Report Date:&nbsp;&nbsp;</td><td>'+d.x.format('M d, Y')+'&nbsp;&nbsp;</td></tr>'+
                 '<tr><td>Total Absent:&nbsp;&nbsp;</td><td>'+d.y+'&nbsp;&nbsp;</td></tr>'+
                 '<tr><td>Total Enrolled:&nbsp;&nbsp;</td><td>'+d.e+'&nbsp;&nbsp;</td></tr></table>'
        })
        .attr("r", 3.5);
  },
  
  _formatLines: function () {
    for(func in this.lines){
      try {
        if(this.lines[func][1] == 'e'){
          var d_d      = 'd.e';
          var qtip_txt = 'Enrollment';
          var line_class = 'line2';
        }
        else if(lines[func][1] == 'a'){
          var d_d        = 'd.a';
          var qtip_txt   = 'Average';
          var line_class = 'line-avg';
        }
        else if(lines[func][1] == 'd'){
          var d_d      = 'd.d';
          var qtip_txt = 'Deviation';
          var line_class = 'line-deviation';
        }
        else if(lines[func][1] == 'a3'){
          var d_d      = 'd.a3';
          var qtip_txt = 'Average';
          var line_class = 'line-avg-30';
        }
        else if(lines[func][1] == 'a6'){
          var d_d      = 'd.a6';
          var qtip_txt = 'Average';
          var line_class = 'line-avg-60';
        }
        else if(lines[func][1] == 'c'){
          var d_d      = 'd.c';
          var qtip_txt = 'Cusum';
          var line_class = 'line-cusum';
        }
        this.svg.append("svg:path")
          .attr('class', line_class)
          .attr("clip-path","url(#clip)")
          .attr("d", lines[c][0](this.data));
        this.svg.selectAll(line_class)
          .data(this.data).enter()
          .append("svg:circle")
            .attr("class", line_class)
            .attr("cx", function(d) { return this.xScale(d.x) })
            .attr("cy", function(d) {
              if(d_d == 'd.e') return this.yScale(d.e);
              if(d_d == 'd.a') return this.yScale(d.a);
              if(d_d == 'd.d') return this.yScale(d.d);
              if(d_d == 'd.a3') return this.yScale(d.a3);
              if(d_d == 'd.a6') return this.yScale(d.a6);
              if(d_d == 'd.c') return this.yScale(d.c);
            })
            .attr("ext:qtip", function(d){
              if(d_d == 'd.e') d_d = d.e;
              if(d_d == 'd.a') d_d = d.a;
              if(d_d == 'd.d') d_d = d.d;
              if(d_d == 'd.a3') d_d = d.a3;
              if(d_d == 'd.a6') d_d = d.a6;
              if(d_d == 'd.c') d_d = d.c;
              return '<table><tr><td>Report Date:&nbsp;&nbsp;</td><td>'+d.x.format('M d, Y')+'&nbsp;&nbsp;</td></tr>'+
                     '<tr><td>'+qtip_txt+':&nbsp;&nbsp;</td><td>'+d_d+'&nbsp;&nbsp;</td></tr></table>';
            })
            .attr("r", 3.5);
      }
      catch(e){};
    }
  }
});
