# HS Stats

![alt text](https://github.com/tirey93/flutter_hs_stats/blob/main/assets/demo.png?raw=true)

This is mobile app for checking Hearthstone stats. It wildly uses Hearthstone Deck Tracker API.
Stats includes:
- Number of collectible cards in player's collection
- Sum of dust("rares" in fact*) for each year and for each expansion
- Sum of "rares" in whole wild
- Average number of "rares"* in each year
- Average number of "rares"* in remaing current wild(e.x. if in current wild 5 months remains to next rotation it divides sum of all wild collectible cards by 5)
- Number of free dust(Recalculated to "rares")
- Last reload  of user collection(made by Hearthstone Deck Tracker).

*By "rares" I mean my own stat currency. Rare is worth 20 dust.
- 1 legendary card = 20 rare cards = 4 epic cards
- 1 golden legendary card = 4 golden epic cards = 16 rare golden cards = 40 golden normal cards = 4 legendary cards

In order to make this app work you need:
- Android phone with system version > 5.0
- Battle.net account and Hearthstone installed on your PC
- HSReplay free account

# Setting up HSReplay info
In order to make this app work you need to provide it an account_lo and session id connected to your HSReplay account. 
Instruction how to get it:
- make sure you are login to HSReplay which is combined to your Battle.net account 
- go to: https://hsreplay.net/collection/mine/
- open DevTools(F12), refresh page and go to Network tab
- as you can see in the screenshot ([link](https://raw.githubusercontent.com/tirey93/flutter_hs_stats/refs/heads/main/assets/hs_collection.png)), filter by Fetch/XHR and find "collection" endpoint 
- in the URL of the endpoint(collection/?region...) copy **account_lo** and enter it to the app
- on the "Cookies" window find **sessionid** - this is what you need to enter in the app

