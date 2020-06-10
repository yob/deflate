Gem::Specification.new do |spec|
  spec.name = "deflate"
  spec.version = "0.0.1"
  spec.summary = "Decompress DEFLATE compressed files"
  spec.description = "Decompress DEFLATE compressed files"
  spec.license = "MIT"
  spec.files =  Dir.glob("{bin,lib}/**/**/*")
  spec.executables << "inspect"
  spec.extra_rdoc_files = %w{README.markdown MIT-LICENSE }
  spec.authors = ["James Healy"]
  spec.email   = ["james@yob.id.au"]
  spec.homepage = "https://github.com/yob/deflate"
  spec.required_ruby_version = ">=2.0"

  spec.add_development_dependency("rspec", "~> 3.8")
  spec.add_development_dependency("pry")
end
