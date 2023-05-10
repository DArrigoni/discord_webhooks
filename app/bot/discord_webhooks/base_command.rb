# frozen_string_literal: true
module DiscordWebhooks
  class BaseCommand
    class_attribute :command_name, :description, :options

    def self.command(name: nil, description: nil, options: nil)
      underscore_name = self.name.gsub('Command', '').underscore

      self.command_name = name || underscore_name.dasherize
      self.description = description || underscore_name.humanize
      self.options = options unless options.nil?
    end

    def self.generate_discord_command
      command_hash = {
        name: self.command_name,
        description: self.description
      }
      command_hash[:options] = options if options.present?
      command_hash
    end

    def self.inherited(subclass)
      subclass.command
    end

    APPLICATION_COMMAND_OPTION_TYPE = {
      sub_command: 1, #
      sub_command_group: 2, #
      string: 3, #
      integer: 4, #	Any integer between -2^53 and 2^53
      boolean: 5, #
      user: 6, #
      channel: 7, #	Includes all channel types + categories
      role: 8, #
      mentionable: 9, #	Includes users and roles
      number: 10, #	Any double between -2^53 and 2^53
      attachment: 11 #	attachment object
    }

    def self.option(name, type, **command_options)
      self.options ||= []

      command_type = type.is_a?(Integer) ? type : APPLICATION_COMMAND_OPTION_TYPE[type]

      self.options << command_options.merge({
        type: command_type,
        name: name.to_s.downcase,
      })
    end

    attr_accessor :command_params, :discord_api

    def initialize(command_params, discord_api = DiscordApi.new)
      @command_params = command_params
      @discord_api = discord_api
    end

    def run_command
      raise NotImplementedError('To be implemented by command classes')
    end

    def options_by_name
      @options_by_name ||= Array(command_params[:data][:options]).inject(Hash.new({})) do |hash, option_hash|
        if option_hash[:type] == APPLICATION_COMMAND_OPTION_TYPE[:user]
          user_id = option_hash[:value]

          user_hash = command_params.dig(:data, :resolved, :users, user_id)
          member_hash = command_params.dig(:data, :resolved, :members, user_id).merge({ 'user' => user_hash })

          option_hash.merge!({ 'resolved' => member_hash })
        end
        hash[option_hash[:name]] = option_hash
        hash
      end.with_indifferent_access
    end

    def executor
      command_params['member']
    end
  end
end