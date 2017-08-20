require './contexts/context'
require './contexts/query_root_context'
require './contexts/root_context'
require './query_ast'

class QueryValidator
  class << self
    def validate(schema, query)
      @schema = schema
      tokenizer = QueryTokenizer.new(query)
      ast = QueryAST.build(tokenizer)
    end

    def validate_layer(query, context:)

    end
  end
end
