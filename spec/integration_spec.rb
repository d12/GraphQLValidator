require "json"
require_relative "../src/query_validator"

describe "Integration specs" do
  # Use the GitHub schema for integration specs
  subject { QueryValidator.new(JSON.parse(File.read("schema.json"))) }

  context "passing queries" do
    @queries = [
      "query { viewer { login }}",
      "query { user(login: \"foo\") { login } }",
      "query{viewer{login}}",
      "query{viewer{login url issues(first: 5){totalCount}}}"
    ]

    @queries.each do |query|
      context "query: \"#{query}\"" do
        it "succeeds" do
          expect do
            subject.validate(query)
          end.to_not raise_exception
        end
      end
    end
  end

  context "failing queries" do
    @queries = [
      "query{}",
      "q",
      "query {",
      "query {}{}",
      "query { foo }",
      "query { user(login: 5)}",
      "query { user(foo: 5)}",
      "query {user(login: \"hello\"){}}",
      "user",
      "query { viewer }",
      "query"
    ]

    @queries.each do |query|
      context "query: \"#{query}\"" do
        it "raises exception" do
          expect do
            subject.validate(query)
          end.to raise_exception
          #TODO: Catch specific exception here. Validator needs to wrap all exceptions first
        end
      end
    end
  end
end
