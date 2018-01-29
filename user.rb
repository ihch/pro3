require 'mongoid'
require 'bcrypt'

class Task
  include Mongoid::Document

  field :name
  field :task_name
  field :task_log, type: Array, default: Array.new(12, Array.new(31, 0))

  validates :name, presence: true
  validates :task_name, presence: true
  validates :task_log, presence: true

end

class User
  include Mongoid::Document

  field :name
  field :task, type: Task
  field :password_hash
  field :password_salt

  attr_readonly :password_hash, :password_salt

  validates :name, presence: true
  validates :name, uniqueness: true
  # validates :password_hash, comfirmation: true
  validates :password_hash, presence: true
  validates :password_salt, presence: true

  def encrypt_password(password)
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  def self.authenticate(name, password)
    user = self.where(name: name).first
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      return user
    else
      nil
    end
  end
end

