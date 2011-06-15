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
    
    @num_reached_this_checkpoint_ahead_of_you_or_further_checkpoints = Checkin.find(:all, :conditions => ["(checkpoint_id = ? AND checkin_time > ?) OR checkpoint_id > ?",current_checkin.checkpoint.id, current_checkin.checkin_time, current_checkin.checkpoint.id]).size    
  end
  
  def register
  end
end