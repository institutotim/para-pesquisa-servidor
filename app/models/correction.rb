class Correction < ActiveRecord::Base
  belongs_to :submission
  belongs_to :field
  belongs_to :user

  def active_model_serializer
    CorrectionSerializer
  end

  after_validation do
    raise I18n.t(:field_isnt_of_this_form) unless self.submission.form.fields.include? self.field
  end
end
