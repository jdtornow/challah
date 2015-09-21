module Challah
  unless defined?(Challah::VERSION)
    VERSION = File.read(File.expand_path('../../../VERSION', __FILE__)).strip.freeze
  end
end
