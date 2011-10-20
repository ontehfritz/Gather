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

ActiveRecord::Schema.define(:version => 20110819141339) do

  create_table "elements", :force => true do |t|
    t.text     "element_text"
    t.integer  "score"
    t.integer  "sort_index"
    t.boolean  "active"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "input_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "options", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "question_images", :force => true do |t|
    t.integer  "question_id"
    t.string   "content_type"
    t.string   "file_name"
    t.binary   "image_data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "question_types", :force => true do |t|
    t.string   "type_name"
    t.boolean  "is_multi_answer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "questions", :force => true do |t|
    t.text     "question_text"
    t.string   "instructions",        :limit => 512
    t.integer  "sort_index"
    t.string   "short_name"
    t.string   "additional_comments", :limit => 512
    t.text     "matrix_columns"
    t.integer  "rating"
    t.boolean  "is_hidden"
    t.boolean  "has_sub_question"
    t.boolean  "is_answer_required"
    t.boolean  "is_sub"
    t.boolean  "active"
    t.string   "type"
    t.integer  "section_id"
    t.integer  "option_id"
    t.integer  "input_type_id"
    t.integer  "question_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "responses", :force => true do |t|
    t.text     "answer_text"
    t.integer  "subject_id"
    t.integer  "element_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sections", :force => true do |t|
    t.string   "name",            :limit => 512
    t.text     "description"
    t.integer  "sort_index"
    t.boolean  "active"
    t.integer  "statistician_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "skip_logic_types", :force => true do |t|
    t.string   "skip_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "skip_logics", :force => true do |t|
    t.string   "types"
    t.integer  "element_id"
    t.integer  "question_id"
    t.integer  "section_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statisticians", :force => true do |t|
    t.string   "name",                 :limit => 512
    t.text     "intro"
    t.text     "outro"
    t.string   "content_type"
    t.string   "file_name"
    t.binary   "image_data"
    t.boolean  "is_anonymous"
    t.boolean  "is_password_required"
    t.boolean  "is_id_required"
    t.boolean  "power"
    t.boolean  "multi_session"
    t.string   "unlock_key"
    t.string   "slug"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sub_questions", :force => true do |t|
    t.integer  "question_parent_id", :null => false
    t.integer  "question_sub_id",    :null => false
    t.integer  "element_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subjects", :force => true do |t|
    t.string   "identifier"
    t.string   "first_name",   :limit => 512
    t.string   "middle_name",  :limit => 512
    t.string   "last_name",    :limit => 512
    t.string   "email",        :limit => 1026
    t.boolean  "is_anonymous"
    t.string   "password",     :limit => 1026
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_completed_surveys", :force => true do |t|
    t.integer  "subject_id"
    t.integer  "statistician_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_skips", :force => true do |t|
    t.integer  "subject_id"
    t.integer  "question_id"
    t.integer  "section_id"
    t.integer  "statistician_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
