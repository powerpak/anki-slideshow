require "sinatra/base"
require "json"

require "backports/1.9.1/array/sample"

# Displays Anki flashcards, exported from Anki as HTML, 
# in a simple slideshow-like interface on a webpage.
#
# See http://github.com/powerpak/anki-slideshow for details.

module AnkiSlideshow
  
  NO_CARDS_MESSAGE = "No cards in this deck, please select another."
  X_FRAME_OPTIONS = "ALLOW-FROM http://tedpak.com"
  
  class << self
    attr_accessor :data_dir, :media_dir, :cards, :decks
  end
  
  def self.new(data_dir)
    self.data_dir   = data_dir
    self.media_dir = File.join(data_dir, 'collection.media')
    
    data = JSON.load(File.open(File.join(data_dir, 'anki-slideshow.json')))
    self.cards = data["cards"]
    self.decks = data["decks"]

    App
  end
  
  class App < Sinatra::Base
    set :app_file, __FILE__

    before do
      @deck = nil
      @decks = AnkiSlideshow.decks.keys.sort
      headers "X-Frame-Options" => X_FRAME_OPTIONS
      content_type "text/html", :charset => "utf-8"
    end

    get "/" do
      redirect "/" + AnkiSlideshow.decks.keys.sample
    end
    
    get "/:image.jpg" do
      content_type "image/jpeg"
      send_file File.join(AnkiSlideshow.media_dir, params[:image] + ".jpg")
    end
    
    get "/:deck" do
      deck = AnkiSlideshow.decks[params[:deck]]
      pass unless deck
      random_card_id = deck.sample.to_s
      @title = @deck_name = params[:deck]
      if random_card_id then @card = AnkiSlideshow.cards[random_card_id]
      else @card = {"q" => NO_CARDS_MESSAGE, "a" => NO_CARDS_MESSAGE}
      erb :card
    end

  end
end