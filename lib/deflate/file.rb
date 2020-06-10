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

      last_block = stream.read_bit1_bool
      encoding_method = stream.read_bit2

      @out = ""

      if encoding_method == 1 || encoding_method == 2

        if encoding_method == 1 # Static Huffman
          main_literals = HuffmanTable.new(
            {(0..143) => 8, (144..255) => 9, (256..279) => 7, (280..287) => 8}
          )
          main_distances = HuffmanTable.new({(0..31) => 5})

          loop do
            symbol = nil
            if symbol = main_literals.lookup(stream.peek_bit7, 7)
              stream.read_bit7 # consume bits
            elsif symbol = main_literals.lookup(stream.peek_bit8, 8)
              stream.read_bit8 # consume bits
            elsif symbol = main_literals.lookup(stream.peek_bit9, 9)
              stream.read_bit9 # consume bits
            else
              $stderr.puts "no matching symbol in table"
              exit
            end
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
          raise "Can't process blocks of type #{encoding_method} yet"
          #literals = stream.read_bit5 + 257
          #distances = stream.read_bit5 + 1
          #code_lengths_length = stream.read_bit4 + 4
          #puts "literals: #{literals}"
          #puts "distances: #{distances}"
          #puts "code_lengths_length: #{code_lengths_length}"

          #l = [0] * 19
          #(0..code_lengths_length).each do |i|
          #  l[CODE_LENGTH_ORDERS[i]] = stream.read_bit3
          #end
          #puts l.inspect
        end
      else
        raise "Can't process blocks of type #{encoding_method} yet"
      end
    end
  end
end
