class Choice < ActiveRecord::Base
  belongs_to :field

  def active_model_serializer
    ChoiceSerializer
  end
end