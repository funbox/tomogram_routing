Absorbed https://github.com/funbox/tomograph

# TomogramRouting

From json file with the structure Tomogram api creates an object and adding methods to fast search requests and responses with json-schemes.

## Install
```
gem 'tomogram_routing'
```

```
require 'tomogram_routing'
```

## Using
```ruby
tomogram = TomogramRouting::Tomogram.craft(tomogram.json)
```

### find_request
```ruby
expect_request = tomogram.find_request(method:, path:)
```

### find_find_responses
```ruby
expect_responses = expect_request.find_responses(status:)
```
