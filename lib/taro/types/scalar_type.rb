# Abstract base class for scalar types, i.e. types without fields.
class Taro::Types::ScalarType < Taro::Types::BaseType
end

module Taro::Types::Scalar
  Dir[File.join(__dir__, 'scalar', '**', '*.rb')].each { |f| require f }
end
