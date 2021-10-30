# frozen_string_literal: true

require "spec_helper"

RSpec.describe CarrierWave::Cloudflare do
  let(:dummy_uploader) do
    Class.new(CarrierWave::Uploader::Base) do
      include CarrierWave::Cloudflare

      default_cdn_options format: :auto, height: 200

      version :virtual_version do
        cdn_transform width: 900, height: 900
      end
    end
  end

  let(:uploader) { dummy_uploader.new }

  after do
    Object.send(:remove_const, "DummyUploader") if defined?(::DummyUploader)
    FileUtils.rm_rf(File.join(uploaders_folder, cache_id))
  end

  let(:root) { File.expand_path("../../", __dir__) }

  let(:test_file) do
    File.open(
      File.join(root, "spec/fixtures", test_file_name)
    )
  end

  let(:uploaders_folder) { File.join(root, "uploads", "tmp") }

  let(:test_file_name) { "test_img.jpg" }

  let(:cache_id) { "1369894322-345-1234-2255" }

  before { allow(CarrierWave).to receive(:generate_cache_id).and_return(cache_id) }

  describe "#url" do
    subject { uploader.path }

    before { uploader.cache!(test_file) }

    it "parent version is stored" do
      is_expected.to eq(File.join(uploaders_folder, cache_id, test_file_name).to_s)
    end

    describe "(:virtual_version)" do
      subject(:url) { uploader.url(:virtual_version) }

      it "returns url with cloduflare preview query" do
        is_expected.to eql("/uploads/tmp/#{cache_id}/#{test_file_name}?cdn-cgi=width-900.height-900.format-auto")
      end

      it "file is not created" do
        expect(uploader.virtual_version.path).to be_nil
      end

      context "when cloudflare_transform is true" do
        before do
          allow(CarrierWave::Cloudflare).to receive(:cloudflare_transform).and_return(true)
        end

        it "returns url with cloduflare params" do
          is_expected.to eql("/cdn-cgi/image/width=900,height=900,format=auto/uploads/tmp/#{cache_id}/#{test_file_name}")
        end
      end
    end
  end

  describe "#retrieve_from_cache!" do
    it "does nothing" do
      uploader.virtual_version.retrieve_from_cache!(cache_id)

      expect(uploader.virtual_version.path).to be_nil
    end
  end

  describe "#retrieve_from_store!" do
    it "does nothing" do
      uploader.virtual_version.retrieve_from_store!(cache_id)

      expect(uploader.virtual_version.path).to be_nil
    end
  end

  describe ".default_cdn_options" do
    it "just returns default options" do
      expect(dummy_uploader.default_cdn_options).to eql(format: :auto, height: 200)
    end
  end

  describe ".reset_default_options!" do
    let(:another_dummy_uploader) do
      Class.new(dummy_uploader) do
        reset_default_options!

        version :virtual_version do
          cdn_transform width: 900, height: 900
        end
      end
    end

    it "resets default options inherited from parent class" do
      expect(another_dummy_uploader.default_cdn_options).to eql({})
    end
  end
end
