require "rubygems"
require "hpricot"

class Amline      
  
  class UnknownOption < StandardError; end

  class BlankSlate
    instance_methods.each { |m| undef_method m unless m =~ /^__/ }
  end

  class HpricotTraverser < BlankSlate


    def initialize(some_root)
      @root = some_root
    end

    attr :root

    def method_missing(id, *args, &block)
      if id.to_s =~ /^(\w+)=/
        @root.at($1).innerHTML =  args[0].to_s
      elsif id.to_s =~ /^(\w+)!/
        @root.at($1)
      else
        new_root = @root.at(id) or raise
        HpricotTraverser.new(new_root)
      end
    rescue
      raise UnknownOption
    end

    def ==(other)
      @root == other
    end

    def inspect
      @root
    end

    def to_s
      @root.to_s
    end

    alias_method :to_xml, :to_s

  end

  class Settings

    def initialize(settings_file="amline_settings.xml")
      @config = HpricotTraverser.new(Hpricot(File.read(settings_file)))
    end

    def config
      yield @config.settings if block_given?
      @config.settings
    end

    def add_graph(gid)
      new_graph = Hpricot(File.read("amline_graph.xml"))
      new_graph.at("graph")["gid"] = gid
      @config.root.search("graphs").append new_graph.to_s
    end

    def graph(gid)
      yield HpricotTraverser.new(@config.root.search("graph[@gid=#{gid}]"))
    end

    def to_xml
      @config.to_xml
    end

    def save(file)
      File.open(file,"w") { |f| f << @config.to_s }
    end

  end

end
