require 'test/helper'

Ruport.quiet { testcase_requires 'scruffy' }

class MockGraphPlugin < Ruport::Formatter
  renders :mock, :for => Ruport::Renderer::Graph
  def prepare_graph 
    output << "prepare"
  end
  def build_graph
    output << "build"
  end
  def finalize_graph
    output << "finalize"
  end
end

describe 'Graph Renderer' do
  before :all do
    @graph = Ruport::Renderer::Graph
    @data = Ruport::Graph(:data => [[1,2,3],[4,5,6]])
  end

  it 'should render' do
    out = @graph.render_mock do |r|
      r.options do |l|
        l.style.should == :line
      end
    end

    out.should == 'preparebuildfinalize'
  end

  it 'should render SVG' do
    @graph.render_svg{|r| r.data = @data}.should_not be_nil
  end

  it 'should render XMLSWF via block' do
    expected = <<-EOS
<chart>
  <chart_type>line</chart_type>
  <chart_data>
    <row>
      <null/>
    </row>
    <row>
      <string>Region 0</string>
      <number>1</number>
      <number>2</number>
      <number>3</number>
    </row>
    <row>
      <string>Region 1</string>
      <number>4</number>
      <number>5</number>
      <number>6</number>
    </row>
  </chart_data>
</chart>
EOS

    @graph.render_xml_swf{|r| r.data = @data}.should == expected
  end

  it 'should render XMLSWF via add_line' do
    expected = <<-EOS
<chart>
  <chart_type>line</chart_type>
  <chart_data>
    <row>
      <null/>
    </row>
    <row>
      <string>Alpha</string>
      <number>1</number>
      <number>2</number>
      <number>3</number>
    </row>
    <row>
      <string>Beta</string>
      <number>4</number>
      <number>5</number>
      <number>6</number>
    </row>
  </chart_data>
</chart>
EOS

  graph = Ruport::Graph()
  graph.add_line [1,2,3], :name => "Alpha"
  graph.add_line [4,5,6], :name => "Beta"
  
  graph.to_xml_swf.should == expected
  end
end
