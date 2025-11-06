# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_11_06_112245) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "exports", force: :cascade do |t|
    t.string "mr_url", null: false
    t.integer "mr_iid", null: false
    t.string "project_path", null: false
    t.string "mr_title"
    t.string "mr_author"
    t.string "mr_state"
    t.jsonb "data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "reviewed", default: false, null: false
    t.index ["mr_url"], name: "index_exports_on_mr_url"
    t.index ["project_path", "mr_iid"], name: "index_exports_on_project_path_and_mr_iid"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.bigint "export_id", null: false
    t.string "feedback_id", null: false
    t.boolean "reviewed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["export_id", "feedback_id"], name: "index_feedbacks_on_export_id_and_feedback_id", unique: true
    t.index ["export_id"], name: "index_feedbacks_on_export_id"
  end

  add_foreign_key "feedbacks", "exports"
end
