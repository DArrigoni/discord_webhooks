module DiscordWebhooks
  mattr_accessor :discord_public_key

  class Engine < ::Rails::Engine
    engine_name "discord_webhooks"
    isolate_namespace DiscordWebhooks

    config.to_prepare do
      require "ed25519"

      # Dir.glob(Rails.root + "app/bot/**/*.rb")
    end
  end
end
