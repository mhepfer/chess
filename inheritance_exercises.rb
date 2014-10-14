class Employee
  attr_reader :title, :name, :salary, :boss
  
  def initialize(name, title, salary, boss = nil)
    @name, @title, @salary, @boss = name, title, salary, boss
    assign_boss(boss) unless boss.nil?
  end
  
  def assign_boss(boss)
    @boss = boss
    @boss.minions << self
  end
  
  def bonus(multiplier)
    @salary * multiplier
  end


end

class Manager < Employee
  attr_reader :minions
  
  def initialize(name, title, salary, boss = nil)
    super(name, title, salary, boss)
    @minions = []
  end
  
  def bonus(multiplier)    
    return bonus_sum = 0 if self.minions.empty?
    bonus_sum = 0
    @minions.each do |employee|
      p 'entered loop'
      #bonus += employee.salary * multiplier
      if employee.is_a?(Manager)
        bonus_sum += employee.bonus(multiplier) + employee.salary * multiplier
      else
        bonus_sum += employee.salary * multiplier
      end
        
    end
  
    bonus_sum
  end
  
end

boss_man = Manager.new("Boss_Man", "Slave driver", 500_000_000)
bob = Employee.new("Bob", "The Man", 3, boss_man)
nina = Manager.new("Nina", "That other person", 5, boss_man)
grunt = Employee.new("Grunt", "Paper Pusher", 1, nina)

p boss_man.bonus(2)
puts boss_man.minions
