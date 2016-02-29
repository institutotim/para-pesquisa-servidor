class User < ActiveRecord::Base
  include RocketPants::Cacheable

  scope :active, -> { where(active: true) }

  has_many :assignment, source: :agent, dependent: :destroy
  has_many :submissions, dependent: :destroy
  has_many :forms, through: :assignment

  mount_uploader :avatar, ImageUploader

  validates_presence_of :password, :username, on: :create
  validates_uniqueness_of :username
  validates_inclusion_of :role, in: %w(agent mod api)

  has_secure_password

  def active_model_serializer
    UserSerializer
  end
end
