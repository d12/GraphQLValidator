class TypeContext < Context
  def initialize(type)
    @type = type
  end

  def name
    "Type Context (#{@type})"
  end

  def validate_field_present(field_name, schema)

  end

  def validate_field_arg(field, key, value, schema)

  end

  def get_context_for_field(field, schema)

  end
end
