# frozen_string_literal: true

require "faraday"
require "json"

module HuaweiPushKit
  class Client
    PUSH_API_URI = "https://push-api.cloud.huawei.com"
    OAUTH_URI = "https://oauth-login.cloud.huawei.com"
    CONTENT_JSON = "application/json"
    CONTENT_URL_ENCODED = "application/x-www-form-urlencoded"

    def initialize(client_id = ENV.fetch("HUAWEI_PUSH_KIT_CLIENT_ID"), client_secret = ENV.fetch("HUAWEI_PUSH_KIT_CLIENT_SECRET"))
      @client_id = client_id
      @client_secret = client_secret
    end

    def send_push_notification(device_token, title, body, type = nil, badge = nil, post_id = nil, comment_id = nil,
      chat_id = nil, avatar = nil)
      response = push_api_connection.post("/v1/#{client_id}/messages:send") do |req|
        req.body = build_notification_body(device_token, title, body, type, badge, post_id, comment_id, chat_id, avatar)
      end

      ApiResponse.new(response)
    end

    def send_push_notification_to_topic(topic_name, title, body, type = nil, badge = nil, post_id = nil,
      comment_id = nil, chat_id = nil, avatar = nil)
      response = push_api_connection.post("/v1/#{client_id}/messages:send") do |req|
        req.body = build_topic_notification_body(topic_name, title, body, type, badge, post_id, comment_id, chat_id,
          avatar)
      end

      ApiResponse.new(response)
    end

    def subscribe_to_topic(topic_name, device_tokens)
      response = push_api_connection.post("/v1/#{client_id}/topic:subscribe") do |req|
        req.body = { topic: topic_name, tokenArray: Array(device_tokens) }.to_json
      end

      ApiResponse.new(response)
    end

    def unsubscribe_from_topic(topic_name, device_tokens)
      response = push_api_connection.post("/v1/#{client_id}/topic:unsubscribe") do |req|
        req.body = { topic: topic_name, tokenArray: Array(device_tokens) }.to_json
      end

      ApiResponse.new(response)
    end

    def topic_list(device_token)
      response = push_api_connection.post("/v1/#{client_id}/topic:list") do |req|
        req.body = { token: device_token }.to_json
      end

      ApiResponse.new(response)
    end

    private

    attr_reader :client_id, :client_secret

    def build_topic_notification_body(topic_name, title, text, type = nil, badge = nil, post_id = nil,
      comment_id = nil, chat_id = nil, avatar = nil)
      {
        validate_only: false,
        message: {
          data: {
                  title:,
                  message: text,
                  type:,
                  badge:,
                  post_id:,
                  comment_id:,
                  chat_id:,
                  avatar:
                }.to_json,
          topic: topic_name
        }
      }.to_json
    end

    def build_notification_body(device_token, title, text, type = nil, badge = nil, post_id = nil, comment_id = nil,
      chat_id = nil, avatar = nil)
      {
        validate_only: false,
        message: {
          data: {
                  title:,
                  message: text,
                  type:,
                  badge:,
                  post_id:,
                  comment_id:,
                  chat_id:,
                  avatar:
                }.to_json,
          token: [
            device_token
          ]
        }
      }.to_json
    end

    def access_token
      response = oauth_connection.post("/oauth2/v3/token") do |req|
        req.body = URI.encode_www_form({
          grant_type: "client_credentials",
          client_id:,
          client_secret:
        })
      end

      JSON.parse(response.body)["access_token"]
    end

    def push_api_connection
      Faraday.new(PUSH_API_URI) do |faraday|
        setup_connection(faraday, CONTENT_JSON, "Bearer #{access_token}")
      end
    end

    def oauth_connection
      Faraday.new(OAUTH_URI) do |faraday|
        setup_connection(faraday, CONTENT_URL_ENCODED)
      end
    end

    def setup_connection(faraday, content_type, authorization = nil)
      faraday.headers["Content-Type"] = content_type
      faraday.headers["Authorization"] = authorization if authorization
      faraday.response :raise_error
      faraday.adapter Faraday.default_adapter
    end
  end
end
