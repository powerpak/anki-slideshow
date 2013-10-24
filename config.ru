#!/usr/bin/env rackup
require File.dirname(__FILE__) + "/anki-slideshow"

run AnkiSlideshow.new("anki-data")
