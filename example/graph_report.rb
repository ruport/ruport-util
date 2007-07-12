require "ruport"

require "ruport/util"

class GraphReport < Ruport::Report
  
  renders_as_graph
  
  def generate
    graph = Ruport::Graph(:column_names => %w[a b c d e])
    graph.add_line [1,2,3,4,5], :name => "foo" 
    graph.add_line [11,22,70,2,19], :name => "bar"
    return graph
  end

end

GraphReport.generate do |r| 
  r.save_as("foo.svg") 
end
