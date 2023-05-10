module DiscordWebhooks
  class BotController < ApplicationController
    # skip_before_action :verify_authenticity_token
    before_action :verify_discord_request, except: [:bot_info]

    rescue_from Ed25519::VerifyError do |e|
      head :unauthorized
    end

    DISCORD_INTERACTION_TYPE = {
      PING: 1,
      APPLICATION_COMMAND: 2,
      MESSAGE_COMPONENT: 3,
      APPLICATION_COMMAND_AUTOCOMPLETE: 4,
      MODAL_SUBMIT: 5
    }

    def bot_info
      info = []
      info << "Requirements loaded: #{Ed25519::VerifyKey.present?}"
      info << "Config key: #{DiscordWebhooks.discord_public_key}"
      render inline: "<style>li { margin-top: 0.5rem; } ul { list-style: square; }</style><ul><li>#{info.join('</li><li>')}</li></ul>".html_safe
    end

    def bot_action
      type = params.require('type')
      return render json: { type: 1 } if type == DISCORD_INTERACTION_TYPE[:PING]

      case type
        when DISCORD_INTERACTION_TYPE[:APPLICATION_COMMAND]
          run_command
        # when DISCORD_INTERACTION_TYPE[:MESSAGE_COMPONENT]
        #   run_message_handler
        # when DISCORD_INTERACTION_TYPE[:MODAL_SUBMIT]
        #   run_modal_handler
        else
          render_error :unsupported_action_type
      end

    end

    private

    def run_command
      # command = BaseCommand.command_for(command_params)
      command_name = command_params[:data][:name]
      command_class = "#{command_name}-command".underscore.camelize.constantize
      raise "Command not found: #{command_name}" if command_class.nil?

      command = command_class.new(command_params)
      payload = command.run_command

      render json: payload
    end

    def command_params
      params.require(:bot).permit!.tap do |params|
        Rails.logger.debug(params.to_h) if Rails.env.development?
      end
    end

    def render_error content
      #Don't actually put an error status code, or Discord will eat our error message
      render json: { type: 4, data: { content: content, flags: (1 << 6) } }
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
