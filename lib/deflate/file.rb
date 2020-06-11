module Deflate
  class File
    CODE_LENGTH_ORDERS = [16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15]

    attr_reader :compression_info, :compression_method, :compression_level, :has_dict
    attr_reader :checksum, :out

    def initialize(io)
      @io = io

      # loading everything into memory isn't what I ultimately want to do, but it's an easy
      # way to get started
      read_input_stream
    end

    def window_size
      if compression_method == 8
        2**(compression_info+8)
      else
        nil
      end
    end

    private

    def read_input_stream
      stream = BitIO.new(@io)

      @compression_method = stream.read_bit4
      @compression_info = stream.read_bit4

      @checksum = stream.read_bit5
      @has_dict = stream.read_bit1_bool
      @compression_level = stream.read_bit2

      if @has_dict
        raise "Can't process files that require a dict"
      end

      @out = ""

      loop do
        last_block = stream.read_bit1_bool
        encoding_method = stream.read_bit2
        if encoding_method == 0 # No compression
          stream.align # consume the remaining bits of the current byte
          len = stream.read_uint16
          nlen = stream.read_uint16
          # TODO confirm len and nlen match
          len.times do
            @out += stream.read_bit8.chr
          end
        elsif encoding_method == 1 || encoding_method == 2

          if encoding_method == 1 # Static Huffman
            main_literals = HuffmanTable.new(
              {(0..143) => 8, (144..255) => 9, (256..279) => 7, (280..287) => 8}
            )
            main_distances = HuffmanTable.new({(0..31) => 5})

            loop do
              symbol = main_literals.lookup(stream)
              if symbol < 256
                @out += symbol.chr
              elsif symbol == 256
                break # end of the block
              elsif symbol >= 257 && symbol <= 285
                # TODO implment reading data from earlier in the output stream
                $stderr.puts "reading data from earlier in the output stream not implemented yet"
              else
                $stderr.puts "unexpected literal value #{symbol}"
              end
              break if stream.eof?
            end
          elsif encoding_method == 2 # Dynamic Huffman
            literals = stream.read_bit5 + 257
            distances = stream.read_bit5 + 1
            code_lengths_length = stream.read_bit4 + 4

            l = [0] * 19
            code_lengths_length.times do |i|
              l[CODE_LENGTH_ORDERS[i]] = stream.read_bit3
            end
            l[14] = 0 # TODO remove?
            bootstrap = {}
            l.each_with_index do |length, i|
              bootstrap[(i..i)] = length
            end
            dynamic_codes = HuffmanTable.new(bootstrap)

            code_lengths = []

            while code_lengths.size < (literals + distances) do
              symbol = dynamic_codes.lookup(stream)

              if symbol >= 0 && symbol <= 15
                code_lengths << symbol
              elsif symbol == 16 # repeast the last code 3-6 times
                last_length = code_lengths.last
                (stream.read_bit2 + 3).times do
                  code_lengths << last_length
                end
              elsif symbol == 17 # repeat code length 0 3-10 times
                (stream.read_bit3 + 3).times do
                  code_lengths << 0
                end
              elsif symbol == 18 # repeat code length 0 11-138 times
                (stream.read_bit7 + 11).times do
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
            code_lengths[literals,literals.size].each_with_index do |length, i|
              main_distances_bootstrap[(i..i)] = length
            end
            main_distances = HuffmanTable.new(main_distances_bootstrap)
            loop do
              symbol = main_literals.lookup(stream)

              if symbol < 256
                @out += symbol.chr
              elsif symbol == 256
                break # end of the block
              elsif symbol >= 257 && symbol <= 285
                # TODO implment reading data from earlier in the output stream
                raise "reading data from earlier in the output stream not implemented yet"
              else
                raise "unexpected literal value #{symbol}"
              end
            end
          end
        else
          raise "Can't process blocks of type #{encoding_method} yet"
        end
        break if last_block
      end
    end
  end
end
