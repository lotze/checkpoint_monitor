require 'rubygems'
require 'geokit'

class Checkin < ActiveRecord::Base
  acts_as_mappable
  belongs_to :runner, :primary_key => :runner_id
  belongs_to :checkpoint, :primary_key => :checkpoint_id
end
