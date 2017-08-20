require_relative "../query_tokenizer"

describe "Query Tokenizer" do
  subject { QueryTokenizer }

  context "token correctness" do
    context "integer" do
      let(:tokenizer) { subject.new("100") }

      it "creates correct token" do
        expect(tokenizer.peek).to eq({ type: :int, string: "100"})
      end
    end

    context "float" do
      let(:tokenizer) { subject.new("12.34") }

      it "creates correct token" do
        expect(tokenizer.peek).to eq({ type: :float, string: "12.34"})
      end
    end

    context "bool" do
      let(:tokenizer) { subject.new("true false") }

      it "creates correct token" do
        expect(tokenizer.pop).to eq({ type: :bool, string: "true"})
        expect(tokenizer.pop).to eq({ type: :bool, string: "false"})
      end
    end

    context "string" do
      let(:tokenizer) { subject.new("\"hello\"") }

      it "creates correct token" do
        expect(tokenizer.pop).to eq({ type: :string, string: "\"hello\""})
      end
    end

    context "key" do
      let(:tokenizer) { subject.new("foo: bar") }

      it "creates correct token" do
        expect(tokenizer.pop).to eq({ type: :key, string: "foo:"})
      end
    end

    context "field" do
      let(:tokenizer) { subject.new("foo") }

      it "creates correct token" do
        expect(tokenizer.pop).to eq({ type: :field, string: "foo"})
      end
    end

    context "empty stream" do
      let(:tokenizer) { subject.new("") }

      it "returns nil" do
        expect(tokenizer.pop).to be_nil
      end
    end

    context "left brace" do
      context "all alone" do
        let(:tokenizer) { subject.new("{") }

        it "creates correct token" do
          expect(tokenizer.peek).to eq({ type: :left_brace, string: "{" })
        end
      end

      context "against another character" do
        let(:tokenizer) { subject.new("foo{") }

        it "creates correct token" do
          tokenizer.pop # remove the foo
          expect(tokenizer.peek).to eq({ type: :left_brace, string: "{" })
        end
      end
    end

    context "right brace" do
      context "all alone" do
        let(:tokenizer) { subject.new("}") }

        it "creates correct token" do
          expect(tokenizer.peek).to eq({ type: :right_brace, string: "}" })
        end
      end

      context "against another character" do
        let(:tokenizer) { subject.new("foo}") }

        it "creates correct token" do
          tokenizer.pop # remove the foo
          expect(tokenizer.peek).to eq({ type: :right_brace, string: "}" })
        end
      end
    end

    context "left paren" do
      context "all alone" do
        let(:tokenizer) { subject.new("(") }

        it "creates correct token" do
          expect(tokenizer.peek).to eq({ type: :left_paren, string: "(" })
        end
      end

      context "against another character" do
        let(:tokenizer) { subject.new("(foo") }

        it "creates correct token" do
          expect(tokenizer.peek).to eq({ type: :left_paren, string: "(" })
        end
      end
    end

    context "right paren" do
      context "all alone" do
        let(:tokenizer) { subject.new(")") }

        it "creates correct token" do
          expect(tokenizer.peek).to eq({ type: :right_paren, string: ")" })
        end
      end

      context "against another character" do
        let(:tokenizer) { subject.new("foo)") }

        it "creates correct token" do
          tokenizer.pop # remove the foo
          expect(tokenizer.peek).to eq({ type: :right_paren, string: ")" })
        end
      end
    end

    context 'comma' do
      context "all alone" do
        let(:tokenizer) { subject.new(",") }

        it "creates correct token" do
          expect(tokenizer.peek).to eq({ type: :comma, string: "," })
        end
      end

      context "against another character" do
        let(:tokenizer) { subject.new(",foo: 5") }

        it "creates correct token" do
          expect(tokenizer.peek).to eq({ type: :comma, string: "," })
        end
      end
    end
  end

  describe "pop" do
    let(:query) { "foo bar" }
    let(:tokenizer) { subject.new(query) }

    it "pops the token" do
      token_a = tokenizer.pop
      token_b = tokenizer.pop

      expect(token_a).to_not eq(token_b)
    end
  end

  describe "peek" do
    let(:query) { "foo bar" }
    let(:tokenizer) { subject.new(query) }

    it "does not pop the token" do
      token_a = tokenizer.peek
      token_b = tokenizer.peek

      expect(token_a).to eq(token_b)
    end
  end
end
