class Factory
  include Enumerable
  class << self
    
    def new(*args, &block)
      Class.new do
        attr_accessor(*args)
        define_method(:initialize) do |*data|
          args.each { |argument| __send__("#{argument}=", data.shift) }
        end
        
        define_method(:values) do
          instance_variables.map { |var| instance_variable_get(var) }
        end

        define_method(:==) do |obj|
          self.class == obj.class && self.values == obj.values
        end

        define_method(:eql?) do |obj|
          self.class == obj.class && (self.values.eql? obj.values)
        end

        define_method(:[]) do |field|
          send_param = field.is_a?(Integer) ? args[field] : field
          __send__(send_param)
        end

        define_method(:[]=) do |field, value|
          param = ("@" + (field.is_a?(Integer) ? args[field] : field).to_s)
          instance_variables.map {instance_variable_set(param, value) }
        end

        define_method(:values_at) do |beg, fin|
          result = values.values_at(beg, fin)
        end

        define_method(:length) do
          self.instance_variables.size
        end

        define_method(:members) do
          instance_variables.map { |instance_var| instance_var.to_s.delete('@').to_sym }
        end
      
        define_method(:to_h) do
          res = {}
          b = instance_variables.map {|var| hash = {var => instance_variable_get(var)}}
          b.each do |val|
            val.each do |key, value|
              key = key.to_s.delete('@').to_sym
              res[key] = Hash[key, value]
            end
          end
          res
        end

        define_method(:each) do |&block|
          block ? members.each { |attribute| block.call(send(attribute)) } : enum_for(:each)
        end

        define_method(:each_pair) do |&block|
          block ? to_h.each_pair(&block) : enum_for(:each)
        end

        define_method(:select) do |&block|
         block ? values.select(&block) : enum_for(:select)
        end  

        alias :to_a :values
        alias :to_s :inspect
        alias :size :length

        class_eval(&block) if block_given?
      end
    end
  end
end

Player = Factory.new(:name, :team, :number) do
  def greeting
    "Hello #{name}!"
  end
end

puts Player.new('Zlatan Ibrahimovic', 'Manchester United', 9).greeting

zlatan = Player.new('Zlatan Ibrahimovic1', 'Manchester United', 9)
zlatan1 = Player.new('Zlatan Ibrahimovic', 'Manchester United', 9)

puts zlatan.values_at 0, 1
puts zlatan == zlatan1
puts zlatan.length
puts zlatan.values
puts zlatan.name
puts zlatan['name']
puts zlatan[:name]
puts zlatan[0]
zlatan[:name] = "Zoltan"
puts zlatan.name
zlatan[0] = "Gendalf"
puts zlatan.name
zlatan["name"] = "Boromir"
puts zlatan.name
puts zlatan.eql? zlatan1
puts zlatan.to_h[:team]
p zlatan.members
p zlatan.values_at 0, 1
p zlatan.inspect
p zlatan.to_s
zlatan.each {|x| puts x}
zlatan.each_pair {|name, value| puts("#{name} => #{value}") }

Lots = Factory.new(:a, :b, :c, :d, :e, :f)
l = Lots.new(11, 22, 33, 44, 55, 66)

puts l.select {|v| (v % 2).zero? }