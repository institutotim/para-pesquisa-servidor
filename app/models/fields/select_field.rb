class SelectField < Field
  has_options
  requirable

  def active_model_serializer
    FieldWithOptionsSerializer
  end
end