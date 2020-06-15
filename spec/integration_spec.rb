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
  # * only literals are encoded in the huffman table, no length/distance pairs
  context "with hello-world.z" do
    let(:path) { File.join(File.expand_path(File.dirname(__FILE__)), "fixtures", "hello-world.z") }

    it "can decompress the file" do
      expect(output).to eql("hello world\n")
    end
  end

  # gemfile.z is:
  #
  # * zlib container format
  # * a single deflate block, encoding type 1 (static huffman)
  # * huffman table has a mixture of literals and length/distance pairs
  context "with gemfile.z" do
    let(:path) { File.join(File.expand_path(File.dirname(__FILE__)), "fixtures", "gemfile.z") }

    it "can decompress the file" do
      expect(output).to eql("source \"https://rubygems.org\"\n\ngemspec\n")
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

  # hello-world-multiple-blocks.deflate is:
  #
  # * raw deflate (RFC1951) blocks, no container
  context "with hello-world-multiple-blocks.deflate" do
    let(:path) { File.join(File.expand_path(File.dirname(__FILE__)), "fixtures", "hello-world-multiple-blocks.deflate") }
    let(:uncompressed_text) { "hello world, 2020 is quite the year" }

    it "can decompress the file" do
      pending
      expect(output).to eql(uncompressed_text)
    end
  end

  # hello-world,gz is:
  #
  # * gzip container format
  context "with hello-world.gz" do
    let(:path) { File.join(File.expand_path(File.dirname(__FILE__)), "fixtures", "hello-world.gz") }
    let(:uncompressed_text) { "hello world, 2020 is quite the year" }

    it "can decompress the file" do
      pending
      expect(output).to eql(uncompressed_text)
    end
  end
end
