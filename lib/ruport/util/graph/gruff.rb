class Ruport::Formatter  
  module Graph    
    class Gruff < Ruport::Formatter

      renders [:png,:jpg], :for => Ruport::Renderer::Graph

      def initialize
        Ruport.quiet { require 'gruff' }
      end

      def build_graph
        graph = ::Gruff::Line.new
        graph.title = options.title if options.title
        graph.labels = options.labels if options.labels
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
  
  class PDF
    def draw_graph(graph, opts={})
      x = opts[:x]
      y = opts[:y]
      width = opts[:width]
      height = opts[:height]
      g = graph.as(:jpg)
      info = ::PDF::Writer::Graphics::ImageInfo.new(g)
      
      # reduce the size of the image until it fits into the requested box
      img_width, img_height =
        fit_image_in_box(info.width,width,info.height,height)
      
      # if the image is smaller than the box, calculate the white space buffer
      x, y = add_white_space(x,y,img_width,width,img_height,height)
      
      pdf_writer.add_image(g, x, y, img_width, img_height) 
    end
  end
end