# frozen_string_literal: true
module Api
  class InteractionsController < ApplicationController
    require 'openssl'
    require 'base64'
    require 'ed25519'

    # Disable CSRF protection for this endpoint
    skip_before_action :verify_authenticity_token

    def receive
      # Verify the request is from Discord
      if valid_signature?(request)
        interaction = JSON.parse(request.body.read)
        case interaction['type']
        when 1 # PING
          render json: { type: 1 } # PONG
        when 2 # APPLICATION_COMMAND
          handle_application_command(interaction)
        when 3 # MESSAGE_COMPONENT
          handle_message_component(interaction)
        when 5 # MODAL_SUBMIT
          handle_modal_submit(interaction)
        else
          head :bad_request
        end
      else
        head :unauthorized
      end
    end

    private

    def handle_application_command(interaction)
      case interaction['data']['name']
      when 'hello'
        user_name = interaction['member']['user']['username']
        render json: {
          type: 4, # ChannelMessageWithSource
          data: {
            content: "Hello, #{user_name}!"
          }
        }
      else
        render json: {
          type: 4,
          data: {
            content: "Unknown command"
          }
        }
      end
    end

    def handle_message_component(interaction)
      # Handle button clicks or other message components
      render json: {
        type: 4,
        data: {
          content: "Button clicked!"
        }
      }
    end

    def handle_modal_submit(interaction)
      # Handle modal submissions
      render json: {
        type: 4,
        data: {
          content: "Modal submitted!"
        }
      }
    end

    def valid_signature?(request)
      puts "KÄKL"
      discord_public_key = ENV['DISCORD_PUBLIC_KEY']
      timestamp = request.headers['X-Signature-Timestamp']
      signature = request.headers['X-Signature-Ed25519']
      body = request.body.read

      verify_key = Ed25519::VerifyKey.new(Base64.decode64(discord_public_key))
      verify_key.verify(Base64.decode64(signature), timestamp + body)
    rescue
      false
    end
  end
end
