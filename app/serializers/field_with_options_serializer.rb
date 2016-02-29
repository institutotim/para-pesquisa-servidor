require 'active_support/core_ext/hash/except'

class FieldWithOptionsSerializer < FieldSerializer
  attributes :options

  def options
    object.choices.map { |choice| {:label => choice.label, :value => choice.value }}
  end
end
