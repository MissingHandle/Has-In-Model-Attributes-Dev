# require 'hima_attribute'
# require 'hima_model'
# require 'hima_db_delta'

class HimaDbMigration < Object 
  #DbMigration = all current needed changes to the db
  #regarding one model file.
  
  #instance methods
  
  attr_reader :up_deltas
  attr_reader :down_deltas
  
  def initialize
    self.up_deltas = []
    self.down_deltas = []
  end
  
  def empty?
    self.up_deltas.empty? or self.down_deltas.empty?
  end  
  
  #A HimaDbMigration is valid if all it's delta operations are valid
  def valid?
    !self.empty? && self.up_deltas.all? {|d| d.valid? } && self.down_deltas.all? {|d| d.valid? }
  end
  
  #takes two HimaModel files as arguments, 
  #assuming the first is the way you would like the db to look.
  #and the second is the way it actually does look.
  def make_self(senior_model, subordinate_model)
    return false if senior_model == subordinate_model
    if senior_model.name != subordinate_model.name
      make_table_migrations(senior_model, subordinate_model)
    end
    unless self.up_deltas.any? { |d| d.command == :drop_table }
      make_column_migrations(senior_model, subordinate_model, "up")
      make_column_migrations(subordinate_model, senior_model, "down")
    end
    true
  end
  
  #takes a filehandle of a file open for writing and writes itself to the file
  #writes everything from 'def self.up' to the 'end' of self.down
  #writes nothing else; does NOT close the file.
  def write_self_to_file(filehandle)
    filehandle.write("  def self.up\n")
    as_text_array("up").each do |migration_command|
      filehandle.write("    " + migration_command + "\n")
    end
    filehandle.write("  end\n\n") #self.up
    filehandle.write("  def self.down\n")
    as_text_array("down").each do |migration_command|
      filehandle.write("    " + migration_command + "\n")
    end
    filehandle.write("  end\n\n") #self.down
  end
  
  private
    attr_writer :up_deltas
    attr_writer :down_deltas
    
    def add_delta(db_delta, direction = "up")
      if db_delta.class != HimaDbDelta or !db_delta.valid?
        return false
      else
        d = HimaDbDelta.new
        d.model_name = db_delta.model_name
        d.command = db_delta.command
        d.options = db_delta.options
        case direction
        when "up": self.up_deltas << d
        when "down": self.down_deltas = [d] + self.down_deltas
        else
          raise "Error Invalid 'direction' value for HimaDbMigration.add_delta: #{direction}"
        end
      end
    end

    # def remove_delta(db_delta)
    #   if db_delta.class != HimaDbDelta
    #     raise "TypeMismatchError! method remove_delta was expecting instance of 
    #     HimaDbDelta and instead got instance of #{db_delta.class}"
    #   end
    #   if @up_deltas.any? {|e| e == db_delta}
    #     @up_deltas.delete(db_delta) 
    #     return true
    #   else
    #     return false
    #   end
    # end
    
    def make_table_migrations(senior_model, subordinate_model)
      delta = HimaDbDelta.new
      if subordinate_model.name.empty? #No AR rep.
        delta.model_name = senior_model.name
        delta.command = :create_table
        #delta.options ..not sure how to handle :force and :id options!
        add_delta(delta)
        delta.command = :drop_table
        add_delta(delta, "down")
      elsif senior_model.name.empty? #No Hima rep.
        delta.model_name = subordinate_name
        delta.command = :drop_table
        add_delta(delta)
        delta.command = :create_table
        add_delta(delta, "down")
        tmp = HimaModel.new
        make_column_migrations(subordinate_model, tmp, "down")
      else #both, need to change name...?
        delta.model_name = subordinate_model.name
        delta.options[:new_name] = senior_model.name
        delta.command = :rename_table
        add_delta(delta)
        delta.model_name = senior_model.name
        delta.options[:new_name] = subordinate_model.name
        add_delta(delta, "down")
      end
    end
      
    
    def make_column_migrations(senior_model, subordinate_model, direction = "up")
      senior_model.each_attribute do |a|
        delta = HimaDbDelta.new
        if !subordinate_model.has_exact_same?(a) #must add/change attributes
          delta.model_name = senior_model.name
          delta.options = a.options
          delta.options[:column_name] = a.name
          delta.options[:column_type] = a.type
          if subordinate_model.has_with_name?(a) #definitely modifying type and/or options; 
            delta.command = :change_column
            add_delta(delta, direction)
            if delta.options.key?(:should_be) #possibly renaming
              delta.command = :rename_column
              delta.options[:new_name] = delta.options[:should_be]
              add_delta(delta, direction)
            end
          else
            delta.command = :add_column
            add_delta(delta, direction)
          end # has_with_name?
        end #has_exact_same?
      end #block
      subordinate_model.each_attribute do |a| #must delete attr's no longer around.
        delta = HimaDbDelta.new
        unless senior_model.has_with_name?(a)
          delta.model_name = senior_model.name
          delta.command = :remove_column
          delta.options[:column_name] = a.name
          add_delta(delta, direction)
        end #unless
      end #block
    end #method
  
    #returns an array, each element of which
    #is a string which is one line of the migration
    def as_text_array(direction)
      text_array = []
      single_line = ""
      if direction == "up"
        self.up_deltas.each do |delta|
          single_line = delta.to_file_text
          text_array.push(single_line)
        end
      elsif direction == "down"
        self.down_deltas.each do |delta|
          single_line = delta.to_file_text
          text_array.push(single_line)
        end
      else
        raise "Error Invalid Migration Direction for HimaDbMigration.as_text_array: #{direction}, expected 'up' or 'down'"
      end
      return text_array
    end
  
end