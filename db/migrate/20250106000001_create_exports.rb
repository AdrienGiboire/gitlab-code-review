class CreateExports < ActiveRecord::Migration[7.1]
  def change
    create_table :exports do |t|
      t.string :mr_url, null: false
      t.integer :mr_iid, null: false
      t.string :project_path, null: false
      t.string :mr_title
      t.string :mr_author
      t.string :mr_state
      t.jsonb :data, null: false, default: {}

      t.timestamps
    end

    add_index :exports, :mr_url
    add_index :exports, [:project_path, :mr_iid]
  end
end
