class AddReviewedToExports < ActiveRecord::Migration[7.1]
  def change
    add_column :exports, :reviewed, :boolean, default: false, null: false
  end
end
