# CarrierWave::Cloudflare

[![Tests](https://github.com/resume-io/carrierwave-cloudflare/actions/workflows/run-specs.yml/badge.svg?branch=master)](https://github.com/resume-io/carrierwave-cloudflare/actions/workflows/run-specs.yml)
[![Gem Version](https://badge.fury.io/rb/carrierwave-cloudflare.svg)](https://badge.fury.io/rb/carrierwave-cloudflare)

This gem integrates CarrierWave with [Cloudflare Image Resizing](https://developers.cloudflare.com/images/image-resizing)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'carrierwave-cloudflare'
```

And then execute:

    $ bundle install

Or install it yourself with:

    $ gem install carrierwave-cloudflare

## Usage

Include `CarrierWave::Cloudflare` in your base uploader

```ruby
class BaseUploader < CarrierWave::Uploader::Base
  include CarrierWave::Cloudflare
end
```

Use `cdn_transform` to define Cloudflare's version (this means that now the file will not be stored on a server, but will be transformed on the Cloudflare side)

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

See details in Cloudflare's [documentation](https://developers.cloudflare.com/images/url-format)

You can also define default options (supports all options described above)

```ruby
class BaseUploader < CarrierWave::Uploader::Base
  default_cdn_options format: :auto
end
```

### In development env

In development you don't need to generate URLs for Cloudflare, because they will not work and therefore you need to disable the Cloudflare transform

``` ruby
CarrierWave::Cloudflare.configure do |config|
  config.cloudflare_transform(false)
end
```

`cloudflare_transform: false` disables links generation and puts all Cloudflare's arguments into query string (for easy debugging)
```
/1.jpg?cdn-cgi=width-11.height-300.fit-pad
```

## Rails views helpers

### cdn_transformed(url, **options)
Returns an image URL with CDN transformations applied. Can process already transformed URLs, in that case the options will be merged together.

```ruby
cdn_transformed('/img.jpg', width: 400)
# => '/cdn-cgi/image/width=400/img.jpg'

cdn_transformed('/cdn-cgi/image/width=100,fit=pad/img.jpg', width: 333)
# => '/cdn-cgi/image/width=333,fit=pad/img.jpg'
```


### hidpi_image_tag(url, dprs: nil, **options)

Returns an image tag with scaled variations (via `srcset`) attribute for devices with different DPR values.


The transformation of the original image should be specified via options.

```ruby
hidpi_image_tag('/bird.jpg', width: 400, drps: [1, 2])
# => <img srcset="/cdn-cgi/image/width=400,dpr=1/img.jpg 1x, /cdn-cgi/image/width=400,dpr=2/img.jpg 2x" src="/cdn-cgi/image/width=400/img.jpg" />
```


### responsive_image_tag(url, width:, sizes: nil, dprs: [1, 2], **options)

Returns a reponsive image tag with variations.

```ruby
responsive_image_tag('/bird.jpg', width: 1200, sizes: { phone: 600, tablet: 800 })

# => <img srcset="/cdn-cgi/image/width=1200,dpr=0.5/bird.jpg 600w,
#                  /cdn-cgi/image/width=1200,dpr=1.0/bird.jpg 1200w,
#                  /cdn-cgi/image/width=1200,dpr=0.67/bird.jpg 800w,
#                  /cdn-cgi/image/width=1200,dpr=1.33/bird.jpg 1600w,
#                  /cdn-cgi/image/width=1200,dpr=2.0/bird.jpg 2400w"
#                  sizes="(max-width: 767px) 600px, (max-width: 1023px) 800px, 1200px"
#                  src="/cdn-cgi/image/width=1200/bird.jpg" />

```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

This project is licensed and distributed under the terms of the [MIT license](https://github.com/resume-io/carrierwave-cloudflare/blob/master/LICENSE.txt). 
