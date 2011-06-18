class CheckpointsController < ApplicationController
  def show
    @checkpoint = Checkpoint.find(:first, :conditions => {:checkpoint_id => params[:checkpoint_id]})
    @summarized_cp = SummarizedCheckpointInfo.new(@checkpoint)
    end_time = @summarized_cp.last_checkin_time
    start_time = @summarized_cp.first_checkin_time
    minute_interval=1
    num_intervals = ((end_time - start_time)/(minute_interval * 60.0)).ceil    
    end_times = (1..num_intervals).map {|interval_index| start_time + minute_interval*interval_index*60}

    @checkpoint_plot = ActivityController.line_plot(end_times, @summarized_cp.checkin_hist(start_time,end_time,minute_interval))
  end
end
