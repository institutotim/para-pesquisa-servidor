class UrlField < Field
  requirable
  ranged

  URI_REGEXP = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[.\!\/\\w]*))?)/

  def custom_validation(answer)
    raise I18n.t(:url_isnt_valid, url: answer) if URI_REGEXP.match(answer).nil?
  end
end
