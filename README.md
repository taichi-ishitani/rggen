[![Gem Version](https://badge.fury.io/rb/rggen.svg)](https://badge.fury.io/rb/rggen)
[![Build Status](https://travis-ci.org/taichi-ishitani/rggen.svg?branch=master)](https://travis-ci.org/taichi-ishitani/rggen)
[![Dependency Status](https://dependencyci.com/github/taichi-ishitani/rggen/badge)](https://dependencyci.com/github/taichi-ishitani/rggen)
[![Code Climate](https://codeclimate.com/github/taichi-ishitani/rggen/badges/gpa.svg)](https://codeclimate.com/github/taichi-ishitani/rggen)
[![Test Coverage](https://codeclimate.com/github/taichi-ishitani/rggen/badges/coverage.svg)](https://codeclimate.com/github/taichi-ishitani/rggen/coverage)
[![Join the chat at https://gitter.im/taichi-ishitani/rggen](https://badges.gitter.im/taichi-ishitani/rggen.svg)](https://gitter.im/taichi-ishitani/rggen?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

# RgGen

RgGen is a code generation tool for SoC designers.
It will automatically generate source code for control registers in a SoC design, e.g. RTL, UVM RAL model, from its register map document.
Also RgGen is customizable so you can build your specific generate tool.

## Ruby

RgGen is written in the [*Ruby*](https://www.ruby-lang.org/en/about/) programing language and supports version 2.0 or later.
If you don't have above version of Ruby, you need to install the Ruby at first.
To install the Ruby, see [this page](https://www.ruby-lang.org/en/downloads/).

## Installation

To install RgGen and required libraries, use the following command:

    $ gem install rggen

RgGen will be installed under your system root.

If you want to install them on other location, you need to specify the install directory and set the **GEM_PATH** environment variable like below:

    $ gem install --install-dir YOUR_INSTALL_DIRECTORY rggen
    $ export GEM_PATH=YOUR_INSTALL_DIRECTORY

## Usage

See [this page](https://github.com/taichi-ishitani/rggen/wiki/Getting-Started)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contact

If you have any questions, problems, ideas or somethings, you can post them on the following ways:

1. [Issue tracker](https://github.com/taichi-ishitani/rggen/issues)
2. [Chat room](https://gitter.im/taichi-ishitani/rggen)
3. [Mail](mailto:taichi730@gmail.com)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/taichi-ishitani/rggen. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

Copyright &copy; 2015-2016 Taichi Ishitani.
RgGen is available as open source under the terms of [the MIT License](LICENSE.txt).
