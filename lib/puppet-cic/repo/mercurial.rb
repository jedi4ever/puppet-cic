require 'lib/puppet-cic/baserepo'
require 'lib/puppet-cic/changeset'

module PuppetCic
  module Repo
    class Mercurial < PuppetCic::BaseRepo

      def changeset(from = "tip~1", to = "tip")
        from  = "tip~1" if from.nil?
        to  = "tip" if to.nil?
        changeset = Changeset.new(standardize(native(from,to)),from,to)
        return changeset
      end

      # Returns the changes as reported by the native commands
      # ["M modules/README",
      # "A .hgsub",
      # "A .hgsubstate",
      # "A hieradata/hiera.yaml",
      # "A manifests/nodes/node1.pp",
      # "A manifests/nodes/node2.pp",
      # "A module/moduleA/init.pp",
      # "A module/moduleA/service.pp",
      def native(from,to)
        command = "hg status --rev #{from}:#{to} -m -a -r -d -S -R #{@repodir}"
        puts "Checking difference : \n#{command}"
        result = `#{command}`
        exitcode = $?
        exit -1 unless exitcode == 0
        return result.split(/\n/)
      end

      def standardize(native_changes)
        detected_changes = Array.new
        native_changes.each do |change|
          path = change[2..-1]
          change_type = change[0..0]
          detected_changes << { :path => path , :type => change_type}
        end
        return detected_changes
      end

    end
  end
end
