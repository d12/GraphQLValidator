require './contexts/context'
require './contexts/query_root_context'
require './contexts/root_context'
require './query_ast'

class QueryValidator
  class << self
    def validate(schema, query)
      @schema = schema
      ast = QueryAST.build(query)
    end

    def validate_layer(query, context:)

    end
  end
end
