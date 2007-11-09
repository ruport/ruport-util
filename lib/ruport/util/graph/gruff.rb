class Ruport::Formatter  
  module Graph    
    class Formatter::Gruff < Ruport::Formatter

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