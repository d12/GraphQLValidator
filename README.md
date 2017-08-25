# GraphQLValidator

This validator checks the format and type-correctness of a GraphQL query, given a JSON schema.

It ensures:
1. No syntax errors
2. Fields exist in the context they're used in
3. Field args exist and are given the correct type
4. All objects have selections
5. There are no naming conflicts (TODO)

## Example

```Ruby
schema = JSON.parse(File.read("schema.json"))
query = "
  query {
    viewer {
      repositories(first: 5) {
        totalCount
        bar
      }
    }
  }
"

validator = QueryValidator.new(schema)
validator.validate(query)
```
```
=> bar not present on RepositoryConnection (Context::ValidationException)
```

## Performance

Generating a schema and validating a 29 line query gives this benchmark:

```
                    user     system      total        real
Creating validator  0.010000   0.000000   0.010000 (  0.007621)
Validating a query  0.000000   0.000000   0.000000 (  0.000593)
```

[Script used to create benchmark](https://gist.github.com/nwoodthorpe/f9885a78f837bf96eed274e2ff81ebac)

## TODO

 - Everything in the issues list
 - Possibly redo the parser with Biston/LALR instead of implementing my own tokenization/parsing from scratch
 - Make this into an actual useful thing (A packaged gem with a proper interface?)
