require 'twitter_ebooks'
require 'dotenv'

# Load enviroment variables file
Dotenv.load(".env")

# Model for tweets
MODEL_PATH = "model/Tweets.model"

# This is an example bot definition with event handlers commented out
# You can define and instantiate as many bots as you like

class Ras_bot < Ebooks::Bot

  attr_accessor :model

  # Configuration here applies to all Bots
  def configure
    # Consumer details come from registering an app at https://dev.twitter.com/
    # Once you have consumer details, use "ebooks auth" for new access tokens
    self.consumer_key = ENV["CONSUMER_KEY"] # Your app consumer key
    self.consumer_secret = ENV["CONSUMER_SECRET"] # Your app consumer secret

    # Users to block instead of interacting with
    self.blacklist = []

    # Range in seconds to randomize delay when bot.delay is called
    self.delay_range = 3..8
  end

  # Random time function
  def time
    # Range into 10 and 120 minutes 
    number = 10..120
    # Pickup random number
    minutes = rand(number)
    # Result on a string
    time = minutes.to_s + 'm'
  end

  def on_startup
    scheduler.every time do
      # Tweet something every 24 hours
      # See https://github.com/jmettraux/rufus-scheduler
      # tweet("hi")
      # pictweet("hi", "cuteselfie.jpg")
      log "Loading model #{MODEL_PATH}"
      model = Ebooks::Model.load("MODEL_PATH")
      text = model.make_statement(140)
      tweet(text)
    end
  end

  def on_message(dm)
    # Reply to a DM
    model = Ebooks::Model.load("MODEL_PATH")
    reply(dm, model.make_response(tweet.text, 130))
    # reply(dm, "Hola! Gracias por seguir mi canal")
  end

  def on_follow(user)
    # Follow a user back
    follow(user.screen_name)
  end

  def on_mention(tweet)
    # Reply to a mention
    model = Ebooks::Model.load("MODEL_PATH")
    text = model.make_response(tweet.text, 130)
    reply(tweet, meta(tweet).reply_prefix + text)
    # reply(tweet, "Hola, como estas?")
  end

  def on_timeline(tweet)
    # Reply to a tweet in the bot's timeline
    model = Ebooks::Model.load("MODEL_PATH")
    unless tweet.text.include?("@") # we don't want to take part at other conversations
      text = model.make_response(tweet.text, 130)
      # reply(tweet, meta(tweet).reply_prefix + text)
      tweet(meta(tweet).reply_prefix + text) # to not show up in the replies
    end
    # reply(tweet, "tienes razón!")
  end

  def on_favorite(user, tweet)
    # Follow user who just favorited bot's tweet
    follow(user.screen_name)
  end

  def on_retweet(tweet)
    # Follow user who just retweeted bot's tweet
    follow(tweet.user.screen_name)
  end

  def load_model
    # Load model to Markov chain
    model = Ebooks::Model.load("MODEL_PATH")
  end
end

# Make a Ras_bot and attach it to an account
Ras_bot.new("RasAlGhul_bot") do |bot|
  bot.access_token = ENV["ACCESS_TOKEN"] # Token connecting the app to this account
  bot.access_token_secret = ENV["ACCESS_TOKEN_SECRET"] # Secret connecting the app to this account
end
