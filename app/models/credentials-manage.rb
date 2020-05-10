require "yaml/store"
require 'securerandom'

module CredentialsManage

  def db
    YAML::Store.new 'db/credentials.yml'
  end

  def create_onetime_data user, data={}
    key = SecureRandom.uuid
    db.transaction do
      db[key] = {user: user}.merge data
    end
  end

  def get_ontime_data str, delete=true
    ret = nil
    db.transaction do
      ret = db[str]
      db.delete str
    end
    ret
  end

  def search_by_user user
    db.transaction do
      db.select{|k,v| v[:user]==user }
    end
  end
end
