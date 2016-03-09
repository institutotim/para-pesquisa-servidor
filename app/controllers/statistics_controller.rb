class StatisticsController < ApplicationController
  skip_authorization_check

  def global
    submissions = Submission.all

    if submissions
      statistics = Submission::STATUS.inject({}) do |hash, status|
        hash[status] = submissions.count(conditions: {status: status}) unless status == 'new'
        hash
      end

      statistics['total_filled'] = submissions.where.not(status: 'new').count
      statistics['total']        = submissions.count
      statistics['form_count']   = Form.count
      statistics['user_count']   = User.count
    else
      statistics = {'total_filled' => 0, 'total' => 0, 'form_count' => 0, 'user_count' => 0}
    end

    expose statistics
  end

  def form
    form        = Form.find(params[:form_id])
    submissions = form.submissions

    statistics = Submission::STATUS.inject({}) do |hash, status|
      hash[status] = submissions.where(status: status).count unless status == 'new'
      hash
    end

    statistics['user_count'] = form.users.count

    if form.quota.nil? or form.quota == 0
      statistics['pending'] = 0
    else
      statistics['pending'] = form.quota - submissions.where.not(status: 'new').count
    end

    statistics['total_filled'] = form.submissions.where.not(status: 'new').count
    statistics['total']        = form.submissions.count
    statistics['form']         = {id: form.id, name: form.name}

    expose statistics
  end

  def user
    user = User.find(params[:user_id])

    if user.role == 'agent'
      submissions = user.submissions
    elsif user.role == 'mod'
      submissions = Submission.joins(:assignment).where(assignments: {mod_id: user.id}).distinct(:submission)
    else
      raise I18n.t(:cant_show_statistics_of_user_with_api_permission)
    end

    submissions = submissions.where(form_id: params[:form_id]) if params[:form_id].present?

    statistics = Submission::STATUS.inject({}) do |hash, status|
      hash[status] = submissions.count(conditions: {status: status}) unless status == 'new'
      hash
    end

    statistics['total_filled'] = submissions.where.not(status: 'new').count
    statistics['total']        = submissions.count
    assignments_with_quota     = user.assignment.where('quota IS NOT NULL AND quota > 0')

    if params[:form_id].nil?
      statistics['form_count'] = user.forms.count
    else
      assignments_with_quota = assignments_with_quota.where(form_id: params[:form_id])
      statistics['form']     = {id: params[:form_id].to_i, name: Form.find(params[:form_id]).name}
    end

    if assignments_with_quota.blank?
      statistics['pending'] = 0
    else
      total_quota  = assignments_with_quota.sum('quota')
      total_filled = assignments_with_quota.sum do |a|
        Submission.where(user_id: user.id, form_id: a.form_id).where.not(status: 'new').count
      end
      statistics['pending'] = total_quota - total_filled
    end

    statistics['user'] = {id: user.id, name: user.name}

    expose statistics
  end
end
