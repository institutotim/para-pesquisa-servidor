class StopReasonSerializer < ActiveModel::Serializer
  attributes :id, :reason, :reschedule
end
