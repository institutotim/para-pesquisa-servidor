class Assignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :form
  has_many :submissions, dependent: :destroy
  belongs_to :moderator, class_name: 'User', foreign_key: 'mod_id'

  validates :user_id, :form_id, presence: true
end
