class Log < ActiveRecord::Base
  belongs_to :submission
  belongs_to :user
  belongs_to :stop_reason

  validates_inclusion_of :action, in: %w(created started submitted reset revised approved reproved canceled rescheduled transferred)
  validate :range_date, if: lambda { action == 'rescheduled' and date.present? }

  default_scope -> { includes(:stop_reason) }

  before_save do
    self.date ||= DateTime.now
  end

  private
    def range_date
      end_date = submission.form.pub_end
      self.errors.add(:date, :greater_than_or_equal_to, count: I18n.l(Date.today)) if date.to_date < Date.today
      self.errors.add(:date, :less_than_or_equal_to,    count: I18n.l(end_date))   if end_date.present? and date.to_date > end_date
    end
end
