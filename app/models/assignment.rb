class Assignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :form
  has_many :submissions, dependent: :destroy
  belongs_to :moderator, class_name: 'User', foreign_key: 'mod_id'

  validates :user_id, :form_id, presence: true

  def transfer_submissions(assignment)
    submissions.each do |submission|
      submission.transfer(assignment.user, assignment)
      self.quota -= 1
      assignment.quota += 1
    end

    self.save!
    assignment.save!
  end
end
