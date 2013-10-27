anki-slideshow
==============

Displays [Anki][anki] flashcards, exported from Anki as HTML, in a simple slideshow-like interface on a webpage.  Check out a working demo of my [flashcards for med school](http://learn.tedpak.com/).

This is just for casual browsing: unlike the [Anki desktop clients][ankidl] or the [AnkiWeb interface][ankiweb], correct/incorrect answers are not tracked and scheduling data is not saved in any way.  I find this useful for leaving up info that I can watch when I'm bored.

It is implemented as a Ruby/Rack application built with [Sinatra][sinatra].  Ruby is preinstalled on most Macs and packaged for most Linuxes, and all necessary gems can be acquired with [RubyGems][rg] and [bundler][].  For deployment, techniques for any Rack apply, and it could be served with, e.g., Apache/Passenger, nginx/Passenger or nginx/Unicorn.

For getting data from your Anki decks into the web app, an Anki plugin is provided, which can be used with the Mac, Windows, or Linux/BSD [Anki desktop clients][ankidl].  The plugin exports all flashcard data and transfers it to the location of the Rack app via [rsync][] (i.e., you can create decks on one computer and serve them from another).  If you use Anki for Windows, you'll need to install rsync first via [Cygwin][cygwin], but it should already be installed on most Macs and Linuxes.

[anki]: http://ankisrs.net/
[sinatra]: http://www.sinatrarb.com/
[ankidl]: http://ankisrs.net/#download
[rsync]: http://rsync.samba.org/
[ankiweb]: https://ankiweb.net/
[rg]: http://www.rubygems.org/
[bundler]: http://bundler.io/
[cygwin]: http://www.cygwin.com/

Installation
------------

1. Clone this repository to the computer that will serve the Rack web application, and `cd` into it.

2. You will need some [Ruby gems][rg].  First, `gem install bundler`, then `bundle install`.

3. Create a folder to hold the flashcard data: `mkdir anki-data`.  (You can change this in `config.ru`).

4. If this computer is different from the one that has your Anki decks, make sure that the `anki-data` is accessible to you via SSH, and that you can get into it without a password using [SSH keys][keys].  If it's the same computer, don't worry about this.

[keys]: https://help.ubuntu.com/community/SSH/OpenSSH/Keys

5. On the computer that has your Anki decks, copy or symlink the `anki-slideshow.py` file from the anki-plugin directory into your Anki addons folder.  On most platforms, this folder is in your user's Documents folder, under Anki/addons.

6. Run Anki.  Once you're at the main window with all your decks, you'll now notice an "Export Cards to Anki-Slideshow" item under the Tools menu.  Click it.

7. You'll be asked for a `rsync` destination.  Enter in the location of the `anki-data` folder you created, which could be on the same computer, or a different computer.  In the former case, enter the full path starting with a forward slash, and in the latter, enter a destination in the form `username@host.tld:/path/to/anki-data`.

8. The files will be copied via rsync, and you'll see a message informing you of the results.

9. Back on the computer that is serving the Rack app, run `rackup -p4567` and off you go.  It will be accessible at <http://0.0.0.0:4567/>.

More complex setups involving nginx or Apache are possible, if you would like to run the app behind a robust web server.  For such situations, you'll want to check out [Passenger](https://www.phusionpassenger.com/) or [Unicorn](http://unicorn.bogomips.org/).

It may also be possible to serve this via Heroku, but I haven't tried yet.