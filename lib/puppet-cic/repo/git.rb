require 'lib/puppet-cic/baserepo'
require 'lib/puppet-cic/changeset'

module PuppetCic
  module Repo
    class Git < PuppetCic::BaseRepo

      def changeset(from, to)
        from  = "HEAD~1" if from.nil?
        to  = "HEAD" if to.nil?
        changeset = Changeset.new(standardize(native(from,to)),from,to)
        return changeset
      end

      # Returns the changes as reported by the native commands
      # ["M\tmodules/README",
      # "A\t.hgsub",
      # "A\t.hgsubstate",
      # "A\thieradata/hiera.yaml",
      # "A\t manifests/nodes/node1.pp",
      # "A\tmanifests/nodes/node2.pp",
      # "A\tmodule/moduleA/init.pp",
      # "A\tmodule/moduleA/service.pp",
      def native(from,to)
        command = "cd #{@repodir} ; git diff --name-status #{from} #{to}"
        puts "Checking difference : \n#{command}"
        result = `#{command}`
        exitcode = $?
        exit -1 unless exitcode == 0
        return result.split(/\n/)
      end

      def standardize(native_changes)
        detected_changes = Array.new
        native_changes.each do |change|
          change_type, path = change.split(/\t/)
          detected_changes << { :path => path , :type => change_type}
        end
        return detected_changes
      end

    end
  end
end
