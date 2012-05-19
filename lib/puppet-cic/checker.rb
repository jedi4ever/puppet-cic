require 'lib/puppet-cic/repo/mercurial'
require 'lib/puppet-cic/repo/git'
require 'lib/puppet-cic/catalog'

module PuppetCic
  class Checker

    attr_accessor :modulepath, :manifestdir, :manifest
    attr_accessor :repodir , :repotype , :from , :to
    attr_accessor :factsfile

    attr_reader :repo

    def initialize(options)
      # Get information about the puppet structure
      @modulepath = File.expand_path(options['modulepath'])
      @manifestdir = File.expand_path(options['manifestdir'])
      @manifest = File.expand_path(options['manifest'])

      # Get information about the repo containing the puppet tree
      @repodir = options['repodir']
      @repotype = options['repotype']
      @from = options['from']
      @to = options['to']

      # Get the role yaml file containing the facts
      @factsfile = options['factsfile']

      # Initialize a repo object
      @repo = case @repotype
              when "mercurial" then ::PuppetCic::Repo::Mercurial.new(@repodir)
              when "git" then ::PuppetCic::Repo::Git.new(@repodir)
              else puts "Unknown repotype"; exit -1
              end
      @catalog = ::PuppetCic::Catalog.new(@modulepath,@manifestdir,@manifest)

    end

    def check

      begin
        facts = YAML::load(File.open(@factsfile))
      rescue Exception => ex
        puts "Error opening factsfile '#{@factsfile}'\n=> #{ex}"
        exit -1
      end

      change_needed = false

      changeset = @repo.changeset(@from, @to)
      puts
      puts "Modules changed by changeset #{changeset.from} to #{changeset.to}:"
      changeset_modules = changeset.modules
      changeset_modules.each do |name|
        puts "- #{name}"
      end
      puts

      puts "Libs changed by changeset #{changeset.from} to #{changeset.to}:"
      changeset.libs.each do |name|
        puts "- #{name}"
      end
      puts

      puts "Given facts:"
      facts.each do |name,value|
        puts "- #{name}: #{value}"
        #puts name.is_a?(Symbol)
      end
      puts

      puts "Modules in current catalog:"
      catalog_modules = @catalog.modules(facts)
      catalog_modules.each do |name|
        puts "- #{name}"
      end
      puts

      change_needed = true unless changeset.libs.empty?
      changeset_modules.each do |name|
        if catalog_modules.include?(name)
          change_needed = true
        end
      end
      puts "Changed needed? #{change_needed}"

    end
  end
end
