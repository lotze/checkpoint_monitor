class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags, :id => false do |t|
      t.integer :tag_id
      t.string :runner_id
      t.string :tagger_id
      t.timestamp :tag_time
      t.double :loc_lat
      t.double :loc_long
      t.string :loc_addr
      t.string :device_id
      t.string :user_agent
      t.string :ip_address
    end
  end

  def self.down
    drop_table :tags
  end
end
