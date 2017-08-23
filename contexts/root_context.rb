require_relative 'type_context'

class RootContext < Context
  def name
    "Root Context"
  end

  def validate_field_present(field_name, schema)
    valid_fields = [schema[:query_type], schema[:mutation_type]].map(&:downcase)

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
      ::TypeContext.new(schema[:query_type])
    else
      raise Context::ValidationException, "Failed to find context for field: #{field}"
    end
  end
end
