#Are you readyyyyyy?
require 'byebug'

class Authorisation
  def self.options_list(employee)
    options_list = []
    options_list << "change_pin"
    klass = employee.class

    if klass == Janitor
    elsif klass == Doctor
      options_list += ["list_patients", "view_records", "add_record", "remove_record"]
    elsif klass == Admin
      options_list += ["list_patients", "view_records", "add_record", "remove_record", "add_new_patient", "add_new_employee"]
    elsif klass ==  Receptionist
      options_list += ["list_patients", "add_new_patient"]
    end
    options_list.sort!
  end

  def self.print_options(user)
    options_list(user).each_with_index do |option, index|
      puts "#{index+1}. #{option}"
    end
  end
end

class Hospital
  def initialize(name, patient_quota)
    @name = name
    @patient_quota = patient_quota
  end
end

class Employee
  @@id = 1

  def initialize(name, pin = 1234)
    @name = name
    @id = @@id
    @@id += 1
    @pin = pin
  end

  def role
    @role
  end

  def name
    @name
  end

  def authorise(username, pin_entry)
    @name == username && @pin == pin_entry
  end

  def change_pin
    print "Please input your OLD PIN: "
    old_pin = gets.chomp.to_i
    if old_pin == @pin
      print "Please input your NEW PIN: "
      new_pin = gets.chomp.to_i
      print "Please confirm your NEW PIN: "
      confirmation_pin = gets.chomp.to_i
      if new_pin == confirmation_pin
        @pin = new_pin
        puts "PIN has been changed"
      else
        puts "Pins do not match"
      end
    else
      puts "Invalid Pin"
    end
  end

  def change_pin=(new_pin)
    @pin = new_pin
  end

  private
    def salary
      @salary
    end

    def salary=(new_salary)
      @salary = new_salary
    end


end

class Janitor < Employee
  def initialize(name)
    super(name)
    @role = "Clean Toilets"
    @salary = "MYR 2000"
  end
end

class Receptionist < Employee
  def initialize(name, pin)
    super(name)
    @role = "Greet Patients"
    @salary = "MYR 2500"
  end
end

class Doctor < Employee
  def initialize(name, pin)
    super(name)
    @role = "Heal Patients"
    @salary = "MYR 8000"
  end
end

class Admin < Employee
  def initialize(name, pin)
    super(name)
    @role = "Does admin"
    @salary = "MYR 12000"
    @pin = pin
    # byebug
  end
end

class Patient
  @@id = 1

  def initialize(name)
    @name = name
    @patient_id = @@id
    @@id += 1
    @record = []
  end

  # number of days stayed in hospital
  # hospital bills racked up so far (use number of days * RM 100 + type of operation)

  attr_reader :name, :patient_id
  attr_accessor :record

  def view_record
    @record
  end

  def add_record=(record)
    @record << record
  end

  def remove_record(record)
    @record.delete(record)
  end
end

class Console

  def self.start
    @patient_list = []
    @employee_list = []
    @employee_list << Admin.new("Jeremy", 1234)
    @employee_list << Doctor.new("Wun Min", 1234)
    @employee_list << Receptionist.new("Jalen", 1234)
    @authorized = false
    try_count = 0
    until @authorized
      puts "What is your name?"
      username = gets.chomp
      puts "What is your PIN?"
      password = gets.chomp.to_i
      @user = self.check_pin(username, password)
      try_count += 1
      if try_count >= 3
        puts "Do you wanna quit? Y/N"
        if gets.chomp == "Y"
          break
        else
          try_count = 0
        end
      end
      # byebug
      # p @authorized
    end

    if @authorized
      self.program
    end
  end

  def self.program
    has_ended = false
    until has_ended
      puts "What would you like to do?"
      puts "Options"
      Authorisation.print_options(@user)

      self.options_run
      puts "Do you want to continue? Type N if you do not want to continue."
      continue = gets.chomp
      if continue == "N"
        has_ended = true
      end
    end
  end

  def self.options_run
    input = gets.chomp.to_i
    input = Authorisation.options_list(@user)[input - 1]
    case input
    when "list_patients"
      # prints out all the patient names and ID
      p @patient_list
    when "view_records"
      patient_id = self.ask_for_patient_id
      puts "Viewing patient's records."
      p @patient_list[patient_id - 1].view_record
    when "add_record"
      patient_id = self.ask_for_patient_id
      puts "what would you like to add into this patient's record?"
      new_record = gets.chomp
      @patient_list[patient_id - 1].add_record=(new_record)
      puts "This record has been added."
      # use the patient ID to locate the records, then push in new record data
    when "remove_record"
      patient_id = self.ask_for_patient_id
      @patient_list[patient_id - 1].view_record
      # display all record data
      puts "Which record would you like to delete?"
      record = gets.chomp
      @patient_list[patient_id - 1].remove_record(record)
      puts "This record has been removed."
      # use record_it_to_delete to delete the relevant record
    when "add_new_patient"
      puts "What is the patient's name?"
      name = gets.chomp
      @patient_list << self.add_new_patient(name)
      p @patient_list
      # Allow receptionist and doctor to add patient
    when "add_new_employee"
      puts "What is the employee's position?"
      @position = gets.chomp
      puts "What is the employee's name?"
      name = gets.chomp
      @employee_list << self.add_new_employee(name)
      # if new employee is either a Doctor, Receptionist or Admin
      # @employee_list[-1].self.add_pin
      p @employee_list

    when "change_pin"
      @user.change_pin
      # puts "What is your new PIN? Four numbers please"
      # new_pin = gets.chomp.to_i
      # @employee_list.each do |object|
      #   if object.name == username
      #     object.change_pin=(new_pin)
      #   end
      # end
      # @employee_list << self.add_new_employee(name)
      # # if new employee is either a Doctor, Receptionist or Admin
      # # @employee_list[-1].self.add_pin
      # p @employee_list
    end
  end

# object of console instead of object of Janitor
  def self.check_pin(username, password)
    @employee_list.each do |object|
      if object.authorise(username, password)
          @authorized = true
          return object
      end
    end
    return nil
  end

  def self.add_new_employee(name)
    if @position == "Janitor"
      Janitor.new(name)
    elsif @position == "Doctor"
      Doctor.new(name)
    elsif @position == "Receptionist"
      Receptionist.new(name)
    elsif @position == "Admin"
      Admin.new(name)
    else
      puts "Please select from Janitor, Doctor, Receptionist or Admin"
    end
  end

  # def self.add_pin
  #     puts "What your is pin? 4 Digits only please."
  #     pin = gets.chomp.to_i
  # end

  def self.add_new_patient(name)
    Patient.new(name)
  end

  def self.ask_for_patient_id
    puts "What is the patient ID?"
    patient_id = gets.chomp.to_i
  end
end

Console.start