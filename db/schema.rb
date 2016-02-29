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

ActiveRecord::Schema.define(version: 20141108194835) do

  create_table "alternatives_submissions", id: false, force: true do |t|
    t.integer "submission_id"
    t.integer "alternative_id"
  end

  create_table "answers", force: true do |t|
    t.integer  "field_id"
    t.integer  "submission_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answers", ["field_id"], name: "index_answers_on_field_id"
  add_index "answers", ["submission_id"], name: "index_answers_on_submission_id"

  create_table "assignments", force: true do |t|
    t.integer  "quota",      default: 0
    t.integer  "form_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "mod_id"
  end

  add_index "assignments", ["form_id"], name: "index_assignments_on_form_id"
  add_index "assignments", ["user_id"], name: "index_assignments_on_user_id"

  create_table "choices", force: true do |t|
    t.string  "label"
    t.string  "value"
    t.integer "field_id"
  end

  add_index "choices", ["field_id"], name: "index_choices_on_field_id"

  create_table "corrections", force: true do |t|
    t.integer  "field_id"
    t.text     "message"
    t.integer  "user_id"
    t.integer  "submission_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "corrections", ["field_id"], name: "index_corrections_on_field_id"
  add_index "corrections", ["submission_id"], name: "index_corrections_on_submission_id"
  add_index "corrections", ["user_id"], name: "index_corrections_on_user_id"

  create_table "fields", force: true do |t|
    t.string   "label"
    t.string   "description"
    t.string   "type"
    t.string   "layout"
    t.boolean  "read_only",   default: false
    t.boolean  "identifier",  default: false
    t.text     "validations"
    t.text     "actions"
    t.integer  "order"
    t.boolean  "public",      default: true
    t.integer  "section_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fields", ["section_id"], name: "index_fields_on_section_id"

  create_table "forms", force: true do |t|
    t.string   "name"
    t.string   "subtitle"
    t.integer  "max_reschedules",       default: 0
    t.datetime "pub_start"
    t.datetime "pub_end"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "allow_transfer",        default: true
    t.integer  "order"
    t.boolean  "allow_new_submissions"
    t.boolean  "requires_approval",     default: false
  end

  create_table "forms_users", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "form_id"
  end

  create_table "logs", force: true do |t|
    t.integer  "user_id"
    t.integer  "submission_id"
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "date"
    t.integer  "stop_reason_id"
  end

  add_index "logs", ["user_id"], name: "index_logs_on_user_id"

  create_table "sections", force: true do |t|
    t.string   "name"
    t.integer  "order"
    t.integer  "form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sections", ["form_id"], name: "index_sections_on_form_id"

  create_table "stop_reasons", force: true do |t|
    t.string   "reason"
    t.boolean  "reschedule", default: false
    t.integer  "form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stop_reasons", ["form_id"], name: "index_stop_reasons_on_form_id"

  create_table "submissions", force: true do |t|
    t.boolean  "substitution",  default: false
    t.string   "status"
    t.text     "answers"
    t.text     "corrections"
    t.integer  "assignment_id"
    t.integer  "user_id"
    t.integer  "form_id"
    t.datetime "started_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "submissions", ["form_id"], name: "index_submissions_on_form_id"
  add_index "submissions", ["user_id"], name: "index_submissions_on_user_id"

  create_table "submissions_substitutions", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "substitution_id"
  end

  create_table "texts", force: true do |t|
    t.string   "title"
    t.string   "subtitle"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "username"
    t.string   "email"
    t.string   "password_digest"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar"
    t.boolean  "active",          default: true
  end

end
