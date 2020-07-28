# frozen_string_literal: true

require 'rails_helper'

describe CarrierWave::Cloudflare do
  let(:uploader) { DummyUploader.new }

  before do
    CarrierWave::Cloudflare.configure do |config|
      config.cloudflare_transform false
    end

    class DummyUploader < CarrierWave::Uploader::Base
      include CarrierWave::Cloudflare

      default_cdn_options format: :auto, height: 200

      version :virtual_version do
        cdn_transform width: 900, height: 900
      end
    end
  end

  after do
    Object.send(:remove_const, 'DummyUploader') if defined?(::DummyUploader)
    FileUtils.rm_rf(Rails.root.join(uploaders_folder, cache_id))
  end

  let(:test_file) { File.open(Rails.root.join(file_path, test_file_name)) }
  let(:file_path) { 'spec/fixtures/carrierwave_cloudflare' }
  let(:test_file_name) { 'test_img.jpg' }
  let(:uploaders_folder) { 'public/uploads/tmp' }

  let(:cache_id) { '1369894322-345-1234-2255' }

  before { allow(CarrierWave).to receive(:generate_cache_id).and_return(cache_id) }

  describe '#url' do
    subject { uploader.path }

    before { uploader.cache!(test_file) }

    it 'parent version is stored' do
      is_expected.to eql(Rails.root.join(uploaders_folder, cache_id, test_file_name).to_s)
    end

    describe '(:virtual_version)' do
      subject(:url) { uploader.url(:virtual_version) }

      it 'returns url with cloduflare preview query' do
        is_expected.to eql("/uploads/tmp/#{cache_id}/#{test_file_name}?cdn-cgi=width-900.height-900.format-auto")
      end

      it 'file is not created' do
        expect(uploader.virtual_version.path).to be_nil
      end

      context 'when preview query is true' do
        before do
          CarrierWave::Cloudflare.configure do |config|
            config.cloudflare_transform true
          end
        end

        it 'returns url with cloduflare params' do
          is_expected.to eql("/cdn-cgi/image/width=900,height=900,format=auto/uploads/tmp/#{cache_id}/#{test_file_name}")
        end
      end
    end
  end

  describe '#retrieve_from_cache!' do
    it 'does nothing' do
      uploader.virtual_version.retrieve_from_cache!(cache_id)

      expect(uploader.virtual_version.path).to be_nil
    end
  end

  describe '#retrieve_from_store!' do
    it 'does nothing' do
      uploader.virtual_version.retrieve_from_store!(cache_id)

      expect(uploader.virtual_version.path).to be_nil
    end
  end

  describe '.default_cdn_options' do
    it 'just returns default options' do
      expect(DummyUploader.default_cdn_options).to eql(format: :auto, height: 200)
    end
  end
end
