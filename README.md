# Devextreme::Rails

This gem just includes [DevExtreme](https://js.devexpress.com/Documentation/ApiReference/UI_Widgets/dxDataGrid/) as an asset in the Rails asset pipeline. Source code can be found [here](https://github.com/DevExpress/DevExtreme).
Devextreme is not free for commercial use, so make sure you have a [valid license](https://js.devexpress.com/Licensing/) to use DevExtreme.

It also adds a nice ruby dsl to be able to create data tables easily

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'devextreme-rails'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install devextreme-rails

## Usage

Creat a data table using a ruby dsl:

E.g.
```ruby
class ExchangeRateDataTable < Devextreme::DataTable::Base

  def initialize(base_query = ExchangeRate)
    # assume you have activemodel associations set up for these includes for lookups
    super (base_query.includes(:exchange_rate_source, :from_currency, :to_currency))

    # define your columns and their data types 
    define_columns do |c|
      c.text :code
      c.text :name
      c.text :description
      c.lookup [:exchange_rate_source, :name]
      c.lookup [:from_currency, :code]
      c.lookup [:to_currency, :code]
      c.text :data_warning_count, proc { |instance| instance.data_warning_count }
    end

    # include all crud actions (or you optionally only show some by calling the underlying add_show_action, add_edit_action, add_delete_action methods)   
    include_crud_actions

    # override any options that are supported by the devextreme grid
    option :group_panel => {:visible => false}
    option :columnChooser => {:enabled => false}
    option :selection => { :mode => 'single' }

    # specify the path used to do remote calls to load more data fro the data table
    source :exchange_rates_path
  end

end


```

In you controller

```ruby
def find_data_table
  @data_table = ExchangeRateDataTable.new(current_filter_query)
end

def index
  current_filter_query = ExchangeRate.all
  @data_table = ExchangeRateDataTable.new(current_filter_query)
  respond_to do |format|
    format.html
    format.js
    format.json { render data_table_json: @data_table }
    # these are all optional
    format.xml { render data_table_xml: @data_table }
    format.csv { render data_table_csv: @data_table }
    format.xls { render data_table_xls: @data_table }
    format.s3 {  create_data_table_s3(@data_table)
       render "/data_tables/adhoc_export.js.erb" }
  end
end

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/devextreme-rails. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Devextreme::Rails project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/devextreme-rails/blob/master/CODE_OF_CONDUCT.md).
