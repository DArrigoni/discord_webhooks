# Discord Webhooks
A Rails engine to handle Discord application commands that is still very much under development. You probably shouldn't use this. How did you even find this repository? You must be really bored.

## Usage
Don't yet. 

Seriously, this ain't the tool you're looking for yet. Go checkout [discordrb](https://github.com/shardlab/discordrb) if you just want a bot.

You still here? Okay, well... Copy the structure of the `spec/dummy/app/bot/ping_command.rb` file and see what happens. Don't blame me if you summon Chuthulu or something.


## Installation
Not uploaded to any gem server yet. If you don't know how to install an engine locally, just don't.

Once it's loaded, configure it with an initializer like this:

```ruby 
#/config/initializers/discord_webhooks.rb

DiscordWebhooks.discord_application_id = 'APPLICATION_ID_FROM_DISCORD_APP'
DiscordWebhooks.discord_public_key = 'PUBLIC_KEY_FROM_DISCORD_APP'
DiscordWebhooks.discord_bot_token = 'BOT_TOKEN_FROM_DISCORD_APP'
```

Then mount it like this...
```ruby
#/config/routes.rb
mount DiscordWebhooks::Engine => "/bot"
```

And aim your "INTERACTIONS ENDPOINT URL" in your Discord Application configuration to your application's endpoint. 

### Development
Since you need webhooks to hit your local environment, you need some way of exposing your local server to the internet. 

I recommend using [ngrok](https://ngrok.com/). 

For example I use
```bash
ngrok http 3000 --subdomain=darrigonitest
```
while developing and aim my "INTERACTIONS ENDPOINT URL" at `https://darrigonitest.ngrok.io/bot` 

## Contributing
Yeah, don't. Unless you're really, *really* bored. In which case, fork it and go wild. Run some tests, put up a PR, we'll see what happens.

## License
The gem is available as open source under the terms of the [MIT SHIT License](https://raw.githubusercontent.com/DArrigoni/discord_webhooks/master/MIT-SHIT-LICENSE). 

***But you really shouldn't be using this yet. It's a pile of shit.***


[Discord](discord.com) is its own thing. Obviously. Please don't sue me.