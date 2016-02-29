class CorrectionSerializer < ActiveModel::Serializer
  attributes :id, :field_id, :message, :user_id
end
