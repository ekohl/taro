# Taro - Typed Api using Ruby Objects

This library provides an object-based type system for RESTful Ruby APIs, with built-in parameter parsing, response rendering, and OpenAPI schema export.

Inspired by `apipie-rails` and `graphql-ruby`.

## ⚠️ This is a work in progress - TODO:

- additionalProperties, FreeFormType
- maybe later: apidoc rendering based on export (rails engine?)
- [query logs metadata](https://github.com/rmosolgo/graphql-ruby/blob/dcaaed1cea47394fad61fceadf291ff3cb5f2932/lib/generators/graphql/install_generator.rb#L48-L52)
- rspec matchers for testing?
- examples https://swagger.io/specification/#example-object
- `deprecation`
- maybe detect when undeclared params are sent (later: only if additionalProperties is false)
- more docs
- consider rename: ObjectType > TaroObjectType, its annoying to inherit from Taro::ObjectType, but its non-optional since ObjectType alone is too generic
  - another alternative: include Taro::ObjectType might be more descriptive
- object type: accept Hash w.i.access, AC::Parameters?
- ISO8601Time, ISO8601Date types

## Installation

```bash
bundle add taro
```

Then, if using rails, generate type files to inherit from:

```bash
rails generate taro:install [ --dir app/my_types_dir ]
```

## Usage

The core concept of Taro are type classes.

This is how type classes can be used in a Rails controller:

```ruby
class BikesController < ApplicationController
  # Calling `api` to set an endpoint description is optional.
  api     'Update a bike'
  # Params can come from the path, e.g. /bike/:id)
  param   :id, type: 'UUID', null: false, description: 'ID of the bike to update'
  # They can also come from the query string or request body
  param   :bike, type: 'BikeInputType', null: false
  # Return types can differ by status code and can be nested as in this case:
  returns :bike, code: :ok, type: 'BikeType', description: 'update success'
  # This one is not nested:
  returns code: :unprocessable_content, type: 'MyErrorType', description: 'failure'
  def update
    # defined params are available as @api_params
    bike = Bike.find(@api_params[:id])
    success = bike.update(@api_params[:bike])

    # Types can be used to render responses.
    # The object
    if success
      render json: { bike: BikeType.render(bike) }, status: :ok
    else
      render json: MyErrorType.render(bike.errors.first), status: :unprocessable_entity
    end
  end
end
```

Notice the multiple roles of types: They are used to define the structure of API requests and responses, and render the response. Both the input and output of the API can be validated against the schema if desired (see below).

Here is an example of the `BikeType` from that controller:

```ruby
class BikeType < ObjectType
  # Optional description of BikeType (for API docs and the OpenAPI export)
  self.description = 'A bike and all relevant information about it'

  # Object types have fields. Each field has a name, its own type,
  # and a `null:` setting to indicate if it can be nil.
  # Providing a description is optional.
  field :brand, type: 'String', null: true, description: 'The brand name'

  # Fields can reference other types and arrays of values
  field :users, array_of: 'UserType', null: false

  # Pagination is built-in for big lists
  field :parts, page_of: 'PartType', null: false

  # Custom methods can be chosen to resolve fields
  field :has_brand, type: 'Boolean', null: false, method: :brand?

  # Field resolvers can also be implemented or overridden on the type.
  # The object passed in to `BikeType.render` is available as `object`.
  field :fancy_info, type: 'String', null: false
  def fancy_info
    "A bike named #{object.name} with #{object.parts.count} parts."
  end
end
```

### Input types

Note the use of `BikeInputType` in the `param` declaration above? It could look like so:

```ruby
class BikeInputType < InputType
  field :brand,  type: 'String',  null: true,  description: 'The brand name'
  field :wheels, type: 'Integer', null: false, default: 2
end
```

The usage of such dedicated InputTypes is optional. Object types can also be used to define accepted parameters, or parts of them, depending on what you want to allow API clients to send.

### Validation

#### Request validation

TODO

#### Response validation

TODO

### Included type options

The following type names are available by default and can be used as `type:`/`array_of:`/`page_of:` arguments:

- `'Boolean'` - accepts and renders `true` or `false`
- `'Date'` - accepts and renders dates as unix timestamp integers
- `'DateTime'`, `'Time'` - accepts and renders times as unix timestamp integers
- `'Float'`
- `'Integer'`
- `'NoContentType'` - renders an empty object, for use with `status: :no_content`
- `'String'`
- `'UUID'` - accepts and renders UUIDs

### Enums

`EnumType` can be inherited from to define shared enums:

```ruby
class SeverityEnumType < EnumType
  value 'info'
  value 'warning'
  value 'debacle'
end

class ErrorType < ObjectType
  field :severity, type: 'SeverityEnumType', null: false
end

# inline enums are also possible
# (unlike enum classes, these are not extracted into refs in the OpenAPI export)
class ErrorType < ObjectType
  field :severity, type: 'String', enum: %w[info warning debacle], null: false
end
```

## Not supported yet

- non-JSON content types
- sum types
- mixed enums
- nullable enums
- format specifications
- min/max values
- usage without rails is possible but not convenient yet

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/taro.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
