class FieldSerializer < ActiveModel::Serializer
  attributes :id, :label, :identifier, :read_only, :description, :layout, :type, :actions, :order, :parse_validation => 'validations'

  def parse_validation
    validations = {}

    object.validations.each do |validation_type, validation_params|
      case validation_type
        when :range then
          validations[validation_type] = [validation_params.first, validation_params.last]
        else
          validations[validation_type] = validation_params
      end
    end

    validations
  end
end
