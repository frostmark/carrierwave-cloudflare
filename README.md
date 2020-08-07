# Carrierwave::Cloudflare

This gem provides a simple wrapper for transformation images via Cloudflare

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'carrierwave-cloudflare'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install carrierwave-cloudflare

## Usage

Include `CarrierWave::Cloudflare` in your base uploader

```ruby
class BaseUploader < CarrierWave::Uploader::Base
  include CarrierWave::Cloudflare
end
```


Define `virtual` version in some uploader:
```ruby
class AvatarUploader < BaseUploader
  version(:medium) do
    cdn_transform(
      width: 100,
      height: 100,
      dpr: 2
    )
  end
end

> User.avatar.medium # CarrierWave::Uploader
> User.avatar.url # "https://s3.resume.io/users/avatar/1.jpg"
> User.avatar.medium_url   # "https://s3.resume.io/cdn-cgi/.../users/avatar/1.jpg"
> User.avatar.medium.url   # "https://s3.resume.io/cdn-cgi/.../users/avatar/1.jpg"
> User.avatar.url(:medium) # "https://s3.resume.io/cdn-cgi/.../users/avatar/1.jpg"
> User.avatar.medium.url(dpr: 1)
> User.avatar.resize(width: 1200, fit: :cover).url
```

### Options

Supported options:

`width`, `height`, `dpr`, `fit`, `gravity`, `quality`, `format`, `onerror`, `metadata`

See details in Cloudflare [documentation](https://developers.cloudflare.com/images/about)


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/resume-io/carrierwave-cloudflare. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/resume-io/carrierwave-cloudflare/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Carrierwave::Cloudflare project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/resume-io/carrierwave-cloudflare/blob/master/CODE_OF_CONDUCT.md).
