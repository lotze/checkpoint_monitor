class ActivityController < ApplicationController
  def recent
    @recent_twenty_checkins = Checkin.find(:all, :order => 'checkin_time desc', :limit => 20)
    @recent_twenty_tags = Tag.find(:all, :order => 'tag_time desc', :limit => 20)    
  end
  
  def status
    @all_checkpoints = Checkpoint.find(:all).sort {|a, b| a.checkpoint_name <=> b.checkpoint_name}
    
    @summarized_checkpoints = @all_checkpoints.map {|c| SummarizedCheckpointInfo.new(c)}
      
    @total_players = @summarized_checkpoints.map {|sc| sc.num_checked_in}.max
      
    # TODO: get the highest checkpoint reached by each player; do a stream graph of the highest checkpoint each person has reached, by time
    # also report on how many players are known to have become chasers, and what the highest number of reported catches is so far
      
    # in the view, show the by-minute-interval plot of activity at each checkpoint
    start_time = @summarized_checkpoints.map {|sc| sc.first_checkin_time}.compact.min
    end_time = @summarized_checkpoints.map {|sc| sc.last_checkin_time}.compact.max
    minute_interval=5
    num_intervals = ((end_time - start_time)/(minute_interval * 60)).ceil    
    end_times = (1..num_intervals).map {|interval_index| start_time + minute_interval*interval_index*60}
    
    merged_map = @summarized_checkpoints.inject({}) {|total, sm| total.merge(sm.checkpoint.checkpoint_name => sm.checkin_hist(start_time,end_time,minute_interval))}
    @status_plot = ActivityController.status_plot(end_times, merged_map)
  end 
  
  def self.status_plot(times, data_hash)
    series_names = data_hash.keys.sort

    stream_data = Hash.new
    stream_data["label"] = series_names
    stream_data["values"] = series_names.enum_with_index.collect {|name, index| Hash.new(:label => name, :values => data_hash.values.map {|data_vector| data_vector[index]})}

    return <<JS
  <div id="infovis" class="infovis"> </div>
    <link type="text/css" href="/cpm/stylesheets/jit/base.css" rel="stylesheet" />
    <link type="text/css" href="/cpm/stylesheets/jit/AreaChart.css" rel="stylesheet" />
        <!--[if IE]><script language="javascript" type="text/javascript" src="/cpm/javascripts/vendor/jit/excanvas.js"></script><![endif]-->
    
    <!-- JIT Library File -->
    <script language="javascript" type="text/javascript" src="/cpm/javascripts/vendor/jit/jit-yc.js"></script>
  
  <script id="sp_source" language="javascript" type="text/javascript">
var labelType, useGradients, nativeTextSupport, animate;

(function() {
  var ua = navigator.userAgent,
      iStuff = ua.match(/iPhone/i) || ua.match(/iPad/i),
      typeOfCanvas = typeof HTMLCanvasElement,
      nativeCanvasSupport = (typeOfCanvas == 'object' || typeOfCanvas == 'function'),
      textSupport = nativeCanvasSupport
        && (typeof document.createElement('canvas').getContext('2d').fillText == 'function');
  //I'm setting this based on the fact that ExCanvas provides text support for IE
  //and that as of today iPhone/iPad current text support is lame
  labelType = (!nativeCanvasSupport || (textSupport && !iStuff))? 'Native' : 'HTML';
  nativeTextSupport = labelType == 'Native';
  useGradients = nativeCanvasSupport;
  animate = !(iStuff || !nativeCanvasSupport);
})();

var Log = {
  elem: false,
  write: function(text){
    if (!this.elem)
      this.elem = document.getElementById('log');
    this.elem.innerHTML = text;
    this.elem.style.left = (500 - this.elem.offsetWidth / 2) + 'px';
  }
};


function init(){
    //init data
    var json = #{stream_data.to_json};
    var infovis = document.getElementById('infovis');
    //init AreaChart
    var areaChart = new $jit.AreaChart({
      //id of the visualization container
      injectInto: 'infovis',
      //add animations
      animate: true,
      //separation offsets
      Margin: {
        top: 5,
        left: 5,
        right: 5,
        bottom: 5
      },
      labelOffset: 10,
      //whether to display sums
      showAggregates: true,
      //whether to display labels at all
      showLabels: true,
      //could also be 'stacked'
      type: useGradients? 'stacked:gradient' : 'stacked',
      //label styling
      Label: {
        type: labelType, //can be 'Native' or 'HTML'
        size: 13,
        family: 'Arial',
        color: 'white'
      },
      //enable tips
      Tips: {
        enable: true,
        onShow: function(tip, elem) {
          tip.innerHTML = "<b>" + elem.name + "</b>: " + elem.value;
        }
      },
    });
    //load JSON data.
    areaChart.loadJSON(json);
    //end
    var list = $jit.id('id-list'),
        button = $jit.id('update'),
        restoreButton = $jit.id('restore');
    //dynamically add legend to list
    var legend = areaChart.getLegend(),
        listItems = [];
    for(var name in legend) {
      listItems.push('<div class=\'query-color\' style=\'background-color:'
          + legend[name] +'\'>&nbsp;</div>' + name);
    }
    list.innerHTML = '<li>' + listItems.join('</li><li>') + '</li>';
}
  </script>
JS
  end
end
