# GraphQLValidator

This validator checks the format and type-correctness of a GraphQL query, given a JSON schema.

It ensures:
1. No syntax errors
2. Fields exist in the context they're used in
3. Field args exist and are given the correct type
4. All paths terminate with scalars (TODO)
5. There are no naming conflicts (TODO)

## Example

```Ruby
schema = Schema.new(JSON.parse(File.read("schema.json")))

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

QueryValidator.validate(schema, query)
```
```
=> bar not present on RepositoryConnection (Context::ValidationException)
```

## Performance

Generating a schema and validating a 29 line query gives this benchmark:

```
       user     system      total        real
Generating schema  0.030000   0.000000   0.030000 (  0.036233)
Validating query  0.000000   0.000000   0.000000 (  0.000569)
```

[Script used to create benchmark](https://gist.github.com/nwoodthorpe/f5e426f85f8a3bdf40ff992c46a9cd88)

## TODO

 - Everything in the issues list
 - Possibly redo the parser with Biston/LALR instead of implementing my own tokenization/parsing from scratch
 - Make this into an actual useful thing (A packaged gem with a proper interface?)
