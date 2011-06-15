class SampleDataGenerator
  def self.runner_ids
    ['RUBIN','TOMAS','RABIT','DARBY','SEANM','SAMPL','IANKB','ARTMS','MYRNA','DAXTC']
  end
  
  def self.checkpoint_names
    ['Checkpoint 0 Start','Checkpoint 1 Awesome','Checkpoint 2 Kazam','Checkpoint 3 More','Checkpoint 4 Finish']
  end
  
  def self.generate_early_data
    runner_ids.each do |runner_id|
      Runner.create!(:runner_id => runner_id)
    end
    checkpoint_names.each_with_index do |checkpoint_name, index|
      Checkpoint.create!(:checkpoint_name => checkpoint_name, :checkpoint_id => index + 100)
    end
    runners = runner_ids.map {|rid| Runner.find(:first, :conditions => {:runner_id => rid})}
    checkpoints = checkpoint_names.map {|c| Checkpoint.find(:first, :conditions => {:checkpoint_name => c})}
    
    first_half_checkpoints = checkpoints[1..(((checkpoints.size-1)/2).round)]
    
    start_time = Time.new() - 86400
    
    runners.each do |runner|
      runner_time = start_time - rand(3600)
      Checkin.create!(:runner => runner, :checkpoint => checkpoints[0], :checkin_time => runner_time)
      runner_time = start_time
      first_half_checkpoints.each do |checkpoint|
        Checkin.create!(:runner => runner, :checkpoint => checkpoint, :checkin_time => runner_time)
        runner_time = runner_time + rand(1800)
      end
    end
  end
  
  def self.next_checkpoint(checkpoint)
    cp_index = checkpoint_names.index(checkpoint.checkpoint_name)
    if (cp_index < (checkpoint_name.size -1))
      return(Checkpoint.find(:first, :conditions => {:checkpoint_name => checkpoint_names[cp_index+1]}))
    else
      return(nil)
    end
  end
  
  def self.generate_finishing_data
    runners = runner_ids.map {|rid| Runner.find(:first, :conditions => {:runner_id => rid})}
    checkpoints = checkpoint_names.map {|c| Checkpoint.find(:first, :conditions => {:checkpoint_name => c})})}
    second_half_checkpoints = checkpoints[((((checkpoints.size-1)/2).round)+1)..(checkpoints.size-1)]
    
    runners.each do |runner|
      runner_time = runner.current_checkin.checkin_time
      second_half_checkpoints do |checkpoint|
        Checkin.create!(:runner => runner, :checkpoint => checkpoint, :checkin_time => runner_time)
        runner_time = runner_time + rand(1800)
      end
    end    
  end
  
  def self.delete_generated_data
    runners = runner_ids.map {|rid| Runner.find(:first, :conditions => {:runner_id => rid})}
    checkpoints = checkpoint_names.map {|cname| Checkpoint.find(:first, :conditions => {:checkpoint_name => cname})})}
      
    runners.map {|runner| runner.checkins.destroy_all}
    runners.map {|runner| runner.tagged.destroy_all}
    runners.map {|runner| runner.tags.destroy_all}
    runners.destroy_all
    checkpoints.destroy_all
  end
end