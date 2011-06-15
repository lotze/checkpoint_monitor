class Runner < ActiveRecord::Base
  #has_many :chasers, :class_name => :Runner, :through => :tags, :foreign_key => :runner_id, :primary_key => :tagger_id
  has_many :checkins, :foreign_key => :runner_id, :primary_key => :runner_id
  has_many :tags, :foreign_key => :tagger_id, :primary_key => :runner_id  
  has_many :tagged, :class_name => Tag, :foreign_key => :runner_id, :primary_key => :runner_id  

  def caught_by
    t = Tag.find(:first, :conditions => {:runner_id => id})
    if t.present?
      t.chaser
    else
      nil
    end
  end
  
  def current_checkin
    checkins.sort {|a, b| a.checkin_time <=> b.checkin_time}.last
  end
end
