class AssignmentsController < ApplicationController
  load_and_authorize_resource

  def index
    assignments = Assignment.where(form_id: params[:form_id])

    if params[:name_like]
      assignments = assignments.joins(:user).where('lower(users.name) like ?', "%#{params[:name_like].downcase}%")
    end

    if params[:username_like]
      assignments = assignments.joins(:user).where('lower(users.username) like ?', "%#{params[:username_like].downcase}%")
    end

    if params[:by_role]
      assignments = assignments.joins(:user).where('users.role = ?', params[:by_role])
    end

    assignments = assignments.paginate(page: params[:page]) if params[:as].nil? or params[:as] == 'paginated_collection'

    expose assignments, except: [:form_id, :form]
  end

  def create
    assignment = Assignment.create! assignment_params
    head :created
    expose assignment_id: assignment.id
  end

  def update
    assignment = Assignment.find params[:id]

    if params[:quota].present? and params[:quota] < assignment.submissions.count
      raise I18n.t(:the_questionnaires_is_greater_than_target)
    end

    assignment.update assignment_params
    head :no_content
  end

  def destroy
    Assignment.find(params[:id]).destroy
    head :no_content
  end

  private
  def assignment_params
    params.permit :user_id, :form_id, :quota, :mod_id
  end
end
