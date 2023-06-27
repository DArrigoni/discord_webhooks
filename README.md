# Discord Webhooks
A Rails engine to handle Discord application commands that is still very much under development. You probably shouldn't 
use this. How did you even find this repository? You must be really bored.

## Usage
Don't yet. 

Seriously, this ain't the tool you're looking for yet. Go checkout [discordrb](https://github.com/shardlab/discordrb) 
if you just want a bot.

You still here? Okay, well...


## Installation
Not uploaded to any gem server yet. If you don't know how to install an engine locally, just don't.

Once it's loaded, run `rails g discord_webhooks:install` with the Application ID, Public Key and Bot Token from the
Discord application website. Check `rails g discord_webhooks:install --help` for more info.

Start up the server and make it visible to the Discord servers. Since you need webhooks to hit your local environment, 
you need some way of exposing your local server to the internet. 

I recommend using [ngrok](https://ngrok.com/). 

For example I use
```bash
ngrok http 3000 --subdomain=darrigonitest
```
while developing and aim my "INTERACTIONS ENDPOINT URL" at `https://darrigonitest.ngrok.io/bot` 

Obviously this will be your actual production server eventually. Consider making two Discord Applications, one for 
dev/test purposes and one for production. Or more. You know your set up better than I do.

## Usage

Your commands go in `app/bot`. You can use `rails g discord_webhooks:command` to generate one. I'll add more shit here 
eventually, but this is a pile of shit and is gonna change a bunch before I let any other human beings subject 
themselves to this.  

## Contributing
Yeah, don't. Unless you're really, *really* bored. In which case, fork it and go wild. Run some tests, put up a PR, 
we'll see what happens.

## License
The gem is available as open source under the terms of the [MIT SHIT License](https://raw.githubusercontent.com/DArrigoni/discord_webhooks/master/MIT-SHIT-LICENSE). 

***But you really shouldn't be using this yet. It's a pile of shit.***


[Discord](discord.com) is its own thing. Obviously. Please don't sue me.