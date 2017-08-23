require_relative '../../contexts/context'
require_relative '../../contexts/type_context'

describe "TypeContext" do
  subject { TypeContext.new("query") }

  let(:schema) do
    {
      query_type: "query",
      mutation_type: "mutation",
      types: {
        "query" => {
          kind: "OBJECT",
          fields: {
            "test" => {
              type: {
                non_null: false,
                list: false,
                kind: "SCALAR",
                name: "Int"
              },
              args: {
                "integer" => {
                  default: nil,
                  type: {
                    non_null: false,
                    list: false,
                    kind: "SCALAR",
                    name: "Int"
                  }
                }
              }
            },
            "innerquery" => {
              type: {
                non_null: false,
                list: false,
                kind: "OBJECT",
                name: "query"
              },
              args: {}
            }
          }
        }
      }
    }
  end

  describe "#validate_field_present" do
    context "when field is present" do
      it "does not throw an exception" do
        expect do
          subject.validate_field_present("test", schema)
        end.to_not raise_exception
      end
    end

    context "when field does not exist" do
      it "raises exception" do
        expect do
          subject.validate_field_present("Foo", schema)
        end.to raise_exception(Context::ValidationException)
      end
    end
  end

  describe "#validate_field_arg" do
    context "arg does not exist" do
      it "raises an exception" do
        expect do
          subject.validate_field_arg("test", "k", "v", schema)
        end.to raise_exception(Context::ValidationException)
      end
    end

    context "incorrect type for arg" do
      it "raises an exception" do
        expect do
          subject.validate_field_arg("test", "integer", "not an int", schema)
        end.to raise_exception(Context::ValidationException)
      end
    end

    context "correct type for arg" do
      it "does not raise an exception" do
        expect do
          subject.validate_field_arg("test", "integer", 3, schema)
        end.to_not raise_exception
      end
    end
  end

  describe "#get_context_for_field" do
    context "field is a scalar" do
      it "returns nil" do
        expect(subject.get_context_for_field("test", schema)).to be_nil
      end
    end

    context "field is an object" do
      it "returns a type context with correct type" do
        res = subject.get_context_for_field("innerquery", schema)

        expect(res.class).to eq(TypeContext)
        expect(res.name).to eq("Type Context (query)")
      end
    end
  end
end
