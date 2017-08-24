require "json"
require_relative "../src/query_validator"

describe "Integration specs" do
  # Use the GitHub schema for integration specs
  subject { QueryValidator.new(JSON.parse(File.read("schema.json"))) }

  context "passing queries" do
    let(:query1) { "query { viewer { login }}" }
    let(:query2) { "query { user(login: \"foo\") { login } }" }
    let(:query3) { "query{viewer{login}}" }
    let(:query4) { "query{viewer{login url issues(first: 5){totalCount}}}" }

    it "suceeds" do
      expect do
        [query1, query2, query3, query4].each do |query|
          subject.validate(query)
        end
      end.to_not raise_exception
    end
  end

  context "failing queries" do
    let(:query1) { "query{}" }
    let(:query2) { "q" }
    let(:query3) { "query {" }
    let(:query4) { "query {}{}" }
    let(:query5) { "query { foo }" }
    let(:query6) { "query { user(login: 5)}" }
    let(:query7) { "query { user(foo: 5)}" }
    let(:query8) { "query {user(login: \"hello\"){}}" }
    let(:query9) { "user" }

    it "raises exception" do
      [query1, query2, query3, query4, query5,
      query6, query7, query8, query9].each do |query|
        expect do
          subject.validate(query)
        end.to raise_exception
        #TODO: Catch specific exception here. Validator needs to wrap all exceptions first
      end
    end
  end
end
