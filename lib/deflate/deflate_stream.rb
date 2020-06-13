module Deflate
  class DeflateBlock
    attr_reader :last_block, :encoding_method
    attr_accessor :output

    def initialize(last_block, encoding_method)
      @last_block, @encoding_method = last_block, encoding_method
      @output = ""
    end

  end

  class DeflateStream
    CODE_LENGTH_ORDERS = [16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15]
    DISTANCE_BASE = [1,2,3,4,5,7,9,13,17,25,33,49,65,97,129,193,257,385,513,769,1025,1537,2049,3073,4097,6145,8193,12289,16385,24577]
    LENGTH_BASE = [3,4,5,6,7,8,9,10,11,13,15,17,19,23,27,31,35,43,51,59,67,83,99,115,131,163,195,227,258]
    EXTRA_LENGTH_BITS = {
      257 => 0,
      258 => 0,
      259 => 0,
      260 => 0,
      261 => 0,
      262 => 0,
      263 => 0,
      264 => 0,
      265 => 1,
      266 => 1,
      267 => 1,
      268 => 1,
      269 => 2,
      270 => 2,
      271 => 2,
      272 => 2,
      273 => 3,
      274 => 3,
      275 => 3,
      276 => 3,
      277 => 4,
      278 => 4,
      279 => 4,
      280 => 4,
      281 => 5,
      282 => 5,
      283 => 5,
      284 => 5,
      285 => 0,
    }
    EXTRA_DISTANCE_BITS = {
      0  => 0,
      1  => 0,
      2  => 0,
      3  => 0,
      4  => 1,
      5  => 1,
      6  => 2,
      7  => 2,
      8  => 3,
      9  => 3,
      10 => 4,
      11 => 4,
      12 => 5,
      13 => 5,
      14 => 6,
      15 => 6,
      16 => 7,
      17 => 7,
      18 => 8,
      19 => 8,
      20 => 9,
      21 => 9,
      22 => 10,
      23 => 10,
      24 => 11,
      25 => 11,
      26 => 12,
      27 => 12,
      28 => 13,
      29 => 13,
    }

    def initialize(stream)
      @stream = stream
    end

    def each_block(&block)
      @out = ""

      loop do
        last_block = @stream.read_bit_bool
        encoding_method = @stream.read_bits(2)
        output_start_pos = @out.bytesize
        result_block = DeflateBlock.new(last_block, encoding_method)
        if encoding_method == 0 # No compression
          @stream.align # consume the remaining bits of the current byte
          len = @stream.read_uint16
          nlen = @stream.read_uint16
          # TODO confirm len and nlen match
          len.times do
            @out += @stream.read_bits(8).chr
          end
        elsif encoding_method == 1 || encoding_method == 2

          main_literals = nil
          main_distances = nil

          if encoding_method == 1 # Static Huffman
            main_literals = HuffmanTable.new(
              {(0..143) => 8, (144..255) => 9, (256..279) => 7, (280..287) => 8}
            )
            main_distances = HuffmanTable.new({(0..31) => 5})
          elsif encoding_method == 2 # Dynamic Huffman
            literals = @stream.read_bits(5) + 257
            distances = @stream.read_bits(5) + 1
            code_lengths_length = @stream.read_bits(4) + 4

            l = [0] * 19
            code_lengths_length.times do |i|
              l[CODE_LENGTH_ORDERS[i]] = @stream.read_bits(3)
            end
            bootstrap = {}
            l.each_with_index do |length, i|
              bootstrap[(i..i)] = length
            end
            dynamic_codes = HuffmanTable.new(bootstrap)

            code_lengths = []

            while code_lengths.size < (literals + distances) do
              symbol = dynamic_codes.lookup(@stream)

              if symbol >= 0 && symbol <= 15
                code_lengths << symbol
              elsif symbol == 16 # repeast the last code 3-6 times
                last_length = code_lengths.last
                (@stream.read_bits(2) + 3).times do
                  code_lengths << last_length
                end
              elsif symbol == 17 # repeat code length 0 3-10 times
                (@stream.read_bits(3) + 3).times do
                  code_lengths << 0
                end
              elsif symbol == 18 # repeat code length 0 11-138 times
                (@stream.read_bits(7) + 11).times do
                  code_lengths << 0
                end
              else
                raise "unexpected code lenght. #{symbol} should be <= 17"
              end

            end
            main_literals_bootstrap = {}
            code_lengths[0,literals].each_with_index do |length, i|
              main_literals_bootstrap[(i..i)] = length
            end
            main_literals = HuffmanTable.new(main_literals_bootstrap)

            main_distances_bootstrap = {}
            code_lengths[literals, code_lengths.size].each_with_index do |length, i|
              main_distances_bootstrap[(i..i)] = length
            end
            main_distances = HuffmanTable.new(main_distances_bootstrap)
          end

          loop do
            symbol = main_literals.lookup(@stream)

            if symbol < 256
              @out += symbol.chr
            elsif symbol == 256
              break # end of the block
            elsif symbol >= 257 && symbol <= 285
              length_extra = @stream.read_bits(EXTRA_LENGTH_BITS.fetch(symbol, 0))
              length = LENGTH_BASE[symbol-257] + length_extra

              symbol_distance = main_distances.lookup(@stream)
              if symbol_distance && symbol_distance >= 0 && symbol_distance <= 29
                distance = DISTANCE_BASE[symbol_distance] + @stream.read_bits(EXTRA_DISTANCE_BITS.fetch(symbol_distance))
                @out += @out[-distance, length]
              else
                raise "unexpected distance value (#{symbol_distance})"
              end
            else
              raise "unexpected literal value (#{symbol})"
            end
          end
        else
          raise "Can't process blocks of type #{encoding_method} yet"
        end
        result_block.output = @out[output_start_pos..]
        yield result_block
        break if last_block
      end
    end
  end
end
