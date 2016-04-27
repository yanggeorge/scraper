# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160427083521) do

  create_table "items", force: :cascade do |t|
    t.text "spider_name",  limit: 65535
    t.text "item_name",    limit: 65535
    t.text "item_xpath",   limit: 65535
    t.text "item_reg",     limit: 65535
    t.text "item_type",    limit: 65535
    t.text "item_example", limit: 65535
    t.text "start_url",    limit: 65535
  end

  create_table "robot_data_bases", force: :cascade do |t|
    t.text    "robot_id",   limit: 65535
    t.text    "robot_name", limit: 65535
    t.boolean "delete"
    t.text    "robot_def",  limit: 65535
  end

  create_table "start_urls", force: :cascade do |t|
    t.text     "url_name",     limit: 65535
    t.text     "url_value",    limit: 65535
    t.text     "url_response", limit: 65535
    t.text     "spider_name",  limit: 65535
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

end
