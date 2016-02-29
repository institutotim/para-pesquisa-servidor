class Form < ActiveRecord::Base
  include RocketPants::Cacheable
  scope :published, -> { where('(pub_start <= :now AND pub_end >= :now) OR (pub_start IS NULL OR pub_end IS NULL)', now: Time.now) }

  has_many :assignments,  dependent: :destroy
  has_many :users,        through:   :assignments
  has_many :sections,     dependent: :destroy
  has_many :submissions,  dependent: :destroy
  has_many :fields,       through:   :sections
  has_many :stop_reasons, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validate :validate_pub_end, if: :pub_end?

  def active_model_serializer
    FormSerializer
  end

  def quota
    self.assignments.sum('quota')
  end

  private
    def validate_pub_end
      self.errors.add(:pub_end, :greater_than_or_equal_to, count: I18n.l(Date.today)) if new_record? and pub_start.blank? and pub_end < Date.today
      self.errors.add(:pub_end, :greater_than_or_equal_to, count: I18n.l(pub_start))  if pub_start? and pub_end < pub_start
    end
end
