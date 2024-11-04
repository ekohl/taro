module Taro::Types::Shared::ObjectCoercion
  def coerce_input
    coerce_with_fields(true)
  end

  def coerce_response
    coerce_with_fields(false)
  end

  def coerce_with_fields(from_input)
    from_hash = object.is_a?(Hash)
    self.class.fields.to_h do |name, field|
      [name, field.extract_value(object, context: self, from_input:, from_hash:)]
    end
  end
end
