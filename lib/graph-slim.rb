# frozen_string_literal: true

require 'uri'
require 'faraday'
require 'microsoft_kiota_authentication_oauth'
require 'hashie'

# Microsoft Graph API のクライアントを簡潔に扱うためのクラス
class GraphSlim
  VERSION = '0.1.0'

  class Response < Hashie::Mash
    disable_warnings
  end

  # @param azure_tenant_id [String, nil] Azure tenant ID
  # @param azure_client_id [String, nil] Azure client ID
  # @param azure_client_secret [String, nil] Azure client secre
  # @param options [Hash] オプション
  def initialize(azure_tenant_id = nil, azure_client_id = nil, azure_client_secret = nil, options = {})
    tenant_id = azure_tenant_id || ENV['AZURE_TENANT_ID']
    client_id = azure_client_id || ENV['AZURE_CLIENT_ID']
    client_secret = azure_client_secret || ENV['AZURE_CLIENT_SECRET']

    @context = MicrosoftKiotaAuthenticationOAuth::ClientCredentialContext.new(tenant_id, client_id, client_secret)
    @context.initialize_oauth_provider
    @context.initialize_scopes(['https://graph.microsoft.com/.default'])

    @options = options
  end

  # Microsoft Graph API からリソースを取得する（ページング対応）
  # @param resource [String] 例: '/users'
  # @param query_parameters [Hash] クエリパラメータ
  # @param version [String] APIバージョン（デフォルト: 'v1.0'）
  # @return [Array<Hashie::Mash>]
  def get(resource, query_parameters = {}, version: 'v1.0')
    refresh_access_token!

    unless ["v1.0", "beta"].include?(version)
      raise ArgumentError, "Invalid version: #{version}. Supported versions are 'v1.0' and 'beta'."
    end

    if resource.start_with?('/')
      resource = resource[1..-1] # 先頭のスラッシュを削除
    end

    path = "/#{version}/#{resource}"
    query_parameters.merge!(resolve_query_parameters(path))

    results = []
    next_link = nil

    loop do

      url = next_link.nil? ? path : next_link.sub('https://graph.microsoft.com/', '')

      @last_response = response = connection.get(url) do |request|
        query_parameters.each { |k, v| request.params[k] = v }
        request.headers['Authorization'] = 'Bearer %s' % @access_token.token
        request.headers['Content-Type'] = 'application/json'
      end

      if response.status != 200
        raise response.body.to_s
      end

      results.concat((response.body['value'] || []).map { |v| Response.new(v) })
      unless next_link = response.body['@odata.nextLink']
        break
      end
    end

    results
  end

  attr_reader :last_response

  private

  # クエリパラメータを解決する
  # @param path [String] リクエストパス
  def resolve_query_parameters(path)
    uri = URI.parse(path)
    query_array = URI::decode_www_form(uri.query || '')
    Hash[query_array]
  end

  # Faraday コネクションを返す
  # @return [Faraday::Connection]
  def connection
    @connection ||= Faraday.new('https://graph.microsoft.com/') do |builder|
      builder.adapter :net_http
      builder.response :json
      builder.response :logger if @options[:logger]
    end
  end

  def refresh_access_token!
    return unless @access_token.nil? || @access_token&.expired?

    @access_token = @context.get_token
  end
end
