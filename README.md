# Carrierwave::Cloudflare

This gem provides a simple wrapper for transformation images via Cloudflare

<img src="img/logo.svg" align="right" width="300" >

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

Use `cdn_transform` for define Cloudflare's version (this means that now the file will not be stored on the, but will be transformed on the cloudflare side)

```ruby
class AvatarUploader < BaseUploader
  version(:medium) do
    cdn_transform width: 100, height: 100, dpr: 2
  end
end

user = User.find(some_id)
user.avatar.medium # CarrierWave::Uploader
user.avatar.url # "https://s3.your-website.com/users/avatar/1.jpg"
user.avatar.medium_url   # "https://s3.your-website.com/cdn-cgi/width=100,height=100,dpr=2/users/avatar/1.jpg"
user.avatar.url(:medium) # "https://s3.your-website.com/cdn-cgi/width=100,height=100,dpr=2/users/avatar/1.jpg"
user.avatar.medium.url(dpr: 1) # "https://s3.your-website.com/cdn-cgi/width=100,height=100,dpr=1/users/avatar/1.jpg"
user.avatar.resize(width: 1200, fit: :cover).url # "https://s3.your-website.com/cdn-cgi/width=1200,height=100,dpr=2,fit=cover/users/avatar/1.jpg"
```

### Options

Supported options:

`width`, `height`, `dpr`, `fit`, `gravity`, `quality`, `format`, `onerror`, `metadata`

See details in Cloudflare [documentation](https://developers.cloudflare.com/images/about)

Also, you can define default options (supports all options described above)

```ruby
class BaseUploader < CarrierWave::Uploader::Base
  default_cdn_options format: :auto
end
```

### In development env

In development, you don't need to generate URLs for Cloudflare, because they will not work and therefore you need to disable the Cloudflare transform

``` ruby
CarrierWave::Cloudflare.configure do |config|
  config.cloudflare_transform(false)
end
```

`cloudflare_transform: false` disables links generation and put all Cloudflare's arguments into query string (for easy debugging)

e.g:

```
/1.jpg?cdn-cgi=width-11.height-300.fit-pad
```

## Rails views helpers

### cdn_transformed(url, **options)
  Returns an image URL with CDN transformations applied. Can process already transformed URLs, in that case the options will be merged together.

```

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
