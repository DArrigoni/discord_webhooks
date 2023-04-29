Rails.application.routes.draw do
  mount DiscordWebhooks::Engine => "/discord_webhooks"
end
