class FormSerializer < ActiveModel::Serializer
  attributes :id, :name, :subtitle, :pub_start, :pub_end, :max_reschedules, :allow_transfer,
             :allow_new_submissions, :undefined_mode, :requires_approval, :created_at, :updated_at

  has_many :sections
  has_many :stop_reasons

  def undefined_mode
    object.allow_new_submissions.nil?
  end
end
