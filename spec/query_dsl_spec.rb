require_relative '../query_dsl.rb'

describe "QueryDSL" do
  subject { QueryDSL }

  describe "#build" do
    context "simple, no args, no bodies" do
      let(:query) { "query" }

      it "generates correct DSL" do
        expect(subject.build(query)).to eq({
          field: "query",
          arguments: {},
          body: []
        })
      end
    end

    context "has a field with a body" do
      let(:query) { "query { viewer }" }

      it "generates correct DSL" do
        expect(subject.build(query)).to eq({
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

      it "generates correct DSL" do
        expect(subject.build(query)).to eq({
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

        it "generates correct DSL" do
          expect(subject.build(query)).to eq({
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

        it "generates correct DSL" do
          expect(subject.build(query)).to eq({
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

        it "generates correct DSL" do
          expect(subject.build(query)).to eq({
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
