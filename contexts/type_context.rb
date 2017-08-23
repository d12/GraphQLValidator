class TypeContext < Context
  def initialize(type)
    @type = type
  end

  def name
    "Type Context (#{@type})"
  end

  def validate_field_present(field_name, schema)
    unless get_field(field_name, schema)
      raise Context::ValidationException, "#{field_name} not present on #{@type}"
    end
  end

  # TODO: Validate arg is correct type
  def validate_field_arg(field, key, value, schema)
    field = get_field(field, schema)
    arg = field[:args][key.to_s]

    unless arg
      raise Context::ValidationException, "#{key} argument does not exist on the #{field} field of #{@type}"
    end

    validate_field_arg_type(key, value, arg[:type][:name])
  end

  def validate_field_arg_type(key, value, expected_type)
    correct_type = case expected_type
                   when "String"
                     value.is_a? String
                   when "Int"
                     value.is_a? Integer
                   when "Float"
                     (value.is_a? Integer) || (value.is_a? Float)
                   when "ID"
                     value.is_a? String
                   end

    unless correct_type
      raise Context::ValidationException, "Expected #{expected_type} type arg for #{key}, got #{value.class} (#{value})"
    end
  end

  # TODO: Support  interfaces
  def get_context_for_field(field, schema)
    schema_field = get_field(field, schema)
    name = schema_field[:type][:name]
    kind = schema_field[:type][:kind]

    if(kind == "OBJECT" || kind == "LIST")
      TypeContext.new(name)
    elsif(kind == "SCALAR")
      nil
    else
      raise Context::ValidationException, "Unsupported kind: #{kind}"
    end
  end

  private

  def get_field(field_name, schema)
    schema[:types][@type][:fields][field_name]
  end
end
