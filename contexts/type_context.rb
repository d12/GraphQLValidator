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
