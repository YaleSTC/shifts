# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090610201645) do

  create_table "categories", :force => true do |t|
    t.boolean  "active",        :default => true
    t.string   "name"
    t.integer  "department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "departments", :force => true do |t|
    t.string   "name"
    t.integer  "permission_id"
    t.integer  "payform_permission_id"
    t.boolean  "monthly",               :default => false
    t.boolean  "complex",               :default => false
    t.boolean  "end_of_month",          :default => false
    t.integer  "day",                   :default => 6
    t.integer  "day2",                  :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "departments_roles", :id => false, :force => true do |t|
    t.integer "department_id"
    t.integer "role_id"
  end

  create_table "departments_users", :id => false, :force => true do |t|
    t.integer  "department_id"
    t.integer  "user_id"
    t.boolean  "active",        :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "loc_groups", :force => true do |t|
    t.string   "name"
    t.integer  "department_id"
    t.integer  "view_perm_id"
    t.integer  "signup_perm_id"
    t.integer  "admin_perm_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.string   "short_name"
    t.text     "useful_links"
    t.integer  "max_staff"
    t.integer  "min_staff"
    t.integer  "priority"
    t.boolean  "active"
    t.integer  "loc_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payform_item_sets", :force => true do |t|
    t.integer "category_id"
    t.date    "date"
    t.decimal "hours"
    t.text    "description"
  end

  create_table "payform_items", :force => true do |t|
    t.integer  "category_id"
    t.integer  "user_id"
    t.integer  "payform_item_id"
    t.integer  "payform_id"
    t.integer  "payform_item_set_id"
    t.boolean  "active",              :default => true
    t.decimal  "hours"
    t.date     "date"
    t.text     "description"
    t.text     "reason"
    t.string   "source"
    t.datetime "submitted"
    t.datetime "approved"
    t.datetime "printed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payform_sets", :force => true do |t|
    t.integer  "department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payforms", :force => true do |t|
    t.date     "date"
    t.boolean  "monthly",        :default => false
    t.boolean  "end_of_month",   :default => false
    t.integer  "day",            :default => 6
    t.datetime "submitted"
    t.datetime "approved"
    t.datetime "printed"
    t.integer  "approved_by_id"
    t.integer  "department_id"
    t.integer  "user_id"
    t.integer  "payform_set_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions_roles", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "permission_id"
  end

  create_table "report_items", :force => true do |t|
    t.integer  "report_id"
    t.datetime "time"
    t.text     "content"
    t.string   "ip_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reports", :force => true do |t|
    t.integer  "shift_id"
    t.datetime "arrived"
    t.datetime "departed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "shifts", :force => true do |t|
    t.datetime "start"
    t.datetime "end"
    t.integer  "user_id"
    t.integer  "location_id"
    t.boolean  "scheduled",   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sub_requests", :force => true do |t|
    t.datetime "start"
    t.datetime "end"
    t.datetime "mandatory_start"
    t.datetime "mandatory_end"
    t.string   "reason"
    t.integer  "shift_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "substitute_sources", :id => false, :force => true do |t|
    t.integer  "sub_request_id"
    t.integer  "user_source_id"
    t.string   "user_source_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "time_slots", :force => true do |t|
    t.integer  "location_id"
    t.datetime "start"
    t.datetime "end"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "nick_name"
    t.string   "employee_id"
    t.string   "email"
    t.integer  "default_department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
