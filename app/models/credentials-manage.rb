# frozen_string_literal: true

require 'yaml/store'
require 'securerandom'

#
# CredentialsManage module
#
# Examples:
# CredentialsManage.create_onetime_data(
#   'user1',
#   pass: '123',
#   name: 'Foo') => 'qwe-asd-zxc-123-ppp'
#
# CredentialsManage.search_by_user('user1')
#   => {'qwe-asd-zxc-123-ppp' => {pass: '123', name: 'Foo'}}
#
# CredentialsManage.get_ontime_data('qwe-asd-zxc-123-ppp')
#   => {pass: '123', name: 'Foo'}
#
module CredentialsManage
  def db
    YAML::Store.new('db/credentials.yml')
  end

  # store data and return unique key
  def create_onetime_data(user, data = {})
    key = SecureRandom.uuid
    db.transaction do
      db[key] = { user: user, created_at: Time.now.to_i }.merge(data)
    end
    key
  end

  # get stored data by key, delete it then by default
  def get_ontime_data(str, delete = true)
    ret = nil
    db.transaction do
      ret = db[str]
      db.delete(str) if delete
    end
    ret
  end

  # get all user related data
  def search_by_user(user)
    db.transaction do
      db.select { |_, v| v[:user] == user }
    end
  end
end
