# The schema is defined as an array of types which makes
# type lookup by name super inefficient.
# This class creates a more efficient data structure for this info.

# For each type we care about:
#  It's name (IMPORTANT)
#  It's kind
#  It's fields
#    It's name
#    It's args
#      It's name
#      It's type
#      It's default value
#    It's type
#  (soon) Interfaces
#  (soon) inputFields
#  (soon) Enum options (IF ENUM)
#  (soon) Possible types (IF UNION)

class Schema
  attr_reader :schema

  def initialize(raw_schema)
    @schema = build_schema(raw_schema["data"]["__schema"])
  end

  private

  def build_schema(json_schema)
    schema = { types: {} }
    set_root_types(json_schema, schema)

    schema_types = json_schema["types"]
    schema_types.each do |type|
      process_type(type, schema)
    end

    schema
  end

  def process_type(type, schema)
    name = type["name"]
    kind = type["kind"]
    fields = {}

    (type["fields"] || []).each do |field|
      process_field(field, fields)
    end

    schema[:types][name] = {
      kind: kind,
      fields: fields
    }
  end

  def process_field(field, type_fields)
    name = field["name"]
    args = {}
    type = {}

    field["args"].each do |arg|
      process_field_arg(arg, args)
    end

    type = process_field_type(field["type"])

    type_fields[name] = {
      args: args,
      type: type
    }
  end

  def process_field_arg(arg, field_args)
    name = arg["name"]
    default = arg["defaultValue"]
    type = process_field_type(arg["type"])

    field_args[name] = {
      default: default,
      type: type
    }
  end

  def process_field_type(type)
    non_null = false
    list = false
    type_kind = nil
    type_name = ""

    loop do
      if type["kind"] == "NON_NULL"
        non_null = true
      elsif type["kind"] == "LIST"
        list = true
      elsif type["kind"] && type["name"]
        type_kind = type["kind"]
        type_name = type["name"]
      else
        puts "WHAT THE FUCK HAPPENED"
        exit 1
      end

      break unless type = type["ofType"]
    end

    {
      non_null: non_null,
      list: list,
      type_kind: type_kind,
      type_name: type_name
    }
  end

  def set_root_types(json_schema, schema)
    schema[:query_type]    = json_schema["queryType"]["name"]
    schema[:mutation_type] = json_schema["mutationType"]["name"]
  end
end
