# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'graph-slim'
  spec.version       = '0.1.0'
  spec.authors       = ['hito@pepabo.com']
  spec.email         = ['hito@pepabo.com']

  spec.bindir        = "bin"
  spec.executables   = Dir.children("bin").reject { |f| File.directory?(f) }

  spec.summary       = 'Microsoft Graph API のクライアント'
  spec.description   = 'Microsoft Graph API のクライアントを薄く扱うための RubyGem'
  spec.homepage      = 'https://github.com/hiboma/graph-slim'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday'
  spec.add_dependency 'microsoft_kiota_authentication_oauth'

  spec.required_ruby_version = '>= 3.0'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
