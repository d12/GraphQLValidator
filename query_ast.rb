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
# Each method mutates query_arr and trims off the elements that it has processed.
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
require './constants'
include Constants

class QueryAST
  class ParseException < Exception; end

  class << self
    def build(query)
      result = build_node(query.chars)
    end

    def build_node(query_arr)
      return {
        field: extract_label(query_arr),
        arguments: extract_args(query_arr),
        body: build_body(query_arr)
      }
    end

    def extract_label(query_arr)
      trim_whitespace(query_arr)

      field = ""
      while is_alpha?(query_arr.first)
        field << query_arr.shift
      end

      raise ParseException, "Empty label" if field.empty?

      field
    end

    def extract_args(query_arr)
      trim_whitespace(query_arr)

      args = {}
      return args unless query_arr.first == "("

      # remove "("
      query_arr.shift

      while true
        key = ""
        while is_alpha?(query_arr.first)
            key << query_arr.shift
        end

        unless query_arr.first == ":"
          raise ParseException, "Malformed argument, missing :"
        end
        query_arr.shift
        trim_whitespace(query_arr)

        #TODO: implement boolean args

        value = ""
        if(query_arr.first == "\"")
          # String value
          query_arr.shift

          while query_arr.first != "\""
            value << query_arr.shift
          end

          query_arr.shift
        elsif(is_numeric?(query_arr.first))
          begin
            value << query_arr.shift
          end while is_numeric?(query_arr.first) || query_arr.first == "."

          begin
            if value.include? "."
              value = Float(value)
            else
              value = Integer(value)
            end
          rescue ArgumentError
            raise ParseException "Malformed argument, invalid float: #{value}"
          end
        end

        args[key.to_sym] = value

        trim_whitespace(query_arr)

        if query_arr.first == ","
          query_arr.shift
        elsif query_arr.first == ")"
          break
        else
          raise ParseException, "Malformed argument"
        end
        trim_whitespace(query_arr)
      end

      # remove ")"
      query_arr.shift

      return args
    end

    def build_body(query_arr)
      trim_whitespace(query_arr)

      body = []
      return body unless query_arr.first == "{"

      # remove "{"
      query_arr.shift

      while true
        body << build_node(query_arr)
        trim_whitespace(query_arr)
        break if query_arr.first == "}"
      end

      # remove "}"
      query_arr.shift

      body
    end

    def is_alpha?(char)
      return unless char

      ord = char.ord
      (ord >= BIG_A_ORD && ord <= BIG_Z_ORD) || (ord >= LITTLE_A_ORD && ord <= LITTLE_Z_ORD)
    end

    def is_numeric?(char)
      return unless char

      ord = char.ord
      (ord >= ZERO_ORD && ord <= NINE_ORD)
    end

    def is_whitespace?(char)
      return unless char

      ord = char.ord
      ord == NEWLINE_ORD || # newline
        ord == SPACE_ORD  # space
    end

    def trim_whitespace(query_arr)
      while is_whitespace?(query_arr.first)
        query_arr.shift
      end
    end
  end
end
