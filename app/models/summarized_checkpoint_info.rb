class SummarizedCheckpointInfo < ActiveRecord::Base
  attr_reader :checkpoint, :checkin_list, :first_checkin_time, :last_checkin_time, :num_checked_in 
  
  def init(checkpoint, checkin_list=checkpoint.checkins)
    @checkpoint = checkpoint
    @checkin_list = checkin_list.sort {|a, b| a.checkin_time <=> b.checkin_time}
    
    # precompute some statistics
    @first_checkin_time = @checkin_list.first.checkin_time
    @last_checkin_time = @checkin_list.last.checkin_time
    @num_checked_in = @checkin_list.length
  end
  
  # get a list of, per x minutes, the number of checkins over that five minute period
  def checkin_hist(minute_list, start_time=@first_checkin_time.to_i, end_time=@last_checkin_time.to_i, minute_interval = 5)
    num_intervals = ((end_time - start_time)/(minute_interval * 60)).ceil
    
    end_times = (1..num_intervals).map {|interval_index| start_time + minute_interval*interval_index*60}
      
    interval_counts = (1..num_intervals).map {|interval_index| 0}

    interval_index = 0
    interval_start = start_time    
    interval_end = start_time + minute_interval*60    
    @checkin_list.each do |checkin|
      while (checkin.checkin_time > interval_end) do
        interval_start = interval_end
        interval_end = interval_end + minute_interval*60
        interval_index += 1
      end
      if (interval_index < interval_counts.length)
        interval_counts[interval_index] += 1
      end
    end
      
    return(interval_counts)    
  end
end