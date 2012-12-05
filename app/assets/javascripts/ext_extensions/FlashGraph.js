
Talho.ux.FlashGraph = Ext.extend(Ext.Container, {
  height: 175,
  layout: 'fit',
  
  initComponent: function () {
    
    this.store.each(function (record) { 
      var test = record;
    });
    
    this.items = [      
      {xtype: 'linechart', store: this.store, xField: 'report_date',
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
          labelRenderer: Ext.util.Format.numberRenderer('0,0')
        }),
        xAxis: new Ext.chart.TimeAxis({
          displayName: 'Date',
          labelRenderer: Ext.util.Format.dateRenderer('M-d')
        }),
        tipRenderer: function(chart, record, index, series){
          var tip_string = Ext.util.Format.number(record.data.total, '0,0') + ' students absent on ' + record.data.report_date.format('M-d-Y');
          tip_string    += '\n\r'+Ext.util.Format.number(record.data.enrolled, '0,0') + ' students enrolled on ' + record.data.report_date.format('M-d-Y');
          return tip_string;
        },
        series: this.series
      }
    ];
    
    Talho.ux.FlashGraph.superclass.initComponent.call(this);
  }  
});
