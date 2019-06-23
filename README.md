# WIP: Mimi::Struct

Object to Object mapper.

Allows you to map a PORO, Struct, OpenStruct or a Hash into a simple Ruby object
with predefined schema and transformation rules.

## Usage

```ruby
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
# {
#   :id=>"person1", :type=>"PERSON", :first_name=>"John", :last_name=>"Smith",
#   :created_at=>2019-06-23 16:07:30 UTC, :updated_at=>2019-06-23 16:07:30 UTC
# }
```

## Defining your Mimi::Struct schema

### :from
### :using
### :default
### :if
### :optional


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kukushkin/mimi-struct. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Mimi::Struct project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/kukushkin/mimi-struct/blob/master/CODE_OF_CONDUCT.md).
