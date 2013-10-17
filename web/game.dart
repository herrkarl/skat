library skat.game;
import "cards.dart";

class Trick {
  final int leader;
  final List<Card> cards;
  Trick(this.leader, this.cards);
}

class Game {
  static const DEALING = 0;
  static const BID1 = 1;
  static const BID2 = 2;
  static const TAKING_STOCK = 3;
  static const DECLARING = 4;
  static const PLAYING = 5;
  static const COUNTING = 6;
  static const PASS = 7;

  final List<Player> players;
  List<int> points;

  int round = -1;
  int trick = 0;
  int phase = DEALING;
  int startingPlayer = 0;
  int rePlayer;

  int biddingPlayer;
  int listeningPlayer;
  int currentBid;

  GameMode mode;

  List<Trick> tricks;
  List<Card> playedCards;
  List<List<Card>> hands;
  List<Card> stock;

  Game(this.players) :
      points = <int>[0, 0, 0],
      tricks = <Trick>[],
      playedCards = <Card>[] {
    assert(players.length == 3);
  }

  void nextAction() {
    switch (phase) {
      case DEALING:
        Deck deck = new Deck();
        deck.shuffle();
        hands = <List<Card>>[<Card>[], <Card>[], <Card>[]];
        for (int i = 0; i < 30; i++) {
          hands[i % 3].add(deck.cards[i]);
        }
        stock = <Card>[deck.cards[30], deck.cards[31]];
        for (int i = 0; i < 3; i++) {
          players[i].deal(hands[i]);
        }
        phase = BID1;
        changePlayer();
        round++;
        listeningPlayer = nextPlayer(startingPlayer);
        biddingPlayer = nextPlayer(listeningPlayer);
        currentBid = 0;
        break;
      case BID1:
        int bid = bidder.getBid(currentBid);
        if (bid <= currentBid) {
          biddingPlayer = nextPlayer(listeningPlayer);
          phase = BID2;
          break;
        }
        currentBid = bid;
        if (!listener.holds(bidder, bid)) {
          listeningPlayer = nextPlayer(listeningPlayer);
          phase = BID2;
        }
        break;
      case BID2:
        int bid = bidder.getBid(currentBid);
        if (bid <= currentBid) {
          rePlayer = listeningPlayer;
          phase = TAKING_STOCK;
          currentBid = bid;
          break;
        }
        currentBid = bid;
        if (!listener.holds(bidder, bid)) {
          rePlayer = biddingPlayer;
          phase = TAKING_STOCK;
          break;
        }
        break;
      case TAKING_STOCK:
        if (player.wantsStock()) {
          stock = player.useStock(stock);
        }
        phase = DECLARING;
        break;
      case DECLARING:
        mode = player.declareMode();
        phase = PLAYING;
        break;
      case PLAYING:
        break;
    }
  }

  Player get bidder => players[biddingPlayer];
  Player get listener => players[listeningPlayer];
  Player get player => players[rePlayer];

  int nextPlayer(int player) => (player + 1) % 3;

  void changePlayer() {
    startingPlayer = nextPlayer(startingPlayer);
  }
}

abstract class GameMode {
  int winner(Trick trick);
  int worth(Trick trick);
  List<int> points(List<Trick> tricks, List<Card> stock);
  List<bool> result(List<Trick> tricks, List<Card> stock);
  bool isHandGame();
}

abstract class Player {
  void deal(List<Card> cards);

  void inform(Player from, Player to, int bid);
  bool holds(Player from, int bid);
  int getBid(int currentBid);

  bool wantsStock();
  List<Card> useStock(List<Card> stock);

  GameMode declareMode();

  Card play(List<Card> playedCards);
}
