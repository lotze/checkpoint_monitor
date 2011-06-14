class Tag < ActiveRecord::Base
  acts_as_mappable  :lat_column_name => :loc_lat, :lng_column_name => :loc_long

  belongs_to :runner, :foreign_key => :runner_id, :key => :runner_id
  belongs_to :chaser, :foreign_key => :tagger_id, :key => :runner_id
  
end
