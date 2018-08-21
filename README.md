# ParseQueue

The parse queue is a component in the Ruby Compiler Toolkit Project (RCTP). Its
role is to facilitate the movement of language tokens from one compiler phase
(like the lexical analyzer) to the next one (like the parser). More than just a
simple queue, it supports backing up or falling back to earlier states allowing
the parser to try other paths in the syntax tree when one path runs into a
dead end.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'parse_queue'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install parse_queue

## Usage

WIP

## Development

WIP

## Contributing

WIP

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ParseQueue project’s codebases, issue trackers,
chat rooms and mailing lists is expected to follow the
[code of conduct](https://github.com/PeterCamilleri/parse_queue/blob/master/CODE_OF_CONDUCT.md).
