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
```
tomogram = TomogramRouting::Tomogram.craft(tomogram.json)
```

### find_request
```
expect_request = tomogram.find_request(method:, path:)
```

### find_find_responses
```
expect_responses = expect_request.find_responses(status:)
```
