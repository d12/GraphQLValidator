class QueryTokenizer
  def initialize(query)
    @query = query.chars
    set_next_token
  end

  # Get next token, without removing from stream
  def peek
    @next_token
  end

  # Pop next token
  def pop
    token = @next_token
    set_next_token if token

    token
  end

  private

  # Read @query to set @next_token
  def set_next_token
    next_token_string = extract_token_string_from_query
    @next_token = tokenize_string(next_token_string)
  end

  def extract_token_string_from_query
    trim_leading_whitespace

    token_string = ""
    while true
      next_char = @query.first || break

      if is_brace_or_bracket_or_comma?(next_char)
        if token_string.length == 0
          token_string << @query.shift
        end

        break
      else
        if !is_whitespace?(@query.first)
          token_string << @query.shift
        else
          break
        end
      end
    end

    token_string
  end

  def tokenize_string(next_token_string)
    token = case next_token_string
    when '{'
      :left_brace
    when '}'
      :right_brace
    when '('
      :left_paren
    when ')'
      :right_paren
    when ','
      :comma
    when /\A[[:digit:]]+\z/
      :int
    when /\A[[:digit:]]+\.[[:digit:]]+\z/
      :float
    when 'true'
      :true
    when 'false'
      :false
    when /\A".*"\z/
      :string
    when /\A.+:\z/
      :key
    when ''
      next_token_string = "END OF STREAM"
      :empty
    else
      :field
    end

    { type: token, string: next_token_string }
  end

  def trim_leading_whitespace
    while is_whitespace?(@query.first)
      @query.shift
    end
  end

  def is_whitespace?(char)
    char == "\n" || char == " "
  end

  def is_brace_or_bracket_or_comma?(char)
    char == "{" || char == "}" || char == "(" || char == ")" || char == ","
  end
end
