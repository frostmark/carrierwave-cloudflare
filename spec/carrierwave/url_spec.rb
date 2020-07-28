# frozen_string_literal: true

require 'rails_helper'

describe CarrierWave::Cloudflare::URL do
  let(:subject) { described_class }

  before do
    CarrierWave::Cloudflare.configure do |config|
      config.cloudflare_transform true
    end
  end

  it 'formats cdn-cgi/ URL based on options provided' do
    result = subject.transform('http://r.io/images/1.jpg', width: 100)
    expect(result).to eq('http://r.io/cdn-cgi/image/width=100/images/1.jpg')
  end

  it 'supports relative URLs' do
    result = subject.transform('/1.jpg', width: 100)
    expect(result).to eq('/cdn-cgi/image/width=100/1.jpg')

    result = subject.transform('/home', width: 100)
    expect(result).to eq('/cdn-cgi/image/width=100/home')
  end

  it 'keeps the query params and other parts of the URL' do
    path = 'http://r.io/img.png?version=10#index'
    result = subject.transform(path, width: 100)

    expect(result).to eq('http://r.io/cdn-cgi/image/width=100/img.png?version=10#index')
  end

  it 'ignores non-existing options' do
    result = subject.transform('http://r.io/images/1.jpg', foo: :bar)
    expect(result).to eq('http://r.io/images/1.jpg')
  end

  it 'uses a canonical order of options' do
    result = subject.transform('http://r.io/images/1.jpg', height: 200, fit: :pad, width: 100)
    expect(result).to eq('http://r.io/cdn-cgi/image/width=100,height=200,fit=pad/images/1.jpg')
  end

  context 'when no options is given' do
    it 'returns URL as is' do
      result = subject.transform('http://r.io/images/1.jpg')
      expect(result).to eq('http://r.io/images/1.jpg')
    end
  end

  context 'when the URL is already transformed' do
    it 'merges the options' do
      path = 'http://r.io/cdn-cgi/image/width=400,fit=cover/img.jpg'
      result = subject.transform(path, fit: :pad, format: :auto)

      expect(result).to eq('http://r.io/cdn-cgi/image/width=400,fit=pad,format=auto/img.jpg')
    end
  end

  context 'in development mode' do
    before do
      CarrierWave::Cloudflare.configure do |config|
        config.cloudflare_transform false
      end
    end

    it 'uses a query string argument instead' do
      result = subject.transform('http://r.io/images/1.jpg', width: 100)
      expect(result).to eq('http://r.io/images/1.jpg?cdn-cgi=width-100')
    end

    it 'supports options merging' do
      result = subject.transform('/1.jpg?cdn-cgi=width-100.fit-pad', width: 11, height: 300)
      expect(result).to eq('/1.jpg?cdn-cgi=width-11.height-300.fit-pad')
    end
  end
end
