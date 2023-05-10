module DiscordWebhooks
  mattr_accessor :discord_public_key, :discord_application_id, :discord_bot_token

  class Engine < ::Rails::Engine
    engine_name "discord_webhooks"
    isolate_namespace DiscordWebhooks

    config.to_prepare do
      require "ed25519"
    end
  end
end
