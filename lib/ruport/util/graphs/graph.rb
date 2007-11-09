require "rubygems"
require "ruport"
require "amline"

module Ruport
  class Renderer
    class Graph < Renderer

      stage :graph



      class Formatter::Gruff < Formatter

        renders [:png,:jpg], :for => Renderer::Graph

        def initialize
          Ruport.quiet { require 'gruff' }
        end

        def build_graph
          graph = ::Gruff::Line.new
          graph.title = options.title
          graph.labels = options.labels
          data.each do |r|
            graph.data(r.gid,r.to_a)
          end

          output << graph.to_blob(format.to_s)
        end

        # Save the output to a file.
        def save_output(filename)
          File.open(filename,"wb") {|f| f << output }
        end
      end
    end
  end

  module Data



end

#a = Graph([1900,1950,2000,2050])
#a.graph [10,40,14,19], "foo"
#a.graph [200.11,500,40,75], "bar"

#a.as(:amline, :format_settings => 
#  lambda { |settings| 
#    settings.graph "foo" do |g|
#      g.color = "#FFFF00"
#    end
#    settings.graph "bar" do |g|
#    end
#    settings.config do |c|
#       c.values.y_left.max = 10000
#       c.grid.x.dashed = true
#    end
#  },
#   :settings_file => "/home/sandal/build/amline/amline_settings.xml", 
#   :data_file => "/home/sandal/build/amline/amline_data.xml",
#   :template => :graph )

# graph = Graph()
# graph.graph([1, 2, 3, 4, 4, 3], "Apples")
# graph.graph([4, 8, 7, 9, 8, 9], "Oranges")
# graph.graph([2, 3, 1, 5, 6, 8], "Watermelon")
# graph.graph([9, 9, 10, 8, 7, 9], "Peaches")
# 
# png = graph.as(:png, :title => "My Graph",
#   :labels => { 0 => '2003', 2 => '2004', 4 => '2005' }, :data => graph,
#   :file => 'new_graph.png')



