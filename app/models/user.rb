require 'bcrypt'

class User < ActiveRecord::Base
  include BCrypt

  validates_presence_of :email, :password_hash

  has_many :players
  has_many :adventures, through: :players

  def just_players
    self.where(is_master: false)
  end
  
  def masters
    self.where(is_master: true)
  end

  def authorize(pass)
    self.password == pass
  end

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  # def set_password pass
  #   password = Password.create(pass)
  #   save
  # end

  def set_email email
    @email = email
    save
  end
end