module Deflate
  class HuffmanLength
    attr_reader :symbol, :bit_count
    attr_accessor :code, :reverse_code
    def initialize(symbol:, bit_count:, code: nil)
      @symbol, @bit_count = symbol, bit_count
      @code = code
    end

    def <=>(other)
      if @bit_count == other.bit_count
        @symbol <=> other.symbol
      else
        @bit_count <=> other.bit_count
      end
    end

    def ==(other)
      @symbol  == other.symbol && @bit_count == other.bit_count && @code == other.code
    end
  end

  class HuffmanTable
    attr_reader :values

    def initialize(bootstrap)
      @values = []
      bootstrap.each do |symbol_range, bit_count|
        symbol_range.each do |symbol|
          @values << HuffmanLength.new(symbol: symbol, bit_count: bit_count)
        end
      end
      @values.sort
      populate_huffman_codes
    end

    def lookup(code, bit_count)
      result = @values.detect { |value|
        value.reverse_code == code && value.bit_count == bit_count
      }
      result && result.symbol
    end

    def inspect
      @values.inspect
    end

    private

    # reconstruct the bit codes for each value according it section 3.2.2
    # of https://tools.ietf.org/html/rfc1951
    def populate_huffman_codes
      bit_count_freq = Hash.new(0)
      @values.each do |value|
        bit_count_freq[value.bit_count] += 1
      end
      #puts bit_count_freq.inspect

      max_bit_count = bit_count_freq.keys.max
      next_code = Hash.new(0)

      #(0..max_bit_count).each do |bit_count|
      #  next_code[bit_count]
      #end
      code = 0
      (1..16).each do |bits|
          code = (code + bit_count_freq[bits - 1]) << 1;
          next_code[bits] = code;
      end
      #puts next_code.inspect

      @values.each do |value|
        value.code = next_code[value.bit_count]
        value.reverse_code = reverse_bits(next_code[value.bit_count], value.bit_count)
        next_code[value.bit_count] += 1
      end
    end

    def reverse_bits(code, bit_count)
      a = 1 << 0
      b = 1 << (bit_count - 1)
      z = 0
      i = bit_count - 1
      while i > -1 do
        z |= (code >> i) & a
        z |= (code << i) & b
        a <<= 1
        b >>= 1
        i -= 2
      end
      return z
    end
  end
end

