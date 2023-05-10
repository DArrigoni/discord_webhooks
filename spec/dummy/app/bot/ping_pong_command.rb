class PingPongCommand < DiscordWebhooks::BaseCommand
  command description: "Ping pong, baby"

  def run_command
    {
      type: 4,
      data: { content: "Ping pong!" }
    }
  end
end