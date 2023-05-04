module DiscordWebhooks
  class BotController < ApplicationController
    # skip_before_action :verify_authenticity_token
    before_action :verify_discord_request, except: [:bot_info]

    rescue_from Ed25519::VerifyError do |e|
      head :unauthorized
    end

    def bot_info
      info = []
      info << "Requirements loaded: #{Ed25519::VerifyKey.present?}"
      info << "Config key: #{DiscordWebhooks.discord_public_key}"
      render inline: "<style>li { margin-top: 0.5rem; } ul { list-style: square; }</style><ul><li>#{info.join('</li><li>')}</li></ul>".html_safe
    end

    def bot_action
      render json: { 'type' => 1 }
    end

    def verify_discord_request
      verification_key = Ed25519::VerifyKey.new(pack_key(DiscordWebhooks.discord_public_key))
      timestamp = request.headers["HTTP_X_SIGNATURE_TIMESTAMP"].to_s

      # Get the timestamp and check for replay attacks
      current_time = Time.now.to_i
      if (current_time - timestamp.to_i).abs > 10
        render json: { error: 'Request timestamp too old' }, status: :bad_request
        return
      end

      # Get the signature and verify it against the content and timestamp
      signature = pack_key request.headers["HTTP_X_SIGNATURE_ED25519"].to_s
      request_body = request.body.read
      verification_key.verify(signature, timestamp + request_body)
    end

    def pack_key keystring
      [keystring].pack("H*")
    end
  end
end
