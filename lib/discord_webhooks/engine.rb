module DiscordWebhooks
  mattr_accessor :discord_public_key

  class Engine < ::Rails::Engine
    isolate_namespace DiscordWebhooks

    config.to_prepare do
      require "ed25519"
    end
  end
end
