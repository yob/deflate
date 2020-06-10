require 'rspec'

RSpec.describe "Integration" do
  let(:bitio) { Deflate::BitIO.new(input)}

  context "with hello-world.z" do
    let(:path) { File.join(File.expand_path(File.dirname(__FILE__)), "fixtures", "hello-world.z") }

    it "can decompress the file" do
      File.open(path, "rb") do |io|
        file = Deflate::File.new(io)
        expect(file.out).to eql("hello world\n")  
      end
    end
  end
end
