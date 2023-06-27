require "rails_helper"
require "generator_spec"

load Rails.root.join('../../lib/generators/discord_webhooks/command/command_generator.rb')

describe DiscordWebhooks::CommandGenerator, type: :generator do
  destination Rails.root.join('tmp/generators')
  arguments ['foo']

  before(:each) do
    prepare_destination
    run_generator
  end

  it 'creates the initializer file w/ defaults' do
    expect(destination_root).to have_structure {
      directory "app" do
        directory "bot" do
          file "application_command.rb" do
            contains "class ApplicationCommand < DiscordWebhooks::BaseCommand"
          end

          file "foo_command.rb" do
            contains "class FooCommand < ApplicationCommand"
            contains "def run_command"
          end
        end
      end
    }
  end
end
# require "generators/discord_webhooks/install/install_generator"
#
# module DiscordWebhooks
#   class DiscordWebhooks::InstallGeneratorTest < Rails::Generators::TestCase
#     tests DiscordWebhooks::InstallGenerator
#     destination Rails.root.join("tmp/generators")
#     setup :prepare_destination
#
#     test "generator runs without errors" do
#       assert_nothing_raised do
#         run_generator
#       end
#     end
#
#     test "generates initializer" do
#       run_generator
#       assert_file"config/initializers/discord_webhooks.rb"
#     end
#   end
# end
