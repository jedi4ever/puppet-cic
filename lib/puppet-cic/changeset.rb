module PuppetCic
  class Changeset

    attr_accessor :raw
    attr_reader :to,:from

    def initialize(standardized_changes,from,to)
      @raw = standardized_changes
      @to = to
      @from = from
    end

    def modules
      modules_changes = Hash.new
      @raw.each do |change|
        if module?(change)
          modules_changes[module_name(change)] = true
        end
      end
      return modules_changes.keys
    end

    def module?(change)
      return !change[:path].match(/modules/).nil?
    end

    def module_name(change)
      return change[:path].split(/\//)[1]
    end

    # check if this contains libs (can have impact on all nodes/classes)
    def libs
     libs_changes = Array.new
      @raw.each do |change|
        if lib?(change)
          libs_changes << module_name(change)
        end
      end
      return libs_changes.sort.uniq
    end

    def lib?(change)
      return !change[:path].match(/lib/).nil?
    end


  end
end
