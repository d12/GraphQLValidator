require_relative 'contexts/context'
require_relative 'contexts/root_context'
require_relative 'schema'
require_relative 'query_tokenizer'
require_relative 'query_ast'

class QueryValidator
  class ValidationException < Exception; end

  def initialize(schema)
    @schema = Schema.new(schema)
  end

  def validate(query)
    tokenizer = QueryTokenizer.new(query)
    ast = QueryAST.build(tokenizer)

    validate_node(ast, RootContext.new)
  end

  private

  def validate_node(ast, parent_context)
    parent_context.validate_field_present(ast[:field], @schema)

    ast[:arguments].each do |key, value|
      parent_context.validate_field_arg(ast[:field], key, value, @schema)
    end

    ast_context = parent_context.get_context_for_field(ast[:field], @schema) || return

    if ast[:body].empty?
      raise Context::ValidationException, "Object \"#{@type} must have selections"
    else
      ast[:body].each do |child_ast|
        validate_node(child_ast, ast_context)
      end
    end
  end
end
