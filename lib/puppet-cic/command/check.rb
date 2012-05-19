require 'lib/puppet-cic/checker.rb'

module PuppetCic::Command

  def _check(options)

    checker = ::PuppetCic::Checker.new(options)
    checker.check
  end
end
