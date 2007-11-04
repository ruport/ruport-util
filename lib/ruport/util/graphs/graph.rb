require "rubygems"
require "ruport"
require "amline"

module Ruport
  class Renderer
    class Graph < Renderer

      stage :graph

      class Amline < Ruport::Formatter

        renders :amline, :for => Ruport::Renderer::Graph

        def build_graph
          generate_config_file
          data_out << "<chart>"
          data_out << "<series>"
          data.x_labels.each_with_index do |e,i|
            data_out << %Q{<value xid="#{i}">#{e}</value>}
          end
          data_out << "</series>"
          data_out << "<graphs>"
          data.each do |r|
            data_out << %Q{<graph gid="#{r.gid}">}
            r.each_with_index do |e,i|
              data_out << %Q{<value xid="#{i}">#{e}</value>}
            end
            data_out << "</graph>"
          end

          data_out << "</chart>"

          if options.data_file
            File.open(options.data_file,"w") { |f| f << data_out }
          end

          if options.settings_file
            File.open(options.settings_file,"w") { |f| f << settings_out }
          end

        end

        def generate_config_file
          settings = ::Amline::Settings.new("amline_settings.xml")
          data.each do |r|
            settings.add_graph(r.gid)
            settings.graph(r.gid) { |g|
              g.title = r.gid
            }
          end

          options.templated_settings_proc[settings] if options.templated_settings_proc
          format_settings[settings]
          settings_out << settings.to_xml
        end

        def format_settings
          options.format_settings || lambda {}
        end

        def output
          { :data => data_out, :settings => settings_out }
        end

        def data_out
          @data_out ||= ""
        end

        def settings_out
          @settings_out ||= ""
        end

      end

    end
  end

  module Data
    class Graph < Table

      include Renderer::Hooks
      renders_with Renderer::Graph

      def graph(data,gid=nil)
        self << data
        self[-1].gid = gid
      end

      def initialize_copy(from)
        super
        data.zip(from.data).each do |new_row,old_row|
          new_row.gid = old_row.gid
        end
      end

      alias_method :x_labels, :column_names
      alias_method :x_labels=, :column_names=
      
    end

    class GraphData < Ruport::Data::Record
      attr_accessor :gid
    end
  end


end

module Kernel
  def Graph(x_labels, data=[])
    Ruport::Data::Graph.new(:column_names => x_labels, :data => data,
                            :record_class => Ruport::Data::GraphData )
  end
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




