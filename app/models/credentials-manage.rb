# frozen_string_literal: false

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
  class<<self
    def db
      YAML::Store.new('db/credentials.yml')
    end

    public

    # store data and return unique key
    def create_onetime_data(user, data = {})
      key = SecureRandom.uuid
      d = db
      d.transaction do
        d[key] = { user: user, created_at: Time.now.to_i }.merge(data)
      end
      key
    end

    # get stored data by key, delete it then by default
    def get_ontime_data(str, delete = true)
      ret = nil
      d = db
      d.transaction do
        ret = d[str]
        d.delete(str) if delete
      end
      ret
    end

    # get all user related data
    def search_by_user(user)
      d = db
      d.transaction do
        d.select { |_, v| v[:user] == user }
      end
    end
  end
end
