library skat.cards;
import 'dart:math';
import 'dart:collection';

class Suite {
  final int _value;
  const Suite(this._value);

  static const DIAMONDS = const Suite(0);
  static const HEARTS = const Suite(1);
  static const SPADES = const Suite(2);
  static const CLUBS = const Suite(3);

  static const SUITES = const <Suite>[DIAMONDS, HEARTS, SPADES, CLUBS];
}

class Rank {
  final int _value;
  const Rank(this._value);

  static const SEVEN = const Suite(0);
  static const EIGHT = const Suite(1);
  static const NINE = const Suite(2);
  static const TEN = const Suite(3);
  static const JACK = const Suite(4);
  static const QUEEN = const Suite(5);
  static const KING = const Suite(6);
  static const ACE = const Suite(7);

  static const RANKS =
      const <Rank>[SEVEN, EIGHT, NINE, TEN, JACK, QUEEN, KING, ACE];
}

class Card {
  final Suite suite;
  final Rank rank;
  const Card(this.suite, this.rank);
}

class Deck extends Object with IterableMixin<Card> {
  static final int CARDS = Suite.SUITES.length * Rank.RANKS.length;

  final List<Card> cards;

  Deck() : cards = new List<Card>(CARDS) {
    int index = 0;
    for (Suite suite in Suite.SUITES) {
      for (Rank rank in Rank.RANKS) {
        cards[index++] = new Card(suite, rank);
      }
    }
  }

  void shuffle() {
    Random rng = new Random();
    for (int i = CARDS - 1; i >= 0; i--) {
      _swap(rng.nextInt(i + 1), i);
    }
  }

  void _swap(int i, int j) {
    if (i == j) return;
    Card c = cards[i];
    cards[i] = cards[j];
    cards[j] = c;
  }

  Iterator<Card> get iterator => cards.iterator;
}
