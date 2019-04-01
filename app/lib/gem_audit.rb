require 'bundler/audit/scanner'
require 'bundler/audit/database'

module Bundler
  module Audit
    class Scanner
      def initialize(lockfile)
        @database = Database.new
        @lockfile = LockfileParser.new(lockfile)
      end
    end
  end
end

class GemAudit
  def self.update
    Bundler::Audit::Database.update!(quiet: true)
  end

  def self.scan(file)
    results = []
    s = Bundler::Audit::Scanner.new(file)
    s.scan do |result|
      results << result
    end
  end
end
