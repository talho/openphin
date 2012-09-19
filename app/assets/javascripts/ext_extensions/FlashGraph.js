
Talho.ux.FlashGraph = Ext.extend(Ext.Panel, {
  height: 175,
  layout: 'fit',
  
  initComponent: function () {
    
    // var store = new Ext.data.JsonStore({
        // fields:['name', 'visits', 'views'],
        // data: [
            // {name:'Jul 07', visits: 245000, views: 3000000},
            // {name:'Aug 07', visits: 240000, views: 3500000},
            // {name:'Sep 07', visits: 355000, views: 4000000},
            // {name:'Oct 07', visits: 375000, views: 4200000},
            // {name:'Nov 07', visits: 490000, views: 4500000},
            // {name:'Dec 07', visits: 495000, views: 5800000},
            // {name:'Jan 08', visits: 520000, views: 6000000},
            // {name:'Feb 08', visits: 620000, views: 7500000}
        // ]
    // });
// 
// 
     // this.items = {
            // xtype: 'linechart',
            // store: store,
            // xField: 'name',
            // yField: 'visits',
//             
    // };

    
    
    this.items = [      
      {xtype: 'columnchart', store: this.store, xField: 'report_date',
        url: 'ext3-3-charts.swf',
        chartStyle: {
          padding: 10, animationEnabled: true,
          font: {name: 'Tahoma', color: 0x444444, size: 11 },
          dataTip: {
            padding: 5, 
            border: {color: 0x99bbe8, size:1},
            background: {color: 0xDAE7F6, alpha: .9},
            font: {name: 'Tahoma', color: 0x15428B, size: 10, bold: true}
          },
          xAxis: {
            color: 0x69aBc8,
            majorTicks: {color: 0x69aBc8, length: 4},
            minorTicks: {color: 0x69aBc8, length: 2},
            majorGridLines: {size: 1, color: 0xeeeeee}
          },
          yAxis: {
            color: 0x69aBc8,
            majorTicks: {color: 0x69aBc8, length: 4},
            minorTicks: {color: 0x69aBc8, length: 2},
            majorGridLines: {size: 1, color: 0xdfe8f6}
          }
        },
        yAxis: new Ext.chart.NumericAxis({
          displayName: 'Absent',
          labelRenderer : Ext.util.Format.numberRenderer('0,0')
        }),
        tipRenderer : function(chart, record, index, series){
          var tip_string = Ext.util.Format.number(record.data.total, '0,0') + ' students absent on ' + record.data.report_date;
          tip_string    += '\n\r'+Ext.util.Format.number(record.data.enrolled, '0,0') + ' students enrolled on ' + record.data.report_date;
          return tip_string;
        },
        series: this.series
      }
    ];
    
    Talho.ux.FlashGraph.superclass.initComponent.apply(this, arguments);
  }  
});
