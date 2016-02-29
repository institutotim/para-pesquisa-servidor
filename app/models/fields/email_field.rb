class EmailField < Field
  ranged
  requirable

  def custom_validation(answer)
    raise I18n.t(:email_isnt_valid, email: answer) if /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/.match(answer).nil?
  end
end
