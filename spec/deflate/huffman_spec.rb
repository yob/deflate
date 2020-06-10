require 'rspec'

RSpec.describe Deflate::HuffmanTable do
  let(:table) { Deflate::HuffmanTable.new(bootstrap) }
  describe "#initialize" do

    # the example documented in 3.2.2 of RFC1951
    # https://tools.ietf.org/html/rfc1951
    context "with alphabet ABCDEFGH" do
      let(:bootstrap) {
        {(65..69) => 3, (70..70) => 2, (71..72) => 4}
      }

      it "sets values correctly" do
        expect(table.values).to eq(
          [
            Deflate::HuffmanLength.new(bit_count: 3, symbol: 65, code: 2),  # A   010
            Deflate::HuffmanLength.new(bit_count: 3, symbol: 66, code: 3),  # B   011
            Deflate::HuffmanLength.new(bit_count: 3, symbol: 67, code: 4),  # C   100
            Deflate::HuffmanLength.new(bit_count: 3, symbol: 68, code: 5),  # D   101
            Deflate::HuffmanLength.new(bit_count: 3, symbol: 69, code: 6),  # E   110
            Deflate::HuffmanLength.new(bit_count: 2, symbol: 70, code: 0),  # F    00
            Deflate::HuffmanLength.new(bit_count: 4, symbol: 71, code: 14), # G  1110
            Deflate::HuffmanLength.new(bit_count: 4, symbol: 72, code: 15), # H  1111
          ]
        )
      end
    end
  end
end
