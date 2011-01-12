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

ActiveRecord::Schema.define(:version => 20110111223641) do

  create_table "event_attendees", :force => true do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_attendees", ["event_id"], :name => "index_event_attendees_on_event_id"
  add_index "event_attendees", ["user_id"], :name => "index_event_attendees_on_user_id"

  create_table "event_hosts", :force => true do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_hosts", ["event_id"], :name => "index_event_hosts_on_event_id"
  add_index "event_hosts", ["user_id"], :name => "index_event_hosts_on_user_id"

  create_table "event_maybes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_maybes", ["event_id"], :name => "index_event_maybes_on_event_id"
  add_index "event_maybes", ["user_id"], :name => "index_event_maybes_on_user_id"

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
  end

  create_table "links", :force => true do |t|
    t.string  "url"
    t.string  "text"
    t.integer "event_id"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",      :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["provider"], :name => "index_users_on_provider"
  add_index "users", ["uid"], :name => "index_users_on_uid"

  create_table "venues", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "city"
    t.string   "url"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
