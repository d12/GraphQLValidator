class RootContext < Context
  def name
    "Root Context"
  end

  def validate_field_present(field_name, schema)
    types = ["queryType", "mutationType", "subscriptionType"]

    valid_fields = types.map do |type|
      if schema[type]
        schema[type]["name"].downcase
      end
    end

    unless valid_fields.include? field_name.downcase
      raise Context::ValidationException, "#{field_name.downcase} is not a valid field on the root"
    end
  end

  # Haven't implemented mutation or subscription yet
  # doesn't support variables yet
  def validate_field_arg(field, key, value, schema)
    raise Context::ValidationException, "Noo!"
  end

  def get_context_for_field(field, schema)
    case field.downcase
    when "query"
      QueryContext.new
    else
      raise Context::ValidationException, "Failed to find context for field: #{field}"
    end
  end
end
