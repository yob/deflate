module Deflate
  class File

    attr_reader :compression_info, :compression_method, :compression_level, :has_dict
    attr_reader :checksum

    def initialize(io)
      @io = io
      @stream = BitIO.new(@io)

      # The header on a zlib container file is 2-bytes
      read_header
    end

    def self.inflate(io)
      file = self.new(io)
      output = StringIO.new
      file.each_block do |block|
        output << block.output
      end
      output.string
    end

    def each_block(&block)
      raise ArgumentError "Input file has already been processed" if @stream.eof?

      DeflateStream.new(@stream).each_block do |block|
        yield block
      end
    end

    def window_size
      if compression_method == 8
        2**(compression_info+8)
      else
        nil
      end
    end

    private

    def read_header
      @compression_method = @stream.read_bits(4)
      @compression_info = @stream.read_bits(4)

      @checksum = @stream.read_bits(5)
      @has_dict = @stream.read_bit_bool
      @compression_level = @stream.read_bits(2)

      if @has_dict
        raise "Can't process files that require a dict"
      end
    end

  end
end
