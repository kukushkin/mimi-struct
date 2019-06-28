require "mimi/struct"
require "json"

class User < Mimi::Struct
  attribute :id
  attribute :name, from: :username
end

class Comment < Mimi::Struct
  attribute :author, from: :user, using: User
  attribute :text
end

class Post < Mimi::Struct
  attribute :id
  attribute :author, using: User
  attribute :text
  attribute :comments, using: Comment
end

user1 = { id: 1, username: "Alice", email: "alice@gmail.com" }
user2 = { id: 2, username: "Bob", email: "bob@gmail.com" }
comm1 = { user: user1, text: "Mmm?" }
comm2 = { user: user2, text: "Hi!" }
post_params = { id: 1, author: user1, text: "Hello, world!", comments: [comm1, comm2] }

# Maps Post including all nested data
post = Post.new(post_params)
puts JSON.pretty_generate post.to_h
