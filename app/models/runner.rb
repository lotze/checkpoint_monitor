class Runner < ActiveRecord::Base
  has_one :caught_by, :through => :tags, :foreign_key => :runner_id, :key => :tagger_id
  has_many :checkins, :foreign_key => :runner_id
  has_many :tags, :foreign_key => :tagger_id, :key => :runner_id
  
  
end
