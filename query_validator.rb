require './contexts/context'
require './contexts/query_root_context'
require './contexts/root_context'
require './query_dsl'

class QueryValidator
  class << self
    def validate(schema, query)
      @schema = schema
      parsed_DSL = QueryDSL.build(query)
    end

    def validate_layer(query, context:)
    end
  end
end
