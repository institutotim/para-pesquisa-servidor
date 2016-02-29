class Section < ActiveRecord::Base
  has_many   :fields, dependent: :destroy
  belongs_to :form

  validates_presence_of :name

  def active_model_serializer
    SectionSerializer
  end
end
