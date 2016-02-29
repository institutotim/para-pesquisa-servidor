class UsersController < ApplicationController
  load_and_authorize_resource

  caches :show, :forms, :users

  def index
    user_list = User.all

    if params[:name_like].present?
      user_list = user_list.where('lower(name) like ?', "%#{params[:name_like].downcase}%")
    end

    if params[:username_like].present?
      user_list = user_list.where('lower(username) like ?', "%#{params[:username_like].downcase}%")
    end

    user_list = user_list.where(role: params[:by_role].split(',')) if params[:by_role].present?
    user_list = user_list.paginate(page: params[:page]) if params[:as].nil? or params[:as] == 'paginated_collection'

    expose user_list
  end

  def show
    expose User.find(params[:id]), except: [:password_digest, :updated_at]
  end

  def create
    fields = user_params
    fields[:password_confirmation] = fields[:password] if fields[:password_confirmation].nil?
    user = User.create! fields
    head :created
    expose user_id: user.id
  end

  def update
    user = User.find(params[:id])

    params[:password_confirmation] = params[:password] if params[:password].present?
    user.avatar = params[:avatar] if params[:avatar].present?

    user.update(user_params)
    head :no_content
  end

  def destroy
    user = User.find(params[:id])
    if (user.role == 'agent' and user.try(:submissions).blank?) or
       (user.role == 'mod' and Assignment.find_by(mod_id: user.id).blank?) or user.role == 'api'
      user.destroy!
    else
      user.update!(active: false)
    end
    head :no_content
  end

  def save_avatar
    user = User.find(params[:id])
    user.avatar = params[:avatar]
    user.save!
    expose avatar: user.avatar.url
  end

  def remove_avatar
    user = User.find(params[:id])
    user.avatar = nil
    user.save!
    head :no_content
  end

  def forms
    user = User.find(params[:user_id])

    case user.role
      when 'agent' then
        expose_stashed :forms, user.assignment, except: [:form_id, :moderator, :user]
      when 'mod' then
        used_form_ids = []
        result = []
        Assignment.where(mod_id: user.id).each do |a|
          unless used_form_ids.include?(a.form_id)
            result.push(a)
            used_form_ids.push(a.form_id)
          end
        end

        expose_stashed :forms, result, except: [:moderator, :user, :form_id, :quota]
      else
        head :bad_request
    end
  end

  def users
    user = User.find(params[:id])
    expose Assignment.joins(:user).where(mod_id: user.id), except: [:moderator, :form]
  end

  def submissions
    user = User.find(params[:user_id])

    case user.role
      when 'agent' then
        submissions = user.submissions.with_dependencies
      when 'mod' then
        submissions = Submission.with_dependencies.joins(:assignment).where(assignments: {mod_id: user.id}).distinct(:submission)
      else
        return head :bad_request
    end

    submissions = datetime_filters(submissions, nil, 'submissions')
    submissions = submissions.where(status: params[:by_status]) if params[:by_status].present?
    submissions = submissions.where(form_id: params[:form_id])  if params[:form_id].present?
    submissions = submissions.paginate(page: params[:page])     if params[:as] == 'paginated_collection'

    expose_stashed :submissions, submissions
  end

  private
  def user_params
    params.permit :name, :username, :email, :password, :password_confirmation, :role
  end
end
