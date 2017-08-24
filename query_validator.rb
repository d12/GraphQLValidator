require './contexts/context'
require './contexts/root_context'
require './query_tokenizer'
require './query_ast'

class QueryValidator
  class ValidationException < Exception; end

  class << self
    def validate(schema, query)
      @schema = schema
      tokenizer = QueryTokenizer.new(query)
      ast = QueryAST.build(tokenizer)

      validate_node(ast, RootContext.new)
    end

    def validate_node(ast, parent_context)
      # first, check if field is valid in parent context
      # then check if args are valid
      # then recursively validate body nodes
      parent_context.validate_field_present(ast[:field], @schema)

      ast[:arguments].each do |key, value|
        parent_context.validate_field_arg(ast[:field], key, value, @schema)
      end

      ast_context = parent_context.get_context_for_field(ast[:field], @schema) || return

      ast[:body].each do |child_ast|
        validate_node(child_ast, ast_context)
      end
    end
  end
end
