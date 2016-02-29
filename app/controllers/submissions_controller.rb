class SubmissionsController < ApplicationController
  load_and_authorize_resource

  def index
    order_by  = params[:order_by] || :updated_at
    order_dir = (params[:order_type] || 'desc').to_sym
    listing   = datetime_filters(Submission.where(form_id: params[:form_id]))
    listing   = listing.where(status: params[:by_status]) if params[:by_status].present?
    expose listing.order(order_by => order_dir).paginate(page: params[:page]),
           each_serializer: FullSubmissionSerializer
  end

  def show
    expose Submission.find(params[:id])
  end

  def create
    form = Form.find(params[:form_id])

    raise I18n.t(:has_submissions_pre_registered_you_cant_create_manually) if form.allow_new_submissions == false

    form.update(allow_new_submissions: true) if form.allow_new_submissions.nil?

    Submission.transaction do
      assignment = Assignment.find_by(user_id: current_user, form_id: params[:form_id])

      raise I18n.t(:the_user_has_no_permission_to_this_form) if assignment.nil?
      raise I18n.t(:user_has_passed_of_its_target) if assignment.submissions.count >= assignment.quota

      submission = form.submissions.create!(user: current_user, form_id: params[:form_id], assignment: assignment)
      submission.answer(params[:answers]) if params[:answers].present?
      submission.log.create! action: 'started', user: current_user, date: params[:started_at] || DateTime.now
      submission.save

      expose submission_id: submission.id
    end
  end

  def update
    submission        = Submission.find(params[:id])
    submission.status = params[:status] if params[:status].present?

    if submission.status == 'waiting_approval' and submission.log.find_by_action('started').blank?
      submission.log.create! action: 'started', date: params[:started_at] || DateTime.now, user: current_user
    end

    submission.answer(params[:answers])                   if params[:answers].present?
    submission.review(current_user, params[:corrections]) if params[:corrections].present?
    submission.save

    head :no_content
  end

  def destroy
    Submission.find(params[:id]).destroy
    head :no_content
  end

  def create_correction
    correction = Submission.find(params[:submission_id]).corrections.create correction_params.merge(user_id: current_user.id)
    head :created
    expose correction_id: correction.id
  end

  def update_correction
    Correction.find(params[:id]).update! correction_params
    head :no_content
  end

  def delete_correction
    Correction.find(params[:id]).destroy
    head :no_content
  end

  def reschedule
    submission = Submission.find(params[:id])
    reason     = StopReason.find(params[:reason_id])
    status     = reason.reschedule? ? 'rescheduled' : 'canceled'

    submission.log.create! action: status, user: current_user, date: params[:date], stop_reason: reason
    submission.update status: status

    head :no_content
  end

  def moderate
    submission = Submission.find(params[:id])

    if params[:submission_action] == 'approve'
      submission.approve current_user, params[:date]
    else
      submission.reprove current_user, params[:date]
    end

    head :no_content
  end

  def reset
    Submission.find(params[:id]).reset current_user
    json_set_status :no_content
  end

  def reset_by_mod
    user = User.find_by(id: params[:mod_id], role: 'mod')
    raise ActiveRecord::RecordNotFound.new(I18n.t(:moderator_not_found)) if user.nil?

    Assignment.where(mod_id: user.id).each do |assignment|
      assignment.user.submissions.each { |submission| submission.reset(current_user) }
    end

    json_set_status :no_content
  end

  def swap
    user_from = User.find(params[:user_id_from])
    user_to   = User.find(params[:user_id_to])
    pivot     = user_to.submissions.pluck(:id)

    Submission.where(user_id: user_from.id).update_all(user_id: user_to.id)
    Submission.where(id: pivot).update_all(user_id: user_from.id)

    json_set_status :no_content
  end

  def transfer_by_form_id
    submissions = Submission.where(user_id: params[:user_id_from], form_id: params[:form_id])
    user_to     = User.find(params[:user_id_to])

    submissions.each { |submission| submission.transfer(user_to, params[:date]) }

    json_set_status :no_content
  end

  def transfer_by_submission_id
    submissions = Submission.find(params[:submissions_ids])
    user        = User.find(params[:user_id])

    raise I18n.t(:cant_transfer_submissions_of_users_that_are_not_agents) unless user.role == 'agent'

    submissions.each { |submission| submission.transfer(user, params[:date]) }

    user.assignment.first.update!(quota: user.submissions.count) unless user.assignment.first.quota.zero?

    json_set_status :no_content
  end

  private
  def listing_params
    params.permit :created_from, :created_to, :updated_from, :updated_to
  end

  def submissions_params
    params.permit :answers, :status
  end

  def correction_params
    params.permit :user_id, :message, :field_id
  end
end
