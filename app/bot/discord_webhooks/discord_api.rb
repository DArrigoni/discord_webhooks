require 'faraday'

module DiscordWebhooks
  class DiscordApi
    attr_accessor :conn


    def initialize conn = nil
      self.conn = conn || ::Faraday.new(
        url: 'https://discord.com/api/v8/',
      ) do |builder|
        builder.request :authorization, 'Bot', DiscordWebhooks.discord_bot_token
        builder.request :json
        builder.response :json
        builder.response :raise_error
        builder.adapter :net_http
      end
    end

    def list_commands guild_id = nil
      url = "applications/#{DiscordWebhooks.discord_application_id}/"
      url += "guilds/#{guild_id}/" unless guild_id.blank?
      url += 'commands'

      resp = conn.get(url)
      resp.body
    end

    def delete_command action_id, guild_id = nil
      url = "applications/#{DiscordWebhooks.discord_application_id}/"
      url += "guilds/#{guild_id}/" unless guild_id.blank?
      url += "commands/#{action_id}"

      resp = conn.delete(url)
      resp.body
    end

    def update_commands commands, guild_id = nil, dry_run = false
      url = "applications/#{DiscordWebhooks.discord_application_id}/"
      url += "guilds/#{guild_id}/" unless guild_id.blank?
      url += 'commands'

      if dry_run
        "PUT #{url}\n#{JSON.pretty_generate(commands)}"
      else
        resp = conn.put(url, commands)
        resp.body
      end
    end

    def add_role guild_id, member_id, role_id
      url = "guilds/#{guild_id}/members/#{member_id}/roles/#{role_id}"

      resp = conn.put(url)
      resp.success?
    end

    def remove_role guild_id, member_id, role_id
      url = "guilds/#{guild_id}/members/#{member_id}/roles/#{role_id}"

      resp = conn.delete(url)
      resp.success?
    end

    def post_message(content, channel_id)
      url = "channels/#{channel_id}/messages"

      resp = conn.post(url, content)
      resp.body.with_indifferent_access
    end

    def remove_message(channel_id, message_id)
      url = "channels/#{channel_id}/messages/#{message_id}"

      Rails.logger.info(url)
      conn.delete(url)
    rescue Faraday::ResourceNotFound => ex
      # Okie dokie, response not found means delete was a No-OP. Good to go.
      return ex.response
    end
  end
end