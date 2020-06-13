module Deflate
  class BitIO
    def initialize(io)
      @io = io
      @bits = 0
      @bitfield = 0x0
    end

    # move ahead to the start of the next byte
    def align
      read_bits(@bits & 0x7)
    end

    def read_uint8
      read_bits(8)
    end

    def read_uint16
      read_bits(16)
    end

    def read_bit
      read_bits(1)
    end

    def read_bit_bool
      read_bits(1) == 1
    end

    def eof?
      @io.eof?
    end

    def peek_bits(n)
      needbits(n) if n > @bits

      # normal
      @bitfield & mask(n)

      # reverse
      #(@bitfield >> (@bits - n)) & mask(n)
    end

    def read_bits(n)
      needbits(n) if n > @bits

      # normal
      r = @bitfield & mask(n)
      @bits -= n
      @bitfield >>= n

      # reverse
      #r = (@bitfield >> (@bits - n)) & mask(n)
      #@bits -= n
      #@bitfield &= ~(mask(n) << @bits)
      r
    end

    private

    def mask(n)
      (1 << n) - 1
    end

    def more
      # TODO is raise really what we want?
      raise "EOF" if @io.eof?
      c = @io.read(1)

      # normal
      @bitfield += c.ord << @bits
      @bits += 8

      # reverse
      #@bitfield <<= 8
      #@bitfield += c.ord
      #@bits += 8
    end

    def needbits(n)
      while @bits < n
        more
      end
    end
  end
end
