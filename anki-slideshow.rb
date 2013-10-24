require "sinatra/base"
require "json"

require "backports/1.9.1/array/sample"

# A mobile-optimized wiki for the East Harlem Health Outreach
# Partnership, Icahn School of Medicine at Mount Sinai, NY, NY
#
# Original license for git-wiki.rb is WTFPL
# License for this fork is MIT (see README.markdown)

module AnkiSlideshow
  
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
      @card = AnkiSlideshow.cards[random_card_id]
      erb :card
    end

  end
end