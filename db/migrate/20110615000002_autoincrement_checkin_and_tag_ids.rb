class AddIndices < ActiveRecord::Migration
  def self.up
    change_column :checkins, :checkin_id, :primary_key
    change_column :tags, :tag_id, :primary_key
  end

  def self.down
  end
end
