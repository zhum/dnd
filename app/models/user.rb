# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id            :integer          not null, primary key
#  name          :string
#  password_hash :string
#  email         :string
#  active        :boolean
#  secret        :string
#
require 'bcrypt'

class User < ActiveRecord::Base
  include BCrypt

  validates_presence_of :email, :password_hash

  has_many :players
  has_many :adventures, through: :players

  def just_players
    where(is_master: false)
  end

  def masters
    where(is_master: true)
  end

  def authorize(pass)
    password == pass
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
  #

  def send_password_reset
    secret = CredentialsManage.create_onetime_data(
      id,
      reset_password: 1,
      expire: Time.now.to_i + EXPIRATION_TIME
    )
    Pony.mail(
      to: email,
      via: :smtp,
      via_options: {
        address:              ENV['SMTP_SERVER'] || 'localhost',
        port:                 '25',
        enable_starttls_auto: true,
        user_name:            ENV['SMTP_USER'] || 'user',
        password:             ENV['SMTP_PASS'] || 'password_see_note',
        authentication:       :plain, # :plain, :login, :cram_md5
        domain:               'dnd.zhum.freeddns.org'
        # the HELO domain provided by the client to the server
      },
      from: ENV['SMTP_FROM'] || 'master@dnd.zhum.freeddns.org',
      subject: t('password_reset_subject'),
      body: t('password_reset_body', base: BASE_PATH, str: secret)
    )
  end

  def set_email(email)
    @email = email
    save
  end
end
