# HrrRbMount

[![Build Status](https://travis-ci.com/hirura/hrr_rb_mount.svg?branch=master)](https://travis-ci.com/hirura/hrr_rb_mount)
[![Gem Version](https://badge.fury.io/rb/hrr_rb_mount.svg)](https://badge.fury.io/rb/hrr_rb_mount)

hrr_rb_mount is a wrapper around mount and umount for CRuby.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hrr_rb_mount'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install hrr_rb_mount

## Usage

The basic usage is as follows.

```ruby
require "hrr_rb_mount"

flags = HrrRbMount::NOEXEC
HrrRbMount.mount "tmpfs", "/path/to/target", "tmpfs", flags, "size=1M" # => 0
HrrRbMount.mountpoint? "/path/to/target"                               # => true
HrrRbMount.umount "/path/to/target"                                    # => 0

HrrRbMount.bind "/path/to/source", "/path/to/target" # => 0
HrrRbMount.make_private "/path/to/target"            # => 0
HrrRbMount.remount "/path/to/target", flags          # => 0
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hirura/hrr_rb_mount. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/hirura/hrr_rb_mount/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the HrrRbMount project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/hirura/hrr_rb_mount/blob/master/CODE_OF_CONDUCT.md).
