require 'rspec'

RSpec.describe Deflate::BitIO do
  let(:bitio) { Deflate::BitIO.new(input)}

  describe "#read_uint8" do
    let(:input) { StringIO.new("\x00\x7F\xFF") }

    it "reads the next 8 bits and interprets them as an unsigned int" do
      expect(bitio.read_uint8).to eql(0)
      expect(bitio.read_uint8).to eql(127)
      expect(bitio.read_uint8).to eql(255)
    end
  end

  describe "#read_bit1" do
    let(:input) { StringIO.new("\x7F") }

    it "reads the next byte right-left, returning the bits as 1 or 0" do
      expect(bitio.read_bit1).to eql(1)
      expect(bitio.read_bit1).to eql(1)
      expect(bitio.read_bit1).to eql(1)
      expect(bitio.read_bit1).to eql(1)
      expect(bitio.read_bit1).to eql(1)
      expect(bitio.read_bit1).to eql(1)
      expect(bitio.read_bit1).to eql(1)
      expect(bitio.read_bit1).to eql(0)
    end
  end

  describe "#read_bit1_bool" do
    let(:input) { StringIO.new("\x7F") }

    it "reads the next byte right-left, returning the bits as true or false" do
      expect(bitio.read_bit1_bool).to eql(true)
      expect(bitio.read_bit1_bool).to eql(true)
      expect(bitio.read_bit1_bool).to eql(true)
      expect(bitio.read_bit1_bool).to eql(true)
      expect(bitio.read_bit1_bool).to eql(true)
      expect(bitio.read_bit1_bool).to eql(true)
      expect(bitio.read_bit1_bool).to eql(true)
      expect(bitio.read_bit1_bool).to eql(false)
    end
  end

  describe "#read_bit2" do
    let(:input) { StringIO.new("\x7F") }

    it "reads the next byte right-left, returning the bits as 0-3" do
      expect(bitio.read_bit2).to eql(3)
      expect(bitio.read_bit2).to eql(3)
      expect(bitio.read_bit2).to eql(3)
      expect(bitio.read_bit2).to eql(1)
    end
  end

  describe "#read_bit3" do
    let(:input) { StringIO.new("\x7F") }

    it "reads the next byte right-left, returning the bits as 0-7" do
      expect(bitio.read_bit3).to eql(7)
      expect(bitio.read_bit3).to eql(7)
    end
  end

  describe "#read_bit4" do
    let(:input) { StringIO.new("\x7F") }

    it "reads the next byte right-left, returning the bits as 0-15" do
      expect(bitio.read_bit4).to eql(15)
      expect(bitio.read_bit4).to eql(7)
    end
  end

  describe "#read_bit5" do
    let(:input) { StringIO.new("\x7F") }

    it "reads the next byte right-left, returning the bits as 0-31" do
      expect(bitio.read_bit5).to eql(31)
    end
  end

  describe "#read_bit7" do
    let(:input) { StringIO.new("\x7F") }

    it "reads the next byte right-left, returning the bits as 0-127" do
      expect(bitio.read_bit7).to eql(127)
    end
  end

  describe "#read_bit8" do
    let(:input) { StringIO.new("\x7F") }

    it "reads the next byte right-left, returning the bits as 0-255" do
      expect(bitio.read_bit8).to eql(127)
    end
  end

  describe "#read_bit9" do
    it "reads the next byte right-left, returning the bits as 0-512"
  end

  describe "#peek_bit7" do
    it "reads the next byte right-left, returning the bits as 0-127 without consuming input"
  end

  describe "#peek_bit8" do
    it "reads the next byte right-left, returning the bits as 0-255 without consuming input"
  end

  describe "#peek_bit9" do
    it "reads the next byte right-left, returning the bits as 0-511 without consuming input"
  end

  describe "#eof?" do
    it "returns true if the input stream has been fully consumed"
  end
end
