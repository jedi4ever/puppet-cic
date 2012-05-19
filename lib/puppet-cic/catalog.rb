require 'puppet'
module PuppetCic
  class Catalog
    attr_accessor :modulepath,:manifestdir,:manifest

    def initialize(modulepath,manifestdir,manifest)
      @modulepath = modulepath
      @manifestdir = manifestdir
      @manifest = manifest

      Puppet[:modulepath] = @modulepath
      Puppet[:manifestdir] = @manifestdir
      Puppet[:manifest] = @manifest
    end

    def munge_facts(facts)
      output = {}
      facts.keys.each { |key| output[key.to_s] = facts[key] }
      output
    end

    # List modules currently linked in the catalog
    def modules(facts = {})
      # Get all clases that are in the catalog
      classes = classes(munge_facts(facts))

      # Extract only the module part
      modules = classes.collect {|c| c.split('::').first}
      return modules.sort.uniq
    end

    # List classes currently linked in the catalog
    def classes(facts = {})
      # Use the manifest f.i. site.pp and import it
      code = "import '#{Puppet[:manifest]}'\n"
      Puppet[:code] = code

      name = "dummy"
      # Create an empty puppet node
      node = Puppet::Node.new(name)

      # Merge facts into node
      node.merge(munge_facts(facts))

      # Find the Catalog
      begin
        # trying to be compatible with 2.7 as well as 2.6
        if Puppet::Resource::Catalog.respond_to? :find
          catalog = Puppet::Resource::Catalog.find(node.name, :use_node => node)
        else
          catalog = Puppet::Resource::Catalog.indirection.find(node.name, :use_node => node)
        end
      rescue Puppet::Error => ex
        puts "Something went wrong with compiling the catalog: \n#{ex}."
        exit -1
      end

      tags = Array.new

      # Loop over all classes
      catalog.classes.each do |c|
        # Create a class resource
        r = catalog.resource(:class,c)

        # Resources have title and type:
        # resource.title (running a command), resource.type (f.i. exec)
        #
        # This doesn't tell us about the modulename
        #
        # Using tags we can find out the module name as it's added as a tag

        unless r.nil?
          # Find dependents & Find dependencies
          [ catalog.dependents(r),catalog.dependencies(r)].each do |dep|
            dep.each do |resource|
              #puts resource.title
              resource.tags.each do |tag|
                tags << tag
              end
            end
          end
        end

      end

      # Only return unique tags
      return tags.sort.uniq.reject { |tag| ['stage','node','notify','class','exec','file','service','package'].include?(tag)}
    end
  end
end
