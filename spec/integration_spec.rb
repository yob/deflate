require 'rspec'

RSpec.describe "Integration" do
  let(:bitio) { Deflate::BitIO.new(input)}

  # hello-world.z is:
  #
  # * zlib container format
  # * a single deflate block, encoding type 1 (static huffman)
  context "with hello-world.z" do
    let(:path) { File.join(File.expand_path(File.dirname(__FILE__)), "fixtures", "hello-world.z") }

    it "can decompress the file" do
      File.open(path, "rb") do |io|
        file = Deflate::File.new(io)
        expect(file.out).to eql("hello world\n")
      end
    end
  end

  # hello-world-multiple-blocks.z is:
  #
  # * zlib container format
  # * multiple deflate blocks, encoding type 0 (no compression) and 1 (static huffman)
  context "with hello-world-multiple-blocks.z" do
    let(:path) { File.join(File.expand_path(File.dirname(__FILE__)), "fixtures", "hello-world-multiple-blocks.z") }

    it "can decompress the file" do
      File.open(path, "rb") do |io|
        file = Deflate::File.new(io)
        expect(file.out).to eql("hello world, 2020 is quite the year")
      end
    end
  end

  # lorem-ipsum.z is:
  #
  # * zlib container format
  # * a single deflate block, encoding type 2 (dynamic huffman)
  context "with lorem-ipsum.z" do
    let(:path) { File.join(File.expand_path(File.dirname(__FILE__)), "fixtures", "lorem-ipsum.z") }

    it "can decompress the file" do
      File.open(path, "rb") do |io|
        file = Deflate::File.new(io)
        expect(file.out).to eql("hello world\n")
      end
    end
  end
end
