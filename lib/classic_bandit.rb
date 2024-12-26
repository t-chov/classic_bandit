# frozen_string_literal: true

require "zeitwerk"
require_relative "classic_bandit/version"

module ClassicBandit
  class Error < StandardError; end
  # Your code goes here...
end

loader = Zeitwerk::Loader.for_gem
loader.setup
loader.eager_load
