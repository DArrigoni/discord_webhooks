DiscordWebhooks::Engine.routes.draw do
  root to: "bot#bot_info"
  post '/', to: 'bot#bot_action', as: :bot_action
end
