# Brigitte

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/brigitte`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Game rules
Card game against max 4 players where you need to get rid of your cards as soon as possible.

### Game steps
1) You have a chance to swap the any cards in your hand with your cards that lays on the table.
   Usually you put up your best card on table. So you can move on fast to your blind cards behind it.
   When you have swapped your cards you push ready. When everyone is ready. The game starts with the player with the lowest card in hand.
   Turn runs clockwise.

2) In this phase a hand should always have minimum 3 cards when there is still cards on the deck. When you hand has less cards there will be cards automatically added in your hand from the deck.
   Everybody plays untill the deck and hands are empty.

3) The visible cards are taken into your hand. Now you play your hand untill it's empty.

4) You take one blind card when it's your turn. When you clear all the blind cards you won the game.

### Special cards
Usually you put an equal card or higher on the pile.
Except if 7 is on top of the pile. Then you can only put cards lower or equal to 7.
There are other special cards
10 clears the pile and you stay in turn. You can always throw 10
It has the same effect if there are 4 consecutive equal cards on the pile.
You can always throw 2.
Ace is the highest Card.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'brigitte'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install brigitte

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/youszef/brigitte.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
