require_relative '../../src/contexts/root_context'

describe "RootContext" do
  subject { RootContext.new }

  let(:schema) do
    {
      query_type: "query",
      mutation_type: "mutation"
    }
  end

  describe "#validate_field_present" do
    context "when values are valid" do
      it "does not throw an exception" do
        expect do
          subject.validate_field_present(schema[:query_type], schema)
          subject.validate_field_present(schema[:mutation_type], schema)
        end.to_not raise_exception
      end

      it "does not depend on capitalization" do
        expect do
          subject.validate_field_present(schema[:query_type].upcase, schema)
        end.to_not raise_exception
      end
    end

    context "when values are invalid" do
      it "raises exception" do
        expect do
          subject.validate_field_present("Foo", schema)
        end.to raise_exception(Context::ValidationException)
      end
    end
  end

  describe "#validate_field_arg" do
    it "fails" do
      expect do
        subject.validate_field_arg(1, 2, 3, schema)
      end.to raise_exception Context::ValidationException
    end
  end

  describe "#get_context_for_field" do
    context "when valid field" do
      it "returns a TypeContext" do
        result = subject.get_context_for_field("query", schema)
        expect(result.class).to eq(TypeContext)
        expect(result.name).to eq("Type Context (query)")
      end
    end

    context "when an invalid field" do
      it "raises an exception" do
        expect do
          subject.get_context_for_field("potato", schema)
        end.to raise_exception(Context::ValidationException)
      end
    end
  end
end
