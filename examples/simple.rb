require "mimi/struct"

# Simple data mapping
#
class User < Mimi::Struct
  attribute :id
  attribute :name, from: :username
end

# Maps defined attributes, filters out all the extra attributes:
user = User.new(id: 1, username: "John", email: "john@gmail.com")

puts user.to_h