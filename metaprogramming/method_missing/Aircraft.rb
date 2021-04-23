class Aircraft
  attr_accessor :passengers

  def initialize
    @passengers = 0
  end

  def method_missing(method_name, *args)
    message = "You called #{method_name} with #{args}. This method doesn't exist."

    raise NoMethodError, message
  end

  def taxt
  end

  def park
  end
end

aircraft = Aircraft.new
aircraft.add_passengers(275)
