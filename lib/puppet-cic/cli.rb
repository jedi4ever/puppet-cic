require 'rubygems'
require 'bundler/setup'
require 'puppet-cic/command/check'

module PuppetCic
  class CLI < Thor

    include PuppetCic::Command

    desc "check", "Given facts specificied by factsfile (Yaml)\n"+
      "check what puppet modules are impacted by a commit range"
    method_option :modulepath , :default => "modules", :desc => "Path to the puppet modules"
    method_option :manifestdir , :default => "manifests", :desc => "Path to puppet manifests"
    method_option :manifest , :default => "manifests/site.pp", :desc => "Path to puppet manifest"

    method_option :repodir , :default => '.', :desc => "Directory where the repository is located"
    method_option :repotype , :default => 'mercurial', :desc => "Type of repository (mercurial or git)"
    method_option :from, :desc => "From revision (defaults last commit -1 )"
    method_option :to, :desc => "Till Revision (defaults last commit)"

    method_option :factsfile , :required => true,:desc => "Yaml file that contains facts"
    def check
      _check(options)
    end

  end
end
