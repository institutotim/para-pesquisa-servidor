class SubmissionSerializer < ActiveModel::Serializer
  attributes :id, :form_id, :status, :answers, :created_at, :updated_at, :last_rescheduled_date => 'last_reschedule_date'
  has_many :log
  has_many :alternatives
  has_many :corrections
  has_one :user, key: :owner

  def answers
    object.answers.map { |field_id, answer| [field_id.to_s.to_i, answer] }
  end
end
