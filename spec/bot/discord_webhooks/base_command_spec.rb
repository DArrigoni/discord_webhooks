require 'rails_helper'

RSpec.describe DiscordWebhooks::BaseCommand do
  context '.command' do
    it 'should set the command name and description' do
      class FooBarCommand < DiscordWebhooks::BaseCommand
        command name: 'foo', description: 'Lorem Ipsum'
      end

      expect(FooBarCommand.command_name).to eq 'foo'
      expect(FooBarCommand.description).to eq 'Lorem Ipsum'

      Object.send(:remove_const, :FooBarCommand)
    end

    it 'should set the name and description by default even if the command method is not called' do
      class FooBarCommand < DiscordWebhooks::BaseCommand
        # command name: 'foo', description: 'Lorem Ipsum'
      end

      expect(FooBarCommand.command_name).to eq 'foo-bar'
      expect(FooBarCommand.description).to eq 'Foo bar'

      Object.send(:remove_const, :FooBarCommand)
    end
  end

  context ".option & options_by_name" do
    it 'should let me set an user option and resolve when selected' do
      class FooBarCommand < DiscordWebhooks::BaseCommand
        option 'Attacker', :user, description: 'Attacker'
      end

      expect(FooBarCommand.options).to eq [
        {
          type: 6,
          name: 'attacker',
          description: 'Attacker'
        }
      ]

      command = FooBarCommand.new({
        "data" => {
          "name" => "foo-bar",
          "options" => [
            { "name" => "attacker", "type" => 6, "value" => "240601403511406592" }
          ],
          "resolved" => {
            "members" => {
              "240601403511406592" => {
                "avatar" => nil,
                "communication_disabled_until" => nil,
                "flags" => 0,
                "joined_at" => "2022-01-30T02:59:08.578000+00:00",
                "nick" => nil,
                "pending" => false,
                "permissions" => "137411140505153",
                "premium_since" => nil,
                "roles" => []
              }
            },
            "users" => {
              "240601403511406592" => {
                "avatar" => "a_91c143c0430a778954e032d2852c0938",
                "avatar_decoration" => "v2_a_8f4e2c88d0b00a2e6eefdbe0a70944ec",
                "discriminator" => "4709",
                "display_name" => nil,
                "global_name" => nil,
                "id" => "240601403511406592",
                "public_flags" => 0,
                "username" => "H."
              }
            }
          },
          "type" => 1
        },
        "type" => 2
      }.with_indifferent_access)

      expect(command.options_by_name[:attacker]).to eq({
        'name' => 'attacker',
        'type' => 6,
        'value' => "240601403511406592",
        'resolved' => {
          "avatar" => nil,
          "communication_disabled_until" => nil,
          "flags" => 0,
          "joined_at" => "2022-01-30T02:59:08.578000+00:00",
          "nick" => nil,
          "pending" => false,
          "permissions" => "137411140505153",
          "premium_since" => nil,
          "roles" => [],
          'user' => {
            "avatar" => "a_91c143c0430a778954e032d2852c0938",
            "avatar_decoration" => "v2_a_8f4e2c88d0b00a2e6eefdbe0a70944ec",
            "discriminator" => "4709",
            "display_name" => nil,
            "global_name" => nil,
            "id" => "240601403511406592",
            "public_flags" => 0,
            "username" => "H."
          }
        }
      })

      Object.send(:remove_const, :FooBarCommand)
    end
  end

  context '#executor' do
    it 'should give me the calling user/member hash' do
      class FooBarCommand < DiscordWebhooks::BaseCommand
      end

      command = FooBarCommand.new({
        "data" => {
          "guild_id" => "937179437353549855",
          "id" => "1105837992423206912",
          "name" => "foo-bar",
          "type" => 1
        },
        "member" => {
          "avatar" => nil,
          "communication_disabled_until" => nil,
          "deaf" => false,
          "flags" => 0,
          "joined_at" => "2022-01-30T02:56:29.828000+00:00",
          "mute" => false,
          "nick" => nil,
          "pending" => false,
          "permissions" => "140737488355327",
          "premium_since" => nil,
          "roles" => [
            "952362590867181568",
            "952362154974130196",
            "952362628028727316",
            "952362690003734588",
            "952362756961603614"
          ],
          "user" => {
            "avatar" => "bc85018fda99856c8343095c6908085a",
            "avatar_decoration" => nil,
            "discriminator" => "4375",
            "display_name" => nil,
            "global_name" => nil,
            "id" => "65208420147400704",
            "public_flags" => 0,
            "username" => "StormTAG"
          }
        },
        "type" => 2
      })

      expect(command.executor).to eq({
        "avatar" => nil,
        "communication_disabled_until" => nil,
        "deaf" => false,
        "flags" => 0,
        "joined_at" => "2022-01-30T02:56:29.828000+00:00",
        "mute" => false,
        "nick" => nil,
        "pending" => false,
        "permissions" => "140737488355327",
        "premium_since" => nil,
        "roles" => [
          "952362590867181568",
          "952362154974130196",
          "952362628028727316",
          "952362690003734588",
          "952362756961603614"
        ],
        "user" => {
          "avatar" => "bc85018fda99856c8343095c6908085a",
          "avatar_decoration" => nil,
          "discriminator" => "4375",
          "display_name" => nil,
          "global_name" => nil,
          "id" => "65208420147400704",
          "public_flags" => 0,
          "username" => "StormTAG"
        }
      })

      Object.send(:remove_const, :FooBarCommand)
    end
  end

  context 'discord command generation' do

    context 'without options' do
      around do |spec|
        class FooCommand < DiscordWebhooks::BaseCommand
        end

        spec.run

        Object.send(:remove_const, :FooCommand)
      end

      subject!(:command_hash) { FooCommand.generate_discord_command }

      it { expect(command_hash[:name]).to eq 'foo' }
      it { expect(command_hash[:description]).to eq "Foo" }
      it { expect(command_hash.keys).to_not include(:options) }
    end

    context 'with description/options' do
      around do |spec|
        class FooCommand < DiscordWebhooks::BaseCommand
          command description: 'Do foo stuff',
            options: [
              { type: 4, name: 'amount', description: 'Amount of foo', required: true, min_value: 0 },
              { type: 6, name: 'foo-er', description: 'Foo-er', }
            ]
        end

        spec.run

        Object.send(:remove_const, :FooCommand)
      end

      subject!(:command_hash) { FooCommand.generate_discord_command }

      it { expect(command_hash[:name]).to eq 'foo' }
      it { expect(command_hash[:description]).to eq 'Do foo stuff' }
      it { expect(command_hash[:options]).to eq [
        { type: 4, name: 'amount', description: 'Amount of foo', required: true, min_value: 0 },
        { type: 6, name: 'foo-er', description: 'Foo-er', }
      ] }
    end
  end
end