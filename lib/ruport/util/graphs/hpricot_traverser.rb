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





end
