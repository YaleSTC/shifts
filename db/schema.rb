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

ActiveRecord::Schema.define(:version => 20121205044916) do

  create_table "app_configs", :force => true do |t|
    t.string   "footer"
    t.string   "auth_types"
    t.string   "ldap_host_address"
    t.integer  "ldap_port"
    t.string   "ldap_base"
    t.string   "ldap_login"
    t.string   "ldap_first_name"
    t.string   "ldap_last_name"
    t.string   "ldap_email"
    t.boolean  "use_ldap"
    t.string   "mailer_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "calendar_feed_hash"
    t.string   "admin_email"
  end

  create_table "calendars", :force => true do |t|
    t.string   "name"
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean  "active"
    t.integer  "department_id"
    t.boolean  "default",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public"
  end

  create_table "categories", :force => true do |t|
    t.boolean  "active",        :default => true
    t.boolean  "built_in",      :default => false
    t.string   "name"
    t.integer  "department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_entries", :force => true do |t|
    t.integer  "data_object_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_fields", :force => true do |t|
    t.integer  "data_type_id"
    t.string   "name"
    t.string   "display_type"
    t.string   "values"
    t.float    "upper_bound"
    t.float    "lower_bound"
    t.string   "exact_alert"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",       :default => true
  end

  create_table "data_objects", :force => true do |t|
    t.integer  "data_type_id"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_objects_locations", :id => false, :force => true do |t|
    t.integer "data_object_id"
    t.integer "location_id"
  end

  create_table "data_types", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "department_configs", :force => true do |t|
    t.integer  "department_id"
    t.integer  "schedule_start"
    t.integer  "schedule_end"
    t.integer  "time_increment"
    t.integer  "grace_period"
    t.boolean  "auto_remind",          :default => true
    t.boolean  "auto_warn",            :default => true
    t.string   "mailer_address"
    t.boolean  "monthly",              :default => false
    t.boolean  "end_of_month",         :default => false
    t.integer  "day",                  :default => 6
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "weekend_shifts"
    t.boolean  "unscheduled_shifts"
    t.text     "printed_message"
    t.text     "reminder_message"
    t.text     "warning_message"
    t.integer  "warning_weeks"
    t.integer  "description_min"
    t.integer  "reason_min"
    t.boolean  "can_take_passed_sub",  :default => true
    t.string   "stats_mailer_address"
    t.boolean  "stale_shift",          :default => true
    t.integer  "payform_time_limit"
    t.integer  "admin_round_option",   :default => 15
    t.integer  "early_signin",         :default => 60
    t.integer  "task_leniency",        :default => 60
    t.string   "search_engine_name",   :default => "Google"
    t.string   "search_engine_url",    :default => "http://www.google.com/search?q="
  end

  create_table "departments", :force => true do |t|
    t.string   "name"
    t.integer  "admin_permission_id"
    t.integer  "payforms_permission_id"
    t.integer  "shifts_permission_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "departments_users", :id => false, :force => true do |t|
    t.integer  "department_id"
    t.integer  "user_id"
    t.boolean  "active",                                       :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "payrate",       :precision => 10, :scale => 2
  end

  create_table "emails", :force => true do |t|
    t.string   "from"
    t.string   "to"
    t.integer  "last_send_attempt", :default => 0
    t.text     "mail"
    t.datetime "created_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "loc_groups", :force => true do |t|
    t.string   "name"
    t.string   "sub_request_email"
    t.integer  "department_id"
    t.integer  "view_perm_id"
    t.integer  "signup_perm_id"
    t.integer  "admin_perm_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public",            :default => true
    t.boolean  "active",            :default => true
  end

  create_table "location_sinks_location_sources", :id => false, :force => true do |t|
    t.integer "location_sink_id"
    t.string  "location_sink_type"
    t.integer "location_source_id"
    t.string  "location_source_type"
  end

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.string   "short_name"
    t.text     "useful_links"
    t.integer  "max_staff"
    t.integer  "min_staff"
    t.integer  "priority"
    t.string   "report_email"
    t.boolean  "active"
    t.integer  "loc_group_id"
    t.integer  "template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
  end

  create_table "locations_requested_shifts", :force => true do |t|
    t.integer  "requested_shift_id"
    t.integer  "location_id"
    t.boolean  "assigned",           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations_shift_preferences", :force => true do |t|
    t.integer  "shift_preference_id"
    t.integer  "location_id"
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notices", :force => true do |t|
    t.boolean  "sticky",        :default => false
    t.boolean  "useful_link",   :default => false
    t.boolean  "announcement",  :default => false
    t.boolean  "indefinite"
    t.text     "content"
    t.integer  "author_id"
    t.datetime "start"
    t.datetime "end"
    t.integer  "department_id"
    t.integer  "remover_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
    t.string   "type"
  end

  create_table "payform_item_sets", :force => true do |t|
    t.integer "category_id"
    t.date    "date"
    t.decimal "hours",          :precision => 10, :scale => 2
    t.text    "description"
    t.boolean "active"
    t.integer "approved_by_id"
  end

  create_table "payform_items", :force => true do |t|
    t.integer  "category_id"
    t.integer  "user_id"
    t.integer  "payform_id"
    t.integer  "payform_item_set_id"
    t.boolean  "active",                                             :default => true
    t.decimal  "hours",               :precision => 10, :scale => 2
    t.date     "date"
    t.text     "description"
    t.text     "reason"
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source_url"
  end

  create_table "payform_sets", :force => true do |t|
    t.integer  "department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payforms", :force => true do |t|
    t.date     "date"
    t.boolean  "monthly",                                       :default => false
    t.boolean  "end_of_month",                                  :default => false
    t.integer  "day",                                           :default => 6
    t.datetime "submitted"
    t.datetime "approved"
    t.datetime "printed"
    t.integer  "approved_by_id"
    t.integer  "department_id"
    t.integer  "user_id"
    t.integer  "payform_set_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "payrate",        :precision => 10, :scale => 2
    t.datetime "skipped"
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

  create_table "punch_clock_sets", :force => true do |t|
    t.string   "description"
    t.integer  "department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "punch_clocks", :force => true do |t|
    t.string   "description"
    t.integer  "user_id"
    t.integer  "department_id"
    t.integer  "runtime"
    t.datetime "last_touched"
    t.boolean  "paused"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "punch_clock_set_id"
  end

  create_table "repeating_events", :force => true do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "calendar_id"
    t.string   "days_of_week"
    t.integer  "user_id"
    t.string   "loc_ids"
    t.boolean  "is_set_of_timeslots"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "requested_shifts", :force => true do |t|
    t.datetime "preferred_start"
    t.datetime "preferred_end"
    t.datetime "acceptable_start"
    t.datetime "acceptable_end"
    t.integer  "day"
    t.integer  "template_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "assigned_start"
    t.datetime "assigned_end"
  end

  create_table "restrictions", :force => true do |t|
    t.datetime "starts"
    t.datetime "expires"
    t.integer  "max_subs"
    t.decimal  "max_hours",  :precision => 10, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_templates", :id => false, :force => true do |t|
    t.integer  "role_id"
    t.integer  "template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "shift_preferences", :force => true do |t|
    t.integer  "max_total_hours"
    t.integer  "min_total_hours"
    t.integer  "max_continuous_hours"
    t.integer  "min_continuous_hours"
    t.integer  "max_number_of_shifts"
    t.integer  "min_number_of_shifts"
    t.integer  "max_hours_per_day"
    t.integer  "template_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shifts", :force => true do |t|
    t.datetime "start"
    t.datetime "end"
    t.boolean  "active"
    t.integer  "calendar_id"
    t.integer  "repeating_event_id"
    t.integer  "user_id"
    t.integer  "location_id"
    t.integer  "department_id"
    t.boolean  "scheduled",                                         :default => true
    t.boolean  "signed_in",                                         :default => false
    t.boolean  "power_signed_up",                                   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "stats_unsent",                                      :default => true
    t.boolean  "stale_shifts_unsent",                               :default => true
    t.boolean  "missed",                                            :default => false
    t.boolean  "late",                                              :default => false
    t.boolean  "left_early",                                        :default => false
    t.boolean  "parsed",                                            :default => false
    t.decimal  "updates_hour",        :precision => 5, :scale => 2, :default => 0.0
  end

  add_index "shifts", ["user_id"], :name => "index_shifts_on_user_id"

  create_table "shifts_tasks", :id => false, :force => true do |t|
    t.integer  "task_id"
    t.integer  "shift_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "missed"
  end

  create_table "sub_requests", :force => true do |t|
    t.datetime "start"
    t.datetime "end"
    t.datetime "mandatory_start"
    t.datetime "mandatory_end"
    t.text     "reason"
    t.integer  "shift_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sub_requests_users", :id => false, :force => true do |t|
    t.integer "sub_request_id"
    t.integer "user_id"
  end

  create_table "tasks", :force => true do |t|
    t.integer  "location_id"
    t.string   "name"
    t.string   "kind"
    t.datetime "start"
    t.datetime "end"
    t.boolean  "interval_completed", :default => false
    t.time     "time_of_day"
    t.string   "day_in_week"
    t.boolean  "active",             :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "expired",            :default => false
    t.string   "description"
    t.string   "link"
  end

  create_table "template_time_slots", :force => true do |t|
    t.integer  "location_id"
    t.integer  "template_id"
    t.integer  "day"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "templates", :force => true do |t|
    t.string   "name"
    t.integer  "department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public"
    t.integer  "max_total_hours"
    t.integer  "min_total_hours"
    t.integer  "max_continuous_hours"
    t.integer  "min_continuous_hours"
    t.integer  "max_number_of_shifts"
    t.integer  "min_number_of_shifts"
    t.integer  "max_hours_per_day"
  end

  create_table "time_slots", :force => true do |t|
    t.integer  "location_id"
    t.integer  "calendar_id"
    t.integer  "repeating_event_id"
    t.datetime "start"
    t.datetime "end"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_configs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "default_dept"
    t.string   "view_loc_groups"
    t.string   "view_week"
    t.string   "watched_data_objects"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "taken_sub_email",        :default => true
    t.boolean  "send_due_payform_email", :default => true
  end

  create_table "user_profile_entries", :force => true do |t|
    t.integer  "user_profile_id"
    t.integer  "user_profile_field_id"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_profile_fields", :force => true do |t|
    t.string   "name"
    t.string   "display_type"
    t.string   "values"
    t.boolean  "public"
    t.boolean  "user_editable"
    t.integer  "department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "index_display", :default => true
  end

  create_table "user_profiles", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.integer  "crop_x"
    t.integer  "crop_y"
    t.integer  "crop_h"
    t.integer  "crop_w"
  end

  create_table "user_sinks_user_sources", :id => false, :force => true do |t|
    t.integer "user_sink_id"
    t.string  "user_sink_type"
    t.integer "user_source_id"
    t.string  "user_source_type"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "nick_name"
    t.string   "employee_id"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.string   "auth_type"
    t.string   "perishable_token",      :default => "",   :null => false
    t.integer  "default_department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "superuser"
    t.boolean  "supermode",             :default => true
    t.string   "calendar_feed_hash"
  end

  create_table "versions", :force => true do |t|
    t.integer  "versioned_id"
    t.string   "versioned_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "user_name"
    t.text     "changes"
    t.integer  "number"
    t.string   "tag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "versions", ["created_at"], :name => "index_versions_on_created_at"
  add_index "versions", ["number"], :name => "index_versions_on_number"
  add_index "versions", ["tag"], :name => "index_versions_on_tag"
  add_index "versions", ["user_id", "user_type"], :name => "index_versions_on_user_id_and_user_type"
  add_index "versions", ["user_name"], :name => "index_versions_on_user_name"
  add_index "versions", ["versioned_id", "versioned_type"], :name => "index_versions_on_versioned_id_and_versioned_type"

end
