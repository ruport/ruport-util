require "rubygems"
require "hpricot"
require "hpricot_traverser"

class Amline

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
