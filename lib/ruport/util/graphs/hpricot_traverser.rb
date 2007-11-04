require "rubygems"
require "hpricot"

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

if __FILE__ == $PROGRAM_NAME

  require "test/spec"



  describe "A simple traversal" do

    before :each do
      xml = "<foo><bar><baz></baz></bar></foo>"
      @root = Hpricot(xml)
      @traverser = HpricotTraverser.new(@root)
    end

    it "should allow accessing nested attributes" do
      @root.at("foo").at("bar").at("baz").should ==
      @traverser.foo.bar.baz
    end

    it "should allow setting nested attributes" do
      @traverser.foo.bar.baz = "kittens"
      @root.at("foo/bar/baz").innerHTML.should == "kittens"
    end

    it "should be a true bro about missing elements" do
      assert_raises(UnknownOption) do
        @traverser.foo.bart.baz
      end

      assert_raises(UnknownOption) do
        @traverser.foo.bart = "baz"
      end

      assert_raises(UnknownOption) do
        @traverser.foot
      end
    end

    it "should allow accessing the Hpricot elements via !" do
     @traverser.foo!().class.should ==  Hpricot::Elem
    end

    it "should convert values to strings when setting tags" do
      @traverser.foo.bar.baz = 10
      @traverser.foo.bar.baz!().innerHTML.should == "10"
    end

  end


end
