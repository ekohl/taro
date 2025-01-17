# :nocov:
return unless defined?(::Rails)
# :nocov:

module Taro::Rails
  Dir[File.join(__dir__, "rails", "*.rb")].each { |f| require_relative f }

  extend ActiveDeclarations
  extend DeclarationBuffer

  def self.reset
    buffered_declarations.clear
    RouteFinder.clear_cache
    Taro.reset
  end
end
