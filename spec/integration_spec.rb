require 'rspec'

RSpec.describe "Integration" do
  let(:bitio) { Deflate::BitIO.new(input)}
  let(:output) { 
    File.open(path, "rb") do |io|
      Deflate::File.inflate(io)
    end
  }

  # hello-world.z is:
  #
  # * zlib container format
  # * a single deflate block, encoding type 1 (static huffman)
  context "with hello-world.z" do
    let(:path) { File.join(File.expand_path(File.dirname(__FILE__)), "fixtures", "hello-world.z") }

    it "can decompress the file" do
      expect(output).to eql("hello world\n")
    end
  end

  # hello-world-multiple-blocks.z is:
  #
  # * zlib container format
  # * multiple deflate blocks, encoding type 0 (no compression) and 1 (static huffman)
  context "with hello-world-multiple-blocks.z" do
    let(:path) { File.join(File.expand_path(File.dirname(__FILE__)), "fixtures", "hello-world-multiple-blocks.z") }

    it "can decompress the file" do
      expect(output).to eql("hello world, 2020 is quite the year")
    end
  end

  # hello-world-no-compression.z is:
  #
  # * zlib container format
  # * a single deflate block, encoding type 0 (no compression)
  context "with hello-world-no-compression.z" do
    let(:path) { File.join(File.expand_path(File.dirname(__FILE__)), "fixtures", "hello-world-no-compression.z") }

    it "can decompress the file" do
      expect(output).to eql("hello world, 2020 is quite the year")
    end
  end

  # lorem-ipsum.z is:
  #
  # * zlib container format
  # * a single deflate block, encoding type 2 (dynamic huffman)
  context "with lorem-ipsum.z" do
    let(:path) { File.join(File.expand_path(File.dirname(__FILE__)), "fixtures", "lorem-ipsum.z") }
    let(:result_path) { File.join(File.expand_path(File.dirname(__FILE__)), "fixtures", "lorem-ipsum.txt") }
    let(:uncompressed_text) { File.read(result_path) }

    it "can decompress the file" do
      expect(output).to eql(uncompressed_text)
    end
  end
end
