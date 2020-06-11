module Deflate
  class BitIO
    def initialize(io)
      @io = io
      @bits = 0
      @bitfield = 0x0
    end

    # move ahead to the start of the next byte
    def align
      readbits(@bits & 0x7)
    end

    def read_uint8
      readbits(8)
    end

    def read_uint16
      readbits(16)
    end

    def read_bit1
      readbits(1)
    end

    def read_bit1_bool
      readbits(1) == 1
    end

    def read_bit2
      readbits(2)
    end

    def read_bit3
      readbits(3)
    end

    def read_bit4
      readbits(4)
    end

    def read_bit5
      readbits(5)
    end

    def read_bit7
      readbits(7)
    end

    def read_bit8
      readbits(8)
    end

    def read_bit9
      readbits(8) # TODO fix me
    end

    def peek_bit7
      peekbits(7)
    end

    def peek_bit8
      peekbits(8)
    end

    def peek_bit9
      peekbits(8) # TODO fix me
    end

    def eof?
      @io.eof?
    end

    private

    def peekbits(n)
      if n > @bits
        needbits(n)
      end

      # normal
      @bitfield & mask(n)

      # reverse
      #(@bitfield >> (@bits - n)) & mask(n)
    end

    def readbits(n)
      if n > @bits
        needbits(n)
      end

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
