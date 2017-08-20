# QueryAST parses the GraphQL query into structured AST for the validator
# to use.
#
# The class is strictly concerned about syntax, not semantics. It does ensure
# that various GraphQL semantics are followed such as type correctness,
# valid field names, and valid structure.
#
# Implementation:
#
# This code is written with performance in mind.
#
# To begin, we turn the query string into a char array. We only ever do
# 1 of 2 things to the array: Look at the first element, and shift(pop) the first
# element. This ensures we only actually read the query string once. By using a
# recursive strategy, we can generate an AST by reading the query once from beginning
# to end, one character at a time.
#
# Each method mutates the tokenizer and trims off the elements that it has processed.
#
# Example:
#
# 'query {
#   viewer
#   repository(name: "foo", owner: "bar"){ title }
# }'
#
# =>
#
# {
#   field: "query",
#   arguments: {},
#   body: [{
#     field: "viewer",
#     arguments: {},
#     body: []
#   },
#   {
#     field: "repository",
#     arguments: {name: "foo", owner: "bar"},
#     body: [{
#       field: "title",
#       arguments: {},
#       body: []
#     }]
#   }]
# }
class QueryAST
  class ParseException < Exception; end

  class << self
    def build(tokenizer)
      result = build_node(tokenizer)
    end

    def build_node(tokenizer)
      return {
        field: get_field(tokenizer),
        arguments: get_args(tokenizer),
        body: build_body(tokenizer)
      }
    end

    def get_field(tokenizer)
      token = tokenizer.pop
      validate_token_type(token, :field)

      throw_parse_exception(token, "field") unless (token[:type] == :field)

      token[:string]
    end

    def get_args(tokenizer)
      args = {}
      return args unless (tokenizer.peek[:type] == :left_paren)

      # remove "("
      tokenizer.pop

      while true
        token = tokenizer.pop
        validate_token_type(token, :key)

        # Remove :
        key = token[:string].sub(":", "")

        token = tokenizer.pop
        value = case token[:type]
                when :string
                  token[:string][1..-2] # remove ""
                when :int
                  Integer(token[:string])
                when :float
                  Float(token[:string])
                when :true
                  true
                when :false
                  false
                else
                  raise ParseException, "Expected string, int, float, or boolean, got #{token[:string]}"
                end

        args[key.to_sym] = value

        if tokenizer.peek[:type] == :comma
          tokenizer.pop
        elsif tokenizer.peek[:type] == :right_paren
          tokenizer.pop
          break
        else
          raise ParseException, "Expected comma or right paren, got #{tokenizer[:string]}"
        end
      end

      return args
    end

    def build_body(tokenizer)
      body = []
      return body unless (tokenizer.peek[:type] == :left_brace)

      # remove "{"
      tokenizer.pop

      while true
        body << build_node(tokenizer)
        break if (tokenizer.peek[:type] == :right_brace)
      end

      # remove "}"
      tokenizer.pop

      body
    end

    def validate_token_type(token, expected_type)
      unless token[:type] == expected_type
        raise ParseException, "Expected #{expected_type.to_s} token, got #{token[:string]}"
      end
    end
  end
end
