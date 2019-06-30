require "mimi/struct"

class Customer < Mimi::Struct
  attribute :id
  attribute :type, using: -> (o) { o.type.to_s.upcase }

  group if: -> (o) { o.type == :person } do
    attribute :first_name, from: :firstName
    attribute :last_name, from: :lastName
  end

  group if: -> (o) { o.type == :company } do
    attribute :company_name
  end

  attribute :created_at, default: -> { Time.now.utc }
  attribute :updated_at, default: -> { Time.now.utc }
end

customer = Customer << { id: "person1", type: :person, firstName: "John", lastName: "Smith" }

puts customer.to_h
