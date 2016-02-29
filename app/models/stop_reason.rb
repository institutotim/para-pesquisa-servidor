class StopReason < ActiveRecord::Base
  belongs_to :form

  validates :reason, presence: true, uniqueness: true

  def active_model_serializer
    StopReasonSerializer
  end
end
