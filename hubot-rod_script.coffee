# Description:
#   Script that comsumes the Pokéapi to return Pokémon info.
#   This also can list a user's public repos and show the last
#   xkcd comic.
#
# Commands:
#   hubot pokedex <pokemon> - Looks for that Pokémon's info.
#   hubot pokedex <id> - Looks for that Pokémon's info.
#   hubot repos <user> - Lists all repos from a user.
#   hubot interactions - Returns the number of ineractions with the bot.
#   hubot reset - Sets the number of interactions back to zero.
#   hubot thank you - Returns "You're welcome!"
#   xkcd comic - Returns latest xkcd comic.
#   tacos - Returns custom message.
#
# Author:
#   RodolfoFerro

module.exports = (robot) ->

  # Set initial number of interactions to zero
  interactions = 0

  # Return the number of interactions
  robot.respond /interactions/i, (res) ->
    robot.brain.set 'totalInteractions', interactions + 1
    interactions = robot.brain.get('totalInteractions') * 1 or 0
    res.send "Number of interactions: #{interactions}.\nMention me with the \"reset\" command to set this number to zero."

  # Reset the number of interactions
  robot.respond /reset/i, (res) ->
    interactions = 0
    robot.brain.set 'totalInteractions', 0
    res.send "Number of interactions set to zero."

  # Functionality that activates whenever somebody mentions the word "tacos"
  robot.hear /tacos/i, (res) ->
    robot.brain.set 'totalInteractions', interactions + 1
    interactions = robot.brain.get('totalInteractions') * 1 or 0
    res.send "TACOS?! YAAAS! WHEN?! WHERE?! 🌮🌮🌮"

  # Functionality that returns the latest xkcd comic
  robot.hear /xkcd comic/i, (res) ->
    robot.brain.set 'totalInteractions', interactions + 1
    interactions = robot.brain.get('totalInteractions') * 1 or 0
    res.http("https://xkcd.com/info.0.json")
      .get() (err, msg, body) ->
        switch msg.statusCode
          when 200
            info = JSON.parse(body)
            res.send "LATEST COMIC\nTitle: #{info.title}\nDescription: #{info.alt}\nImage: #{info.img}"
          else
            res.send "There was an error with xkcd. Try again later?"

  # Functionality that activates when you mention the bot, it consumes
  # the Pokeapi looking for Pokémon's info
  robot.respond /pokedex (.*)/i, (res) ->
    robot.brain.set 'totalInteractions', interactions + 1
    interactions = robot.brain.get('totalInteractions') * 1 or 0
    pokemon = res.match[1]
    robot.http("https://pokeapi.co/api/v2/pokemon/#{pokemon.toLowerCase()}/")
      .get() (err, msg, body) ->
        switch msg.statusCode
          when 200
            info = JSON.parse(body)
            robot.http("#{info.forms[0].url}")
              .get() (err2, msg2, body2) ->
                switch msg.statusCode
                  when 200
                    img_var = JSON.parse(body2)
                    img = img_var.sprites.front_default
                  else
                    img = "Image not available by now. Sorry! :("
                res.send "Pokémon: #{info.name}\nHeight: #{info.height/10} meters\nWeight: #{info.weight/10} kilograms\nImage: #{img}\n"
          else
            res.send "That might not be a Pokémon... "

  # Functionality that activates when you mention the bot, it returns
  # the number and the list of public repos from a user
  robot.respond /repos (.*)/i, (res) ->
    robot.brain.set 'totalInteractions', interactions + 1
    interactions = robot.brain.get('totalInteractions') * 1 or 0
    gh_user = res.match[1]
    robot.http("https://api.github.com/users/#{gh_user}/repos?per_page=100000&type=owner")
      .get() (err, msg, body) ->
        switch msg.statusCode
          when 200
            info = JSON.parse(body)
            repos = "Number of public repos: #{Object.keys(info).length}.\n\nList of public repos: \n"
            for index, value in info
              repos += "#{value+1}. #{info[value].html_url}\n"
            res.send "#{repos}"
          else
            res.send "Couldn't find a thing. Did you spell correctly that username? 🤔"

  # Thanking Hubot
  robot.respond /thank you/i, (res) ->
    robot.brain.set 'totalInteractions', interactions + 1
    interactions = robot.brain.get('totalInteractions') * 1 or 0
    res.send "You're welcome!"

  # Error handling
  robot.error (err, res) ->
    robot.brain.set 'totalInteractions', interactions + 1
    interactions = robot.brain.get('totalInteractions') * 1 or 0
    robot.logger.error "DOES NOT COMPUTE"

    if res?
      res.reply "DOES NOT COMPUTE"
