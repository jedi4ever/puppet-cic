module PuppetCic
  class BaseRepo
    attr_reader :repodir

    def initialize(repodir)
      @repodir = repodir
    end

  end
end
