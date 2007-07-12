# renderer/graph.rb
# Generalized graphing support for Ruby Reports
#
# Written by Gregory Brown, Copright December 2006, All Rights Reserved.
#
# This is free software.  See LICENSE and COPYING for details.
#
begin
  require "rubygems"
  gem "ruport", ">= 0.9.3"
rescue LoadError
  nil
end

module Ruport

  module Renderer::Hooks
    module ClassMethods
      def renders_as_graph
        renders_with Ruport::Renderer::Graph
      end
    end
  end

  def Graph(*args)
    Graph.new(*args)
  end

  module_function :Graph
  
  # This class implements the basic graphing engine for Ruport.
  #
  # == Supported Format Plugins
  # 
  # * Formatter::XML
  # * Formatter::SVG
  #
  # == Default layout options
  #
  # * height #=> 350
  # * width  #=> 500
  # * style  #=> :line
  #
  # ==  Plugin hooks called (in order)
  # 
  # * prepare_graph
  # * build_graph
  # * finalize_graph
  class Renderer::Graph < Renderer

    options { |o| o.style  = :line }

    prepare :graph

    stage :graph

    finalize :graph

  end                   
  
  class Graph < Ruport::Data::Table        
    
    renders_with Renderer::Graph

    class Line < Ruport::Data::Record
      attr_accessor :name      
      
      def initialize_copy(from) 
         @name = from.name.dup if from.name
      end
    end

    def initialize(options={})
      super({:record_class => Line}.merge(options))
    end

    def add_line(row_data,options={})
      self << row_data
      self[-1].name = options[:name]
    end 
    
    def dup                   
      obj = self.class.new(:column_names => column_names)  
      data.each { |r| obj.add_line(r.to_a,:name => r.name)}   
      return obj
    end

  end
 
  class Formatter::SVG < Formatter

    renders :svg, :for => Renderer::Graph

    # a hash of Scruffy themes.
    #
    # You can use these by setting options.theme like this:
    #
    #   Graph.render_svg(:theme => :mephisto)
    #  
    # Available themes: ( :mephisto, :keynote, :ruby_blog )
    #
    def themes
      { :mephisto => Scruffy::Themes::Mephisto.new,
        :keynote  => Scruffy::Themes::Keynote.new,
        :ruby_blog => Scruffy::Themes::RubyBlog.new }
    end

    # generates a scruffy graph object
    def initialize
      Ruport.quiet { require 'scruffy' }
      
      @graph = Scruffy::Graph.new
    end

    # the Scruffy::Graph object
    attr_reader :graph

    # sets the graph title, theme, and column_names
    #
    # column_names are defined by the Data::Table,
    # theme may be specified by options.theme (see SVG#themes)
    # title may be specified by options.title 
    #
    def prepare_graph 
      @graph.title ||= options.title
      @graph.theme = themes[options.theme] if options.theme
      @graph.point_markers ||= data.column_names
    end

    # Generates an SVG using Scruffy.
    def build_graph
      data.each_with_index do |r,i|
        add_line(r.to_a,r.name||"series #{i+1}")
      end

      output << @graph.render( 
        :size => [options.width||500, options.height||300],
        :min_value => options[:min], :max_value => options[:max]
      )
    end
    
    # Uses Scruffy::Graph#add to add a new line to the graph.
    #
    # Line style is determined by options.style
    #
    def add_line(row,label)
      @graph.add( options.style, label, row )
    end

  end
  
  class Formatter::XML_SWF < Formatter

    renders :xml_swf, :for => Renderer::Graph

    def prepare_graph
      gem "builder"              
      require "builder"
      @builder = Builder::XmlMarkup.new(:indent => 2)
    end

    def build_graph
      output << @builder.chart do |b|
        b.chart_type(options.style.to_s)

        b.chart_data do |cd|
          
          cd.row { |first|
            first.null
            data.column_names.each { |c| first.string(c) }
          }
          
          data.each_with_index { |r,i|       
            label = r.name || "Region #{i}"
            cd.row { |data_row|
              data_row.string(label)
              r.each { |e| data_row.number(e) }
            }
          }
        end
      end
    end

  end

end
