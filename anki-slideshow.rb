require "sinatra/base"
require "json"

require "backports/1.9.1/array/sample"

# Displays Anki flashcards, exported from Anki as HTML, 
# in a simple slideshow-like interface on a webpage.
#
# See http://github.com/powerpak/anki-slideshow for details.
#
# Copyright 2013, Theodore Pak.  License: MIT.  See README.md.

module AnkiSlideshow
  
  NO_CARDS_MESSAGE = "<strong>No cards in this deck, please select another.</strong>"
  X_FRAME_OPTIONS = "ALLOW-FROM http://tedpak.com"
  BASE_TITLE = "Medical School Flashcards"
  
  class << self
    attr_accessor :data_dir, :media_dir, :cards, :decks
  end
  
  def self.new(data_dir)
    self.data_dir = data_dir
    @data_file = File.join(self.data_dir, 'anki-slideshow.json')
    self.media_dir = File.join(data_dir, 'collection.media')
    
    self.load_data

    App
  end
  
  def self.load_data()
    @data_mtime = File.mtime(@data_file)
    data = JSON.load(File.open(@data_file))
    self.cards = data["cards"]
    self.decks = data["decks"]
  end
  
  def self.check_data_updated()
    if File.mtime(@data_file) > @data_mtime then self.load_data; end
  end
  
  class App < Sinatra::Base
    set :app_file, __FILE__

    before do
      AnkiSlideshow.check_data_updated
      @deck = nil
      @decks = AnkiSlideshow.decks.keys.sort
      # You can enable all framing by disabling clickjack protection in Rack::Protection...
      # set :protection, :except => :frame_options
      # ... here I am allowing it only from my own site
      headers "X-Frame-Options" => X_FRAME_OPTIONS
      content_type "text/html", :charset => "utf-8"
      @base_title = BASE_TITLE
    end

    get "/" do
      @deck_name = AnkiSlideshow.decks.keys.sample
      @card = {
        "q" => erb(:welcome, :layout => false), 
        "a" => erb(:welcome, :layout => false, :locals => {:back => true})
      }
      erb :card
    end
    
    get "/:image.jpg" do
      content_type "image/jpeg"
      send_file File.join(AnkiSlideshow.media_dir, params[:image] + ".jpg")
    end
    
    get "/:deck" do
      @title = @deck_name = params[:deck]
      deck = AnkiSlideshow.decks[params[:deck]]
      pass unless deck
      random_card_id = deck.sample && deck.sample.to_s
      if random_card_id then @card = AnkiSlideshow.cards[random_card_id]
      else @card = {"q" => NO_CARDS_MESSAGE, "a" => NO_CARDS_MESSAGE}; end
      erb :card
    end

  end
end