#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'graph-slim'

path = ARGV[0] || '/me'

if path.empty?
  puts "Usage: #{__FILE__} <path>"
  puts "Example: #{__FILE__} /me"
  exit 1
end

client = GraphSlim.new

begin
  response = client.get(path)
  puts response.to_json
rescue => e
  pp e
  puts client.last_response.body
  exit 1
end
