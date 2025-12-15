class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  def self.get(key, default = nil)
    find_by(key: key)&.value || default
  end

  def self.set(key, value)
    setting = find_or_initialize_by(key: key)
    setting.value = value
    setting.save
  end

  def self.gitlab_username
    get("gitlab_username")
  end

  def self.gitlab_username=(value)
    set("gitlab_username", value)
  end
end
