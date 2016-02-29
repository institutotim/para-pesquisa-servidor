class NumberField < Field
  ranged
  requirable

  def custom_validation(answer)
    Float(answer) rescue raise I18n.t(:value_isnt_a_number, value: answer)
  end
end
