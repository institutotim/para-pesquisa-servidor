class SectionSerializer < ActiveModel::Serializer
  attributes :id, :name, :order
  has_many :fields
end
