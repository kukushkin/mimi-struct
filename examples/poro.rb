require "mimi/struct"

#
# Mapping a PORO
#

class User < Mimi::Struct
  attribute :id
  attribute :name, from: :username
end

class UserData
  attr_reader :id, :username

  def initialize(username)
    @id = rand(1000)
    @username = username
  end
end

user_data = UserData.new("John")

puts User.new(user_data).to_h
