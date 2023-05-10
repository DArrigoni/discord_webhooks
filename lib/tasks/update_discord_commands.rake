namespace :discord do
  desc "Update all discord commands; Pass guild_id to update for a specific Discord Guild"
  task :update_commands, [:guild_id] => [:environment] do |task, args|
    Rails.autoloaders.main.eager_load_dir(Rails.root.join('app/bot'))
    commands = DiscordWebhooks::BaseCommand.descendants.map(&:generate_discord_command).flatten

    discord_api = DiscordWebhooks::DiscordApi.new
    puts discord_api.update_commands commands, args[:guild_id]
  end
end