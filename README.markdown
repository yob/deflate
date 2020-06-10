# deflate

Experimenting with a pure ruby decompressor for the DEFLATE algorithm.

## Why?

The ruby stdlib comes with [bindings to
zlib](https://ruby-doc.org/stdlib-2.7.0/libdoc/zlib/rdoc/Zlib.html), which work
perfectly well for compressing and decompressing data using the DEFLATE
algorithm.

I was interested in learning more about the data formats though, so had a crack
at implementing a decompressor in pure ruby.

I'm not using this in the real world anywhere, and you probably shouldn't either.

The API is unstable - refer to `spec/integration_spec.rb` for examples.

## Further Reading

* Deflate data format: https://tools.ietf.org/html/rfc1951
* ZLib container format (using deflate): https://tools.ietf.org/html/rfc1950
* GZip container format (using deflate): https://tools.ietf.org/html/rfc1952
