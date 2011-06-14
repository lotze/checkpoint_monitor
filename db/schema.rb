# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110602000000) do

  create_table "checkins", :id => false, :force => true do |t|
    t.integer  "checkin_id"
    t.string   "runner_id"
    t.integer  "checkpoint_id"
    t.datetime "checkin_time"
    t.string   "device_id"
    t.string   "user_agent"
    t.float    "lng"
    t.float    "lat"
  end

  create_table "checkpoints", :id => false, :force => true do |t|
    t.integer "checkpoint_id"
    t.string  "checkpoint_name"
    t.float   "checkpoint_loc_lat"
    t.float   "checkpoint_loc_long"
  end

  create_table "runners", :id => false, :force => true do |t|
    t.string   "runner_id"
    t.string   "player_email"
    t.string   "player_name"
    t.boolean  "is_mugshot"
    t.datetime "time_of_mugshot"
    t.boolean  "is_registered"
    t.datetime "time_of_registration"
    t.boolean  "is_tagged"
  end

  create_table "tags", :id => false, :force => true do |t|
    t.integer  "tag_id"
    t.string   "runner_id"
    t.string   "tagger_id"
    t.datetime "tag_time"
    t.float    "loc_lat"
    t.float    "loc_long"
    t.string   "loc_addr"
    t.string   "device_id"
    t.string   "user_agent"
    t.string   "ip_address"
  end

end
