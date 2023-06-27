class DiscordWebhooks::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)

  class_option :public_key, desc: "Your Discord App's public key", required: false
  class_option :application_id, desc: "Your Discord App's application id", required: false
  class_option :bot_token, desc: "Your Discord App's bot token", required: false

  def copy_initializer_file
    #TODO: Prefer credentials over this mess, so folks don't commit their bot token. The rest really isn't that big a
    # deal but whatevs.
    initializer "discord_webhooks.rb", <<~INITIALIZER
      DiscordWebhooks.discord_public_key = '#{options[:public_key] || 'YOUR_PUBLIC_KEY_HERE'}'
      DiscordWebhooks.discord_application_id = '#{options[:application_id] || 'YOUR_APPLICATION_ID_HERE'}'
      DiscordWebhooks.discord_bot_token = '#{options[:bot_token] || 'YOUR_BOT_TOKEN_HERE'}'
    INITIALIZER

    inject_into_file 'config/routes.rb', "\tmount DiscordWebhooks::Engine => \"/bot\"\n",
      after: "Rails.application.routes.draw do\n"
  end
end
