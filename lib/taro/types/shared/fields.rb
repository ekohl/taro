# Adds the `::field` method to object and input types.
module Taro::Types::Shared::Fields
  # Fields are defined using blocks. These blocks are evaluated lazily
  # to allow for circular or recursive type references, and to
  # avoid unnecessary eager loading of all types in dev/test envs.
  def field(name, **kwargs)
    defined_at = caller_locations(1..1)[0].then { "#{_1.path}:#{_1.lineno}" }
    validate_field_args(name, defined_at:, **kwargs)

    prev = field_defs[name]
    prev && raise(Taro::ArgumentError, "field #{name} already defined at #{prev[:defined_at]}")

    field_defs[name] = { name:, defined_at:, **kwargs }
  end

  def fields
    @fields ||= evaluate_field_defs
  end

  private

  def validate_field_args(name, defined_at:, **kwargs)
    name.is_a?(Symbol) ||
      raise(Taro::ArgumentError, "field name must be a Symbol, got #{name.class} at #{defined_at}")

    [true, false].include?(kwargs[:null]) ||
      raise(Taro::ArgumentError, "null has to be specified as true or false for field #{name} at #{defined_at}")

    (type_keys = (kwargs.keys & TYPE_KEYS)).size == 1 ||
      raise(Taro::ArgumentError, "exactly one of type, array_of, or page_of must be given for field #{name} at #{defined_at}")

    kwargs[type_keys.first].class == String ||
      raise(Taro::ArgumentError, "#{type_key} must be a String for field #{name} at #{defined_at}")
  end

  TYPE_KEYS = %i[type array_of page_of].freeze

  def field_defs
    @field_defs ||= {}
  end

  def evaluate_field_defs
    field_defs.transform_values do |field_def|
      type = Taro::Types::CoerceToType.call(field_def)
      Taro::Types::Field.new(**field_def.except(*TYPE_KEYS), type:)
    end
  end

  def inherited(subclass)
    subclass.instance_variable_set(:@field_defs, field_defs.dup)
    super
  end
end
