# renderer/graph.rb
# Generalized graphing support for Ruby Reports
#
# Written by Gregory Brown, Copright December 2006, All Rights Reserved.
#
# This is free software.  See LICENSE and COPYING for details.
#
begin
  require "rubygems"
  gem "ruport", ">= 1.2.2"
rescue LoadError
  nil
end    

module Ruport

  module Renderer::Hooks
    module ClassMethods
      def renders_as_graph(options={})
        renders_with Ruport::Renderer::Graph, options
      end
    end
  end
  
  class Renderer
    class Graph < Renderer
       
      prepare :graph 
      stage :graph   
      finalize :graph
      
    end
  end  
  
  module Data 
    class Graph < Table

      renders_as_graph

      def series(data,gid=nil)
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
  def Graph(x_labels=[], data=[])
    Ruport::Data::Graph.new(:column_names => x_labels, :data => data,
                            :record_class => Ruport::Data::GraphData )
  end
end    

require "ruport/util/graph/scruffy"
require "ruport/util/graph/amline"
require "ruport/util/graph/gruff"
