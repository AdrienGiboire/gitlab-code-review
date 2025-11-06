class CreateFeedbacks < ActiveRecord::Migration[7.1]
  def change
    create_table :feedbacks do |t|
      t.references :export, null: false, foreign_key: true
      t.string :feedback_id, null: false
      t.boolean :reviewed, default: false, null: false

      t.timestamps
    end
    add_index :feedbacks, [:export_id, :feedback_id], unique: true
  end
end
