class Summarizer
  def summarize
    ActiveRecord::Base.connection.execute("drop table if exists checkins_so_far;")
    ActiveRecord::Base.connection.execute("create table checkins_so_far as 
      select
        ci.checkin_id,
        ci.checkin_time,
        earlier_checkins.checkpoint_id,
        cp.checkpoint_position,
        count(*) as num_so_far
      from
        checkins as ci,
        checkins as earlier_checkins,
        checkpoints as cp
      where
        earlier_checkins.checkin_time <= ci.checkin_time
        and earlier_checkins.checkpoint_id = cp.checkpoint_id
      group by
        ci.checkin_time, cp.checkpoint_id
      ;")
    ActiveRecord::Base.connection.execute("alter table checkins_so_far add index(checkin_time, checkpoint_id);")
    ActiveRecord::Base.connection.execute("alter table checkins_so_far add index(checkin_time, checkpoint_position);")
    ActiveRecord::Base.connection.execute("alter table checkins_so_far add index(checkpoint_id);")
      
    ActiveRecord::Base.connection.execute("drop table if exists summarized_tags;")
    ActiveRecord::Base.connection.execute("create table summarized_tags as 
      select
        tags.tagger_id,
        count(*) as num_tags
      from
        tags
      group by
        tags.tagger_id
      ;")
    ActiveRecord::Base.connection.execute("alter table summarized_tags add index(num_tags);")
    ActiveRecord::Base.connection.execute("alter table summarized_tags add index(tagger_id);")
    
    ActiveRecord::Base.connection.execute("drop table if exists summarized_runners;")
    ActiveRecord::Base.connection.execute("create table summarized_runners as 
      select
        0 as place,
        checkins.runner_id,
        max(checkpoints.checkpoint_position) as final_position,
        max(checkins.checkin_time) as final_checkin
      from
        checkins,
        checkpoints
      where
        checkpoints.checkpoint_id = checkins.checkpoint_id
      group by
        checkins.runner_id
      order by
        final_position desc, final_checkin
      ;")
    ActiveRecord::Base.connection.execute("alter table summarized_runners add index(runner_id);")
    ActiveRecord::Base.connection.execute("update summarized_runners, (SELECT @row := 0) as r set summarized_runners.place = (@row := @row + 1);")
  end
end