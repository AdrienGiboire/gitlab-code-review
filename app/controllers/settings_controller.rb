class SettingsController < ApplicationController
  def show
    @gitlab_username = Setting.gitlab_username
  end

  def update
    Setting.gitlab_username = params[:gitlab_username]
    redirect_to settings_path, notice: "Settings saved successfully"
  end
end
