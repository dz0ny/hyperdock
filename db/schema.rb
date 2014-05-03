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

ActiveRecord::Schema.define(version: 20140503172118) do

  create_table "containers", force: true do |t|
    t.integer  "image_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "instance_id"
    t.string   "port_bindings"
    t.string   "name"
  end

  add_index "containers", ["image_id"], name: "index_containers_on_image_id"

  create_table "images", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "docker_index"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "port_bindings"
  end

end
