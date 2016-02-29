class DatetimeField < Field
  requirable
  #TODO: Add range support

  def custom_validation(answer)
    raise I18n.t(:date_is_invalid, date: answer) if Time.parse(answer).nil?
  end
end
