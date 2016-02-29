class AssignmentSerializer < ActiveModel::Serializer
  attributes :id, :form_id, :quota
  has_one :user
  has_one :moderator
  has_one :form
end
