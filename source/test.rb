
#  <snip>
class OrangeTree
  attr_reader :age, :height
  def initialize
    @age = 0
    @oranges = []
  end
#</snip>

#<snip>test
  def age!
    @oranges += Array.new(rand(1..10)) { Orange.new } if @age > 5
  end
#</snip>

#<snip>
  def any_oranges?
    !@oranges.empty?
  end
#test</snip>

  def pick_an_orange!
    raise NoOrangesError, "This tree has no oranges" unless self.any_oranges?
    @oranges.pop
  end


  def dead?
    @age >= 50
  end
end
