# frozen_string_literal: false

require 'dbm'
require 'yaml/dbm'
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
  class<<self
    def transaction
      d = YAML::DBM.new('db/credentials.yml')
      # d.transaction do
        yield d
      # end
      d.close
    end

    EXPIRATION_TIME = 3600 * 6 # 6 hours

    def delete_expired(exp = EXPIRATION_TIME)
      now = Time.now.to_i
      transaction do |db|
        db.delete_if { |_, v| v[:created_at] + exp > now }
      end
    end

    # store data and return unique key
    def create_onetime_data(user, data = {})
      key = SecureRandom.uuid
      # d = db
      # d.transaction do
      #   d[key] = { user: user, created_at: Time.now.to_i }.merge(data)
      # end
      transaction do |db|
        db[key] = { user: user, created_at: Time.now.to_i }.merge(data)
      end
      key
    end

    # get stored data by key, delete it then by default
    def get_ontime_data(str, delete = true)
      ret = nil
      # d = db
      # d.transaction do
      #   ret = d[str]
      #   d.delete(str) if delete
      # end
      transaction do |db|
        ret = db[str]
        db.delete(str) if delete
      end
      ret
    end

    # get all user related data
    def search_by_user(user)
      # d = db
      transaction do
        d.select { |_, v| v[:user] == user }
      end
    end
  end
end
