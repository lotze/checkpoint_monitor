class RunnersController < ApplicationController
  def show
    @runner = Runner.find(:first, :conditions => {:runner_id => params[:runner_id]})
      
    @is_chaser = @runner.caught_by.present?
    @num_caught = @runner.tags.size
    
    @num_runners = Runner.find(:all).size
    
    @num_with_more_catches = nil
    @num_chasers = nil
    if (@is_chaser)
      @num_with_more_catches = ActiveRecord::Base.connection.execute("SELECT COUNT(*) FROM (SELECT tagger_id, COUNT(*) as num_tags from tags group by tagger_id having num_tags > ?) AS tags_by_player;", @num_caught).first[0]
      @num_chasers = ActiveRecord::Base.connection.execute("SELECT COUNT(DISTINCT tagger_id) from tags;").first[0]
    end
    
    current_checkin = @runner.current_checkin
    
    @your_place_by_checkin = ActiveRecord::Base.connection.execute("select
      runner_checkins.checkin_id,
      sum(other_runner_checkins.runner_id is not null) as num_reaching_before
    from
      checkins as runner_checkins
    join
      checkpoints as runner_checkpoints
    on
      runner_checkins.checkpoint_id = runner_checkpoints.checkpoint_id
    join
      checkpoints as equivalent_checkpoints
    on
      equivalent_checkpoints.checkpoint_position = runner_checkpoints.checkpoint_position
    left outer join
      checkins as other_runner_checkins
    on
      other_runner_checkins.checkpoint_id = equivalent_checkpoints.checkpoint_id
      and other_runner_checkins.checkin_time < runner_checkins.checkin_time
    where
      runner_checkins.runner_id = '#{@runner.runner_id}'
    group by
      runner_checkins.checkpoint_id
    order by
      runner_checkins.checkin_time DESC
      ").map do |row|
        [Checkin.find(:first, :conditions => {:checkin_id => row[0]}), row[1].to_i]
      end
      
    @num_ahead_right_now = @your_place_by_checkin.first[1]
  end
  
  def index
    #@ordered_runners = Runner.find(:all).sort {|a, b| (b.current_checkin.checkpoint_id <=> a.current_checkin.checkpoint_id) || (a.current_checkin.checkin_time.to_i <=> b.current_checkin.checkin_time.to_i)}[0..29]
    #@ordered_runners = Runner.find(:all).sort {|a, b| (b.current_position <=> a.current_position) || (a.current_time.to_i <=> b.current_time.to_i)}[0..29]
    #@ordered_runners = Runner.find(:all).sort {|a, b| (a.current_checkin.checkin_time.to_i <=> b.current_checkin.checkin_time.to_i)}[0..29]
    @ordered_runners = Runner.find(:all).sort_by {|runner| [-runner.current_position, runner.current_time.to_i]}[0..29]
    @ordered_chasers = Runner.find(:all).sort {|a, b| b.tags.size <=> a.tags.size}[0..10]
  end
  
  def register
  end
end
