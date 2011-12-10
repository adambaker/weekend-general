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

ActiveRecord::Schema.define(:version => 20111209085641) do

  create_table "dishonorable_discharges", :force => true do |t|
    t.string   "email"
    t.string   "provider"
    t.string   "uid"
    t.integer  "officer"
    t.text     "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dishonorable_discharges", ["email"], :name => "index_dishonorable_discharges_on_email"
  add_index "dishonorable_discharges", ["provider", "uid"], :name => "index_dishonorable_discharges_on_provider_and_uid"

  create_table "events", :force => true do |t|
    t.string   "name"
    t.date     "date"
    t.string   "time"
    t.integer  "price"
    t.integer  "venue_id"
    t.string   "address"
    t.string   "city"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
  end

  add_index "events", ["created_at"], :name => "index_events_on_created_at"
  add_index "events", ["date", "price"], :name => "index_events_on_date_and_price"
  add_index "events", ["date"], :name => "index_events_on_date"
  add_index "events", ["updated_at"], :name => "index_events_on_updated_at"
  add_index "events", ["venue_id"], :name => "index_events_on_venue_id"

  create_table "links", :force => true do |t|
    t.string  "url"
    t.string  "text"
    t.integer "event_id"
  end

  create_table "rsvps", :force => true do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rsvps", ["event_id"], :name => "index_rsvps_on_event_id"
  add_index "rsvps", ["user_id", "kind"], :name => "index_rsvps_on_user_id_and_kind"
  add_index "rsvps", ["user_id"], :name => "index_rsvps_on_user_id"

  create_table "trails", :force => true do |t|
    t.integer  "tracker_id"
    t.integer  "target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trails", ["target_id"], :name => "index_trails_on_target_id"
  add_index "trails", ["tracker_id"], :name => "index_trails_on_tracker_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "rank",            :default => 1
    t.string   "theme"
    t.boolean  "attend_reminder", :default => true
    t.boolean  "maybe_reminder",  :default => false
    t.boolean  "host_reminder",   :default => false
    t.boolean  "track_host",      :default => true
    t.boolean  "track_attend",    :default => true
    t.boolean  "track_maybe",     :default => false
    t.boolean  "host_rsvp",       :default => true
    t.boolean  "attend_rsvp",     :default => false
    t.boolean  "maybe_rsvp",      :default => false
    t.boolean  "new_event",       :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["provider", "uid"], :name => "index_users_on_provider_and_uid"

  create_table "venues", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "city"
    t.string   "url"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
  end

  add_index "venues", ["name"], :name => "index_venues_on_name"

end
