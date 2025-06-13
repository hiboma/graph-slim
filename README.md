# graph-slim

A simple Ruby client for Microsoft Graph API.

## Overview

`graph-slim` is a Ruby client for Microsoft Graph API, supporting authentication and automatic paging.

## Installation

```sh
gem install graph-slim
```

Or add to your Gemfile:

```ruby
gem 'graph-slim'
```

## Usage

```ruby
require 'graph_slim'

graph = GraphSlim.new(
  ENV['AZURE_TENANT_ID'],
  ENV['AZURE_CLIENT_ID'],
  ENV['AZURE_CLIENT_SECRET']
)

# Fetch all users (auto-paging supported)
users = graph.get('/users')
users.each do |user|
  puts user.displayName
end
```

### Paging

The `get` method automatically follows Microsoft Graph API's `@odata.nextLink` for paging.

## Environment Variables

- `AZURE_TENANT_ID`
- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`

If arguments are omitted, these environment variables are used.

## Testing

```sh
bundle install
bundle exec rspec
```

## License

MIT

## Author

hito [at] pepabo.com