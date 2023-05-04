Rails.application.routes.draw do
  mount DiscordWebhooks::Engine => "/bot"
end
