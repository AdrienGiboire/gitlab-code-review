class Feedback < ApplicationRecord
  belongs_to :export

  validates :feedback_id, presence: true, uniqueness: { scope: :export_id }

  scope :reviewed, -> { where(reviewed: true) }
  scope :unreviewed, -> { where(reviewed: false) }
end
