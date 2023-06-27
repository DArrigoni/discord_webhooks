class DiscordWebhooks::CommandGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  def create_application_command
    copy_file "application_command.rb", 'app/bot/application_command.rb'
    template 'templated_command.rb.erb', "app/bot/#{name}_command.rb"
  end

  #TODO: Add test_framework generators
  # hook_for :test_framework, as: :command
end
