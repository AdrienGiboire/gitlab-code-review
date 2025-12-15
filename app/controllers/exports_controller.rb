class ExportsController < ApplicationController
  def index
    @exports = Export.order(created_at: :desc)
    respond_to do |format|
      format.html
      format.json { render json: @exports }
    end
  end

  def show
    @export = Export.find(params[:id])
    @gitlab_username = Setting.gitlab_username
    respond_to do |format|
      format.html
      format.json { render json: @export }
    end
  end

  def new
  end

  def create
    mr_url = params[:mr_url]

    unless mr_url
      flash[:error] = "MR URL is required"
      return redirect_to new_export_path
    end

    service = GitlabService.new
    result = service.export_merge_request_feedback(mr_url)

    @export = Export.create!(
      mr_url: mr_url,
      mr_iid: result[:mr_iid],
      project_path: result[:project_path],
      mr_title: result[:merge_request][:title],
      mr_author: result[:merge_request][:author],
      mr_state: result[:merge_request][:state],
      data: result
    )

    # Auto-mark feedback with check marks as reviewed
    result[:feedback].each do |feedback|
      if feedback[:has_check_mark]
        @export.feedbacks.create(feedback_id: feedback[:id].to_s, reviewed: true)
      end
    end

    redirect_to export_path(@export)
  rescue ArgumentError => e
    flash[:error] = e.message
    redirect_to new_export_path
  rescue Gitlab::Error::Error => e
    flash[:error] = "GitLab API error: #{e.message}"
    redirect_to new_export_path
  end

  def mark_reviewed
    @export = Export.find(params[:id])
    @export.update!(reviewed: !@export.reviewed)

    respond_to do |format|
      format.html { redirect_to exports_path, notice: "Export marked as #{@export.reviewed ? 'reviewed' : 'unreviewed'}" }
      format.json { render json: { success: true, export: @export } }
    end
  end
end
