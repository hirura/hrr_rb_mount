require_relative 'lib/hrr_rb_mount/version'

Gem::Specification.new do |spec|
  spec.name          = "hrr_rb_mount"
  spec.version       = HrrRbMount::VERSION
  spec.authors       = ["hirura"]
  spec.email         = ["hirura@gmail.com"]

  spec.summary       = %q{A wrapper around mount and umount for CRuby}
  spec.description   = %q{A wrapper around mount and umount for CRuby}
  spec.homepage      = "https://github.com/hirura/hrr_rb_mount"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.0.0")

  spec.metadata["homepage_uri"] = spec.homepage
  #spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  #spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]
  spec.extensions    = ["ext/hrr_rb_mount/extconf.rb"]
end
