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

ActiveRecord::Schema.define(version: 20140511081130) do

  create_table "containers", force: true do |t|
    t.integer  "image_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "instance_id"
    t.text     "port_bindings", limit: 255
    t.string   "name"
    t.integer  "host_id"
    t.integer  "region_id"
    t.integer  "user_id"
    t.text     "env_settings"
  end

  add_index "containers", ["host_id"], name: "index_containers_on_host_id"
  add_index "containers", ["image_id"], name: "index_containers_on_image_id"
  add_index "containers", ["region_id"], name: "index_containers_on_region_id"
  add_index "containers", ["user_id"], name: "index_containers_on_user_id"

  create_table "hosts", force: true do |t|
    t.string   "name"
    t.string   "ip_address"
    t.integer  "port"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "region_id"
    t.boolean  "healthy",    default: false, null: false
  end

  add_index "hosts", ["region_id"], name: "index_hosts_on_region_id"

  create_table "images", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "docker_index"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "port_bindings",  limit: 255
    t.text     "volumes",        limit: 255
    t.boolean  "shared_volumes"
    t.text     "env_defaults"
  end

  create_table "regions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "available_hosts_count", default: 0, null: false
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "container_limit",        default: 2
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
