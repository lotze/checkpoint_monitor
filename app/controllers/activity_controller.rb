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
      
    @start_time = @summarized_checkpoints.map {|sc| sc.first_checkin_time}.min
    @end_time = @summarized_checkpoints.map {|sc| sc.last_checkin_time}.max
      
      
    # TODO: in the view, show the by-minute-interval plot of activity at each checkpoint
  end 
end
