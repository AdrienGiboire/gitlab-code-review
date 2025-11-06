module Api
  class ExportController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      mr_url = params[:mr_url]

      unless mr_url
        return render json: { error: 'mr_url is required' }, status: :bad_request
      end

      service = GitlabService.new
      result = service.export_merge_request_feedback(mr_url)

      render json: result
    rescue ArgumentError => e
      render json: { error: e.message }, status: :bad_request
    rescue Gitlab::Error::Error => e
      render json: { error: "GitLab API error: #{e.message}" }, status: :unprocessable_entity
    end
  end
end
