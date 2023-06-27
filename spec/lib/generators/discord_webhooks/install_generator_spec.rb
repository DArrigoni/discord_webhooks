require "rails_helper"
require "generator_spec"

load Rails.root.join('../../lib/generators/discord_webhooks/install/install_generator.rb')

describe DiscordWebhooks::InstallGenerator, type: :generator do
  destination Rails.root.join('tmp/generators')

  before(:each) do
    prepare_destination
  end

  context 'with no arguments' do
    before do
      run_generator
    end

    it 'creates the initializer file w/ defaults' do
      expect(destination_root).to have_structure {
        directory "config" do
          directory "initializers" do
            file "discord_webhooks.rb" do
              contains "DiscordWebhooks.discord_public_key = 'YOUR_PUBLIC_KEY_HERE'"
              contains "DiscordWebhooks.discord_application_id = 'YOUR_APPLICATION_ID_HERE'"
              contains "DiscordWebhooks.discord_bot_token = 'YOUR_BOT_TOKEN_HERE'"
            end
          end
        end
      }
    end
  end

  context 'with passed public-key arguments' do
    before do
      run_generator ['--public-key=ASDF1234']
    end

    it 'creates the initalizer file w/ the public key and the other defaults' do
      expect(destination_root).to have_structure {
        directory "config" do
          directory "initializers" do
            file "discord_webhooks.rb" do
              contains "DiscordWebhooks.discord_public_key = 'ASDF1234'"
              contains "DiscordWebhooks.discord_application_id = 'YOUR_APPLICATION_ID_HERE'"
              contains "DiscordWebhooks.discord_bot_token = 'YOUR_BOT_TOKEN_HERE'"
            end
          end
        end
      }
    end
  end

  context 'with all passed arguments' do
    before do
      run_generator %w(--public-key=ASDF1234 --application-id=QWER5678 --bot-token=zxcv90=-)
    end

    it 'creates the initializer w/ all the correct values' do
      expect(destination_root).to have_structure {
        directory "config" do
          directory "initializers" do
            file "discord_webhooks.rb" do
              contains "DiscordWebhooks.discord_public_key = 'ASDF1234'"
              contains "DiscordWebhooks.discord_application_id = 'QWER5678'"
              contains "DiscordWebhooks.discord_bot_token = 'zxcv90=-'"
            end
          end
        end
      }
    end
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
