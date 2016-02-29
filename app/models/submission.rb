class Submission < ActiveRecord::Base
  include RocketPants::Cacheable
  belongs_to :form
  belongs_to :user
  belongs_to :assignment

  has_many :log
  has_many :corrections
  has_and_belongs_to_many :alternatives, class_name: 'Submission', foreign_key: 'alternative_id', join_table: 'alternatives_submissions', association_foreign_key: 'submission_id'

  STATUS = %w(new waiting_approval waiting_correction approved canceled rescheduled)

  scope :with_dependencies, -> { includes(:log, :alternatives, :corrections, :user) }

  self.per_page = 60

  def active_model_serializer
    SubmissionSerializer
  end

  validates_presence_of :status, in: STATUS

  before_validation do
    self.corrections.clear if self.status_changed? and self.status == 'waiting_approval'

    if self.status.blank?
      self.status = self.assignment.present? && self.assignment.moderator.nil? ? 'approved' : 'waiting_approval'
    end

    if self.assignment_id.nil?
      self.assignment = Assignment.find_by('form_id = ? AND (user_id = ? OR mod_id = ?)', self.form_id, self.user_id, self.user_id)
    end
  end

  serialize :answers, Hash

  def approve(user, date=nil)
    self.update status: 'approved'
    self.log.create! action: 'approved', user: user, date: date || DateTime.now
  end

  def reprove(user, date=nil)
    clear_non_read_only_answers
    self.update status: 'new'
    self.log.create! action: 'reproved', user: user, date: date || DateTime.now
  end

  def transfer(user, date=nil)
    self.log.create! action: 'transferred', user: self.user, date: date || DateTime.now
    self.user = user
    self.assignment = user.assignment.find_by(form_id: self.form_id)
    self.save
  end

  def reset(user)
    # if the submission is in a form that does not use extra data then resetting
    # it means deleting it (because it has no data at all at that point)
    if self.form.allow_new_submissions?
      self.destroy!
    else
      self.clear_non_read_only_answers
      self.update status: 'new'
      self.log.create! action: 'reset', user: user
    end
  end

  def clear_non_read_only_answers
    read_only_field_ids = self.form.fields.where(read_only: true).pluck(:id)

    self.answers.keys.each do |field_id|
      self.answers.delete(field_id) unless field_id.in?(read_only_field_ids)
    end
  end

  def answer(new_answers)
    self.answers = {}

    new_answers.each do |answer|
      field = Field.find(answer[0])
      field.validate_answer! answer[1]
      if $api_version == 1
        value = answer[1]
      else
        value = field.type == 'DatetimeField' ? answer[1].to_date.to_s : answer[1]
      end
      self.answers[answer[0]] = value
    end unless answers.nil?
  end

  def review(reviewer, new_corrections)
    self.corrections.clear

    self.status = 'waiting_correction'

    new_corrections.each do |correction|
      correction[:user] = reviewer
      self.corrections.create! correction
    end

    self.log.create! action: 'revised', user: reviewer
  end

  def last_created_date
    last_log_date_of_kind 'created'
  end

  def last_rescheduled_date
    last_log_date_of_kind 'rescheduled'
  end

  def last_started_date
    last_log_date_of_kind 'started'
  end

  def last_approved_date
    last_log_date_of_kind 'approved'
  end

  def last_log_date_of_kind(kind)
    last_log = nil

    self.log.each do |log_entry|
      if log_entry.action == kind
        if last_log.nil?
          last_log = log_entry
        else
          if last_log.date > log_entry.date
            last_log = log_entry
          end
        end
      end
    end

    if last_log
      last_log.date
    end
  end
end
