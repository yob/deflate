require 'rspec'

RSpec.describe Deflate::BitIO do
  let(:bitio) { Deflate::BitIO.new(input)}

  describe "#align" do
    it "consumes the remaining bits in the current byte"
  end

  describe "#read_uint8" do
    let(:input) { StringIO.new("\x00\x7F\xFF") }

    it "reads the next 8 bits and interprets them as an unsigned int" do
      expect(bitio.read_uint8).to eql(0)
      expect(bitio.read_uint8).to eql(127)
      expect(bitio.read_uint8).to eql(255)
    end
  end

  describe "#read_uint16" do
    let(:input) { StringIO.new("\x00\x7F\xFF") }

    it "reads the next 2 bytes and interprets them as an unsigned int"
  end

  describe "#read_bit_bool" do
    let(:input) { StringIO.new("\x7F") }

    it "reads the next byte right-left, returning the bits as true or false" do
      expect(bitio.read_bit_bool).to eql(true)
      expect(bitio.read_bit_bool).to eql(true)
      expect(bitio.read_bit_bool).to eql(true)
      expect(bitio.read_bit_bool).to eql(true)
      expect(bitio.read_bit_bool).to eql(true)
      expect(bitio.read_bit_bool).to eql(true)
      expect(bitio.read_bit_bool).to eql(true)
      expect(bitio.read_bit_bool).to eql(false)
    end
  end

  describe "#read_bits" do
    context "reading 1 bit" do
      let(:input) { StringIO.new("\x7F") }

      it "reads the next byte right-left, returning the bits as 1 or 0" do
        expect(bitio.read_bits(1)).to eql(1)
        expect(bitio.read_bits(1)).to eql(1)
        expect(bitio.read_bits(1)).to eql(1)
        expect(bitio.read_bits(1)).to eql(1)
        expect(bitio.read_bits(1)).to eql(1)
        expect(bitio.read_bits(1)).to eql(1)
        expect(bitio.read_bits(1)).to eql(1)
        expect(bitio.read_bits(1)).to eql(0)
      end
    end

    describe "reading 2 bits" do
      let(:input) { StringIO.new("\x7F") }

      it "reads the next byte right-left, returning the bits as 0-3" do
        expect(bitio.read_bits(2)).to eql(3)
        expect(bitio.read_bits(2)).to eql(3)
        expect(bitio.read_bits(2)).to eql(3)
        expect(bitio.read_bits(2)).to eql(1)
      end
    end

    describe "reading 3 bits" do
      let(:input) { StringIO.new("\x7F") }

      it "reads the next byte right-left, returning the bits as 0-7" do
        expect(bitio.read_bits(3)).to eql(7)
        expect(bitio.read_bits(3)).to eql(7)
      end
    end

    describe "reading 4 bits" do
      let(:input) { StringIO.new("\x7F") }

      it "reads the next byte right-left, returning the bits as 0-15" do
        expect(bitio.read_bits(4)).to eql(15)
        expect(bitio.read_bits(4)).to eql(7)
      end
    end

    describe "reading 5 bits" do
      let(:input) { StringIO.new("\x7F") }

      it "reads the next byte right-left, returning the bits as 0-31" do
        expect(bitio.read_bits(5)).to eql(31)
      end
    end

    describe "reading 7 bits" do
      let(:input) { StringIO.new("\x7F") }

      it "reads the next byte right-left, returning the bits as 0-127" do
        expect(bitio.read_bits(7)).to eql(127)
      end
    end

    describe "reading 8 bits" do
      let(:input) { StringIO.new("\x7F") }

      it "reads the next byte right-left, returning the bits as 0-255" do
        expect(bitio.read_bits(8)).to eql(127)
      end
    end

    describe "reading 9 bits" do
      it "reads the next byte right-left, returning the bits as 0-512"
    end
  end

  describe "#peek_bits" do
    describe "peeking at 7 bits" do
      it "reads the next byte right-left, returning the bits as 0-127 without consuming input"
    end

    describe "peeking at 8 bits" do
      it "reads the next byte right-left, returning the bits as 0-255 without consuming input"
    end

    describe "peeking at 9 bits" do
      it "reads the next byte right-left, returning the bits as 0-511 without consuming input"
    end
  end

  describe "#eof?" do
    it "returns true if the input stream has been fully consumed"
  end
end
