class Export < ApplicationRecord
  has_many :feedbacks, dependent: :destroy

  validates :mr_url, presence: true
  validates :mr_iid, presence: true
  validates :project_path, presence: true
  validates :data, presence: true

  scope :reviewed, -> { where(reviewed: true) }
  scope :unreviewed, -> { where(reviewed: false) }

  def as_json(options = {})
    json = super(options)
    reviewed_ids = feedbacks.reviewed.pluck(:feedback_id)
    
    # Add reviewed attribute to each feedback item
    if json['data'] && json['data']['feedback']
      json['data']['feedback'].each do |feedback|
        feedback['reviewed'] = reviewed_ids.include?(feedback['id'].to_s)
      end
    end
    
    json
  end
end
