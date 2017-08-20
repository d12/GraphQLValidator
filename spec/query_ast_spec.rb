require_relative '../query_ast.rb'
require_relative '../query_tokenizer.rb'

describe "QueryAST" do
  subject { QueryAST }

  describe "#build" do
    context "simple, no args, no bodies" do
      let(:query) { "query" }
      let(:tokenizer) { QueryTokenizer.new(query) }

      it "generates correct AST" do
        expect(subject.build(tokenizer)).to eq({
          field: "query",
          arguments: {},
          body: []
        })
      end
    end

    context "has a field with a body" do
      let(:query) { "query { viewer }" }
      let(:tokenizer) { QueryTokenizer.new(query) }

      it "generates correct AST" do
        expect(subject.build(tokenizer)).to eq({
          field: "query",
          arguments: {},
          body: [{
            field: "viewer",
            arguments: {},
            body: []
          }]
        })
      end
    end

    context "has multiple fields" do
      let(:query) { "query { viewer foo }" }
      let(:tokenizer) { QueryTokenizer.new(query) }

      it "generates correct AST" do
        expect(subject.build(tokenizer)).to eq({
          field: "query",
          arguments: {},
          body: [{
            field: "viewer",
            arguments: {},
            body: []
          },
          {
            field: "foo",
            arguments: {},
            body: []
          }]
        })
      end
    end

    context "has arguments" do
      context "string arguments" do
        let(:query) { "query { user(name: \"John\") }" }
        let(:tokenizer) { QueryTokenizer.new(query) }

        it "generates correct AST" do
          expect(subject.build(tokenizer)).to eq({
            field: "query",
            arguments: {},
            body: [{
              field: "user",
              arguments: {name: "John"},
              body: []
            }]
          })
        end
      end

      context "integer arguments" do
        let(:query) { "query { user(name: 2) }" }
        let(:tokenizer) { QueryTokenizer.new(query) }

        it "generates correct AST" do
          expect(subject.build(tokenizer)).to eq({
            field: "query",
            arguments: {},
            body: [{
              field: "user",
              arguments: {name: 2},
              body: []
            }]
          })
        end
      end

      context "float arguments" do
        let(:query) { "query { user(name: 2.5) }" }
        let(:tokenizer) { QueryTokenizer.new(query) }

        it "generates correct AST" do
          expect(subject.build(tokenizer)).to eq({
            field: "query",
            arguments: {},
            body: [{
              field: "user",
              arguments: {name: 2.5},
              body: []
            }]
          })
        end
      end
    end
  end
end
