class FullLogSerializer < ActiveModel::Serializer
  attributes :action, :user, :submission_owner, :form, :date => 'when', :target_id => 'submission_id'

  has_one :stop_reason

  def target_id
    if object.submission
      object.submission.id
    end
  end

  def form
    unless object.submission.nil? or object.submission.form.nil?
      {:id => object.submission.form.id, :name => object.submission.form.name}
    end
  end

  def submission_owner
    unless object.submission.nil? or object.submission.user.nil?
      {:id => object.submission.user.id, :avatar => object.submission.user.avatar.url, :name => object.submission.user.name}
    end
  end

  def user
    {:id => object.user.id, :avatar => object.user.avatar.url, :name => object.user.name}
  end

  def form_id
    object.submission.form.id
  end
end
