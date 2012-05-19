require 'rubygems'
require 'bundler/setup'
require 'puppet-cic/command/check'

module PuppetCic
  class CLI < Thor

    include PuppetCic::Command

    desc "check", "Check if a role specified by a yaml file is impacted"
    method_option :repodir , :default => '.', :desc => "Directory where the repository is located"
    method_option :repotype , :default => 'mercurial', :desc => "Type of repository (mercurial)"
    method_option :role_file , :desc => "Yaml file that contains facts"
    method_option :modulepath , :default => "modules", :desc => "Path to the modules"
    method_option :manifestdir , :default => "manifests", :desc => "Path to manifests"
    method_option :manifest , :default => "site.pp", :desc => "Path to manifest"
    method_option :from, :desc => "From revision"
    method_option :to, :desc => "Till Revision"
    def check
      _check(options)
    end

  end
end
