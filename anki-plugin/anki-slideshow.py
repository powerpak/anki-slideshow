# import the main window object (mw) from ankiqt
from aqt import mw
# import the "show info" tool from utils.py
from aqt.utils import showInfo
# import all of the Qt GUI library
from aqt.qt import *

import io, json

# We're going to add a menu item below. First we want to create a function to
# be called when the menu item is activated.

def exportCardsToWeb():
    export = {
        "decks": {},
        "cards": {}
    }
    
    for deck in mw.col.decks.all():
        deckName = deck['name']
        export["decks"][deckName] = mw.col.findCards("deck:'%s'" % deckName)
        
    for card in mw.col.renderQA(None, "all"):
        id = card["id"]
        del card["id"]
        export["cards"][id] = card
    
    with io.open('/tmp/anki-slideshow.json', 'w', encoding='utf-8') as f:
        f.write(unicode(json.dumps(export, ensure_ascii=False)))
    
    # show a message box
    showInfo("Card count: %d" % len(export["cards"]))

# create a new menu item, "test", and add it to the Tools menu
action = QAction("Export Cards to Anki-Slideshow", mw)
mw.connect(action, SIGNAL("triggered()"), exportCardsToWeb)
mw.form.menuTools.addAction(action)