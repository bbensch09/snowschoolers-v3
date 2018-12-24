# jQuery timepicker for Rails
[![Gem Version](https://badge.fury.io/rb/jquery-timepicker-rails.png)](http://badge.fury.io/rb/jquery-timepicker-rails)

jquery-timepicker and Datepair.js packaged for the Rails 3.1+ asset pipeline.
See the [jquery-timepicker project home page](http://github.com/jonthornton/jquery-timepicker) and the [Datepair.js home page](https://github.com/jonthornton/Datepair.js).

## Installation

Add this line to your application's Gemfile:

    gem 'jquery-timepicker-rails'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jquery-timepicker-rails

## Usage

Add the following JavaScript file to `app/assets/javascripts/application.js`:

    //= require jquery.timepicker.js

Add the following stylesheet file to `app/assets/stylesheets/application.css`:

    *= require jquery.timepicker.css

You can also include `Datepair.js`, and optionally it's accompanying jquery plugin, `jquery.datepair.js`:

    //= require Datepair
    //= require jquery.datepair.js

Datepair.js depends on [bootstrap-datepicker](http://github.com/eternicode/bootstrap-datepicker) or [jQuery UI Datepicker](http://jqueryui.com/demos/datepicker/).
jquery-timepicker depends on `jQuery`.

## License

jquery-timepicker is being developed by [Jon Thornton](http://jonthornton.com/) and is under [MIT license](http://en.wikipedia.org/wiki/MIT_License).

This gem is also licensed under [MIT license](https://raw.github.com/tkrotoff/jquery-timepicker-rails/master/LICENSE.txt).
