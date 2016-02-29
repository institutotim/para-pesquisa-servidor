class LogSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :action, :stop_reason_id => 'reason_id', :date => 'when'
  has_one :stop_reason
end
