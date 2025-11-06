class FeedbacksController < ApplicationController
  def mark_reviewed
    export = Export.find(params[:export_id])
    feedback_item = export.data['feedback'].find { |f| f['id'].to_s == params[:id] }

    unless feedback_item
      return respond_to do |format|
        format.html { redirect_to export_path(export), alert: 'Feedback not found' }
        format.json { render json: { error: 'Feedback not found' }, status: :not_found }
      end
    end

    feedback = export.feedbacks.find_or_create_by(feedback_id: params[:id])
    feedback.update!(reviewed: true)

    service = GitlabService.new
    begin
      service.add_reaction_to_note(export.project_path, export.mr_iid, params[:id].to_i, 'white_check_mark')
    rescue => e
      Rails.logger.error "Failed to add reaction: #{e.message}"
    end

    respond_to do |format|
      format.html { redirect_to export_path(export), notice: 'Feedback marked as reviewed' }
      format.json { render json: { success: true, feedback: feedback } }
    end
  end
end
