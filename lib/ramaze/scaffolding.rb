require "ramaze/gestalt"

module Ramaze
  ##
  # The scaffolding class is a generator that builds a simple CRUD controller for any database table.
  # This capability is meant only for development, as the resulting controllers have NO SECURITY
  # code built into them. These controllers make it easy to manipulate the database tables during
  # development.
  #
  # The controllers are encapsulated in <scaffolding> ... </scaffolding> tags so that you can write
  # CSS statements that will only apply to scaffolding.
  #
  # The way it works is that it reads the database table to get the list of fields in the table.
  # Next, it takes a prewritten CRUD controller and tailors it based on the fields in the table.
  # It's more complicated to do than than it seems, but the output of this generator is the
  # controller in the form of a String object.
  #
  # The common way to use it is to call it to create the controller, the use class_eval to install it
  # on the fly. You can do this in your 'controller/init.rb' module if you want it to be permanent,
  # but be sure you only generate the controllers in 'dev' mode because, again, they have NO SECURITY
  # built into them.
  #
  # These controllers are created once during load time, so the cost of using them is negligible
  # while Ramaze is running. All the configuring is done at load time, so the generated code does
  # not need to look at the table's schema to operate.
  #
  # If these controllers are in your production version, any idiot hacker can use them to examine
  # and modify your database. So let me repeat:
  #
  # THESE CONTROLLERS ARE FOR DEVELOPMENT USE ONLY.
  #
  # The test table is:
  #  DB::drop_table?(:coltypes)
  #  DB::create_table(:coltypes) do          # common database type used
  #    primary_key :id                       # int(11) + primary key
  #    Integer :int11                        # int(11)
  #    String :vc255                         # varchar(255)
  #    String :vc50, :size=>50               # varchar(50)
  #    String :c255, :fixed=>true            # char(255)
  #    String :c50, :fixed=>true, :size=>50  # char(50)
  #    String :text, :text=>true             # text
  #    File :blob                            # blob
  #    Fixnum :fixnum                        # int(11)
  #    Bignum :bignum                        # bigint(20)
  #    Float :dblflt                         # double
  #    BigDecimal :bigdec                    # decimal(10,0)
  #    BigDecimal :big6dec, :size=>6         # decimal(6,0)
  #    BigDecimal :big10dec2, :size=>[10, 2] # decimal(10,2)
  #    Date :justdate                        # date
  #    DateTime :datetime                    # datetime
  #    Time :justtime                        # datetime
  #    Time :timeonly, :only_time=>true      # time
  #    Numeric :numeric                      # decimal(10,0)
  #    TrueClass :booltrue                   # tinyint(1)
  #    FalseClass :boolfalse                 # tinyint(1)
  #    DateTime :created_at                  # datetime
  #    DateTime :updated_at                  # datetime
  #  end
  #
  class Scaffolding

    Sequel.extension :inflector # http://sequel.jeremyevans.net/rdoc-plugins/classes/String.html

    ##
    # This is the core CRUD controller. It has no comments for efficiency. There's no magic
    # here: it's just simple Ruby/Sequel programming.
    def initialize
      @prototype = [
        "class NilClass", :eol,
        "  def strftime(pattern)", :eol,
        "    \"\"", :eol,
        "  end", :eol,
        "end", :eol,
        :eol,
        "class ", :model_string_singular_camel, "Controller < Controller", :eol,
        :eol,
        "  map '/", :model_string_singular, "'", :eol,
        :eol,
        "  def initialize", :eol,
        "    @columns = ", :columns_list, :eol,
        "    @index_columns = ", :index_columns_list, :eol,
        "    @new_columns = ", :new_columns_list, :eol,
        "    @show_columns = ", :show_columns_list, :eol,
        "    @edit_columns = ", :edit_columns_list, :eol,
        "  end", :eol,
        :eol,
        "  def index", :eol,
        "    @g = Ramaze::Gestalt.new", :eol,
        "    @title = \"List of ", :model_string_plural_camel, "\"", :eol,
        "    @g.scaffolding do", :eol,
        "      rows = ", :model_string_singular_camel, ".select(*@index_columns).all", :eol,
        "      @g.h3 { @title }", :eol,
        "      @g.p do", :eol,
        "        @g.a(:href=>\"/", :model_string_singular, "/new\") { \"new\" }", :eol,
        "      end", :eol,
        "      @g.table do", :eol,
        "        # create the heading", :eol,
        "        @g.tr do", :eol,
        "          @index_columns.each do |col|", :eol,
        "            @g.td do", :eol,
        "              @g.strong { col.to_s.titleize }", :eol,
        "            end", :eol,
        "          end", :eol,
        "        end", :eol,
        "        # list all the rows", :eol,
        "        rows.each do |row|", :eol,
        "          @g.tr do", :eol,
        "            row.each do |col,value|", :eol,
        "              @g.td { value.to_s }", :eol,
        "            end", :eol,
        "            @g.td do", :eol,
        "              @g.a(:href=>\"/", :model_string_singular, "/show?id=%s\"%row[:id]) { \"show\" }", :eol,
        "              @g << \" | \"", :eol,
        "              @g.a(:href=>\"/", :model_string_singular, "/edit?id=%s\"%row[:id]) { \"edit\" }", :eol,
        "              @g << \" | \"", :eol,
        "              @g.a(:href=>\"/", :model_string_singular, "/show?id=%s&delete\"%row[:id]) { \"delete\" }", :eol,
        "            end", :eol,
        "          end", :eol,
        "        end", :eol,
        "      end", :eol,
        "    end", :eol,
        "    @g.to_s", :eol,
        "  end", :eol,
        :eol,
        "  def new", :eol,
        "    @g = Ramaze::Gestalt.new", :eol,
        "    @title = \"New ", :model_string_singular_camel, "\"", :eol,
        "    @g.scaffolding do", :eol,
        "      @g.h3 { @title }", :eol,
        "      row = ", :model_string_singular_camel, ".new", :eol,
        "      @g.form(:method=>:post, :action=>:save_new) do", :eol,
        "        @g.table do", :eol,
        :new_columns,
        "        end", :eol,
        "        @g.br", :eol,
        "        @g.input(:type=>:submit, :id=>\"goto\", :name=>\"goto\", :value=>\"Back\")", :eol,
        "        @g << \"&nbsp;\"", :eol,
        "        @g.input(:type=>:submit, :id=>\"goto\", :name=>\"goto\", :value=>\"Save\")", :eol,
        "      end", :eol,
        "    end", :eol,
        "    @g.to_s", :eol,
        "  end", :eol,
        :eol,
        "  def show", :eol,
        "    @g = Ramaze::Gestalt.new", :eol,
        "    @title = \"Show ", :model_string_singular_camel, "\"", :eol,
        "    @g.scaffolding do", :eol,
        "      @g.h3 { @title }", :eol,
        "      row = ", :model_string_singular_camel, ".where(:id=>session.request.params['id']).first", :eol,
        "      @g.form(:method=>:post, :action=>:save_show) do", :eol,
        "        @g.input(:type=>:hidden, :name=>:id, :value=>row.id)", :eol,
        "        @g.table do", :eol,
        :show_columns,
        "        end", :eol,
        "        @g.br", :eol,
        "        @g.input(:type=>:submit, :id=>\"goto\", :name=>\"goto\", :value=>\"Back\")", :eol,
        "        if session.request.params.has_key?('delete')", :eol,
        "          @g << \"&nbsp;\"", :eol,
        "          @g.input(:type=>:submit, :id=>\"goto\", :name=>\"goto\", :value=>\"Delete\")", :eol,
        "        end", :eol,
        "      end", :eol,
        "    end", :eol,
        "    @g.to_s", :eol,
        "  end", :eol,
        :eol,
        "  def edit", :eol,
        "    @g = Ramaze::Gestalt.new", :eol,
        "    @title = \"Edit ", :model_string_singular_camel, "\"", :eol,
        "    @g.scaffolding do", :eol,
        "      @g.h3 { @title }", :eol,
        "      row = ", :model_string_singular_camel, ".where(:id=>session.request.params['id']).first", :eol,
        "      row.updated_at = Time.now", :eol,
        "      @g.form(:method=>:post, :action=>:save_edit) do", :eol,
        "        @g.input(:type=>:hidden, :name=>:id, :value=>row.id)", :eol,
        "        @g.table do", :eol,
        :edit_columns,
        "        end", :eol,
        "        @g.br", :eol,
        "        @g.input(:type=>:submit, :id=>\"goto\", :name=>\"goto\", :value=>\"Back\")", :eol,
        "        @g << \"&nbsp;\"", :eol,
        "        @g.input(:type=>:submit, :id=>\"goto\", :name=>\"goto\", :value=>\"Save\")", :eol,
        "      end", :eol,
        "    end", :eol,
        "    @g.to_s", :eol,
        "  end", :eol,
        :eol,
        "  def save_new", :eol,
        "    if session.request.params['goto']==\"Save\"", :eol,
        "      row = ", :model_string_singular_camel, ".new", :eol,
        "      row.set_fields(session.request.params, @new_columns, :missing=>:skip)", :eol,
        "      row.id = nil", :eol,
        "      row.created_at = Time.now if @columns.index(:created_at)", :eol,
        "      row.updated_at = Time.now if @columns.index(:updated_at)", :eol,
        "      row.save", :eol,
        "    end", :eol,
        "    redirect(\"/", :model_string_singular, "/index\")", :eol,
        "  end", :eol,
        :eol,
        "  def save_show", :eol,
        "    if session.request.params['goto']==\"Delete\"", :eol,
        "      row = ", :model_string_singular_camel, ".where(:id=>session.request.params['id']).first", :eol,
        "      row.delete", :eol,
        "    end", :eol,
        "    redirect(\"/", :model_string_singular, "/index\")", :eol,
        "  end", :eol,
        :eol,
        "  def save_edit", :eol,
        "    if session.request.params['goto']==\"Save\"", :eol,
        "      row = ", :model_string_singular_camel, ".where(:id=>session.request.params['id']).first", :eol,
        "      row.set_fields(session.request.params, @edit_columns, :missing=>:skip)", :eol,
        "      row.updated_at = Time.now if @columns.index(:updated_at)", :eol,
        "      row.save", :eol,
        "      redirect(\"/", :model_string_singular, "/index\")", :eol,
        "    end", :eol,
        "    redirect(\"/", :model_string_singular, "/index\")", :eol,
        "  end", :eol,
        :eol,
        "end", :eol ]
    end

    ##
    # This method builds the controller.
    #
    # @param Hash args A has containing the options.
    #
    # @param HashElement :model The name of the database table for
    #  which the controller will be built. This name must be lower
    #  case singular symbol and there must be a table in the database
    #  which has this name as lower case plural.
    #
    # @example A table named 'coltypes'. The table must exist in the DB.
    #
    #  :model => :coltype
    #
    # @param HashElement :index_columns => [ ... ] A list of the
    #  columns to display in the 'index' method as a list of Symbols.
    #  Since fields are listed horizontally, be careful not to list
    #  too many.
    #
    # @example A list of fields.
    #
    #  :index_columns=>[:id, :vc255, :int11]
    #
    # @param HashElement :new_columns => [ ... ] A list of the columns
    #  to be displayed on the 'new' page. DON'T include the table's
    #  primary key in this list. Usually you would not include :created_at
    #  or :updated_at, if the table has those fields. The controller
    #  updates those automatically.
    #
    # @param HashElement :show_columns => [ ... ] A list of columns
    #  to be displayed on the 'show' page. Just omit this option to
    #  show all the fields (recommended).
    #
    # @option HashElement :edit_columns => [ ... ] A list of columns
    #  to permit editing on the 'edit' page. DON'T include the table's
    #  primary key in this list. Usually you would not include :created_at
    #  or :updated_at, if the table has those fields. The controller
    #  updates those automatically.
    #
    # BUILDING A CONTROLLER
    # If you do not have a Sequel::Model for the table, create an empty one.
    #
    # @example Create an empty 'coltypes' table model.
    #
    #  class Coltype < Sequel::Model
    #  end
    #
    #  Call the build routine, and direct the output to 'class_eval'.
    #
    # In 'controller/init.rb' (just a suggestion), add this code:
    # 
    #  Object::class_eval(Scaffolding.new.build_controller(
    #    :model=>:coltype,
    #    :index_columns=>[:id, :vc255, :int11],
    #    :new_columns=>[:id, :vc255, :int11],
    #    :show_columns=>[:id, :vc255, :int11],
    #    :edit_columns=>[:id, :vc255, :int11]
    #  ))
    #
    def build_controller(args)
      # Prepare the substitution parameters
      @constant = constant = {}

      constant[:model_symbol_singular] = args[:model]
      constant[:model_string_singular] = args[:model].to_s
      constant[:model_string_plural] = args[:model].to_s.pluralize
      constant[:model_string_plural_camel] = constant[:model_string_singular].pluralize.camelize
      constant[:model_string_singular_camel] = constant[:model_string_singular].camelize

      @schema = DB.schema(constant[:model_string_plural]).to_h
      @columns = @schema.keys
      @index_columns = if args.has_key?(:index_columns) then args[:index_columns] else @columns end
      @new_columns = if args.has_key?(:new_columns) then args[:new_columns] else @columns end
      @show_columns = if args.has_key?(:show_columns) then args[:show_columns] else @columns end
      @edit_columns = if args.has_key?(:edit_columns) then args[:edit_columns] else @columns end

      @schema.each do |name,properties|
        # see if it has something like decimal[10,2], decimal[2], or just decimal
        db_type = properties[:db_type]
        case
        when m = db_type.match(/^([a-z]*)\(([0-9]*),([0-9]*)\)$/)
          a = m[2].to_i
          b = m[3].to_i
        when m = db_type.match(/^([a-z]*)\(([0-9]*)\)$/)
          a = m[2].to_i
          b = 0
        else
          a = 0
          b = 0
        end

        case properties[:type]
        when :integer
          a = 11 if a==0
          width = a
          boxtype = :number
        when :string
          a = 32 if a==0 || a>80
          width = a
          boxtype = if properties[:db_type]=='text' then :textarea else :text end
        when :blob
          width = 80
          boxtype = :textarea
        when :float
          a = 16 if a==0
          width = a
          boxtype = :text
        when :decimal
          a = 12 if a==0
          width = a
          boxtype = :text
        when :date
          width = 10
          boxtype = :date
        when :datetime
          width = 17
          boxtype = :datetime
        when :time
          width = 8
          boxtype = :time
        when :boolean
          width = 0
          boxtype = :checkbox
        end

        properties[:width] = width
        properties[:boxtype] = boxtype
      end

      @source = []
      source(@prototype)
      @source.join
    end

private

    # As the prototype code above is passed to this method, it copies Strings to the
    # output, and processes the Symbols as appropriate. It cannot be called by the user.
    def source(objs)
      objs.each do |obj|
        case
        when obj==:new_columns
          @new_columns.each do |col|
           field(:new, col, @schema[col])
          end
        when obj==:show_columns
          @show_columns.each do |col|
           field(:show, col, @schema[col])
          end
        when obj==:edit_columns
          @edit_columns.each do |col|
           field(:edit, col, @schema[col])
          end
        when obj==:columns_list
          @source << @columns.inspect
        when obj==:index_columns_list
          @source << @index_columns.inspect
        when obj==:new_columns_list
          @source << @new_columns.inspect
        when obj==:show_columns_list
          @source << @show_columns.inspect
        when obj==:edit_columns_list
          @source << @edit_columns.inspect
        when obj==:eol
          @source << "\n"
        when obj.class==String
          @source << obj
        when obj.class==Symbol
          @source << @constant[obj]
        end
      end
    end

    ##
    # This method is used by 'build_controller' to generate each set of
    # code for each field specified. It cannot be called by the user.
    def field(type, col, properties)
      disabled = if type==:show then ", :disabled=>true" else "" end
      source(["          @g.tr do", :eol])
      source(["            @g.td { @g.strong { \"#{col.to_s.humanize}\" } }", :eol])
      source(["            @g.td do", :eol])
      case properties[:boxtype]
      when :checkbox
        source([
          "              @g.input(:type=>:hidden, :name=>#{col.inspect}, :id=>\"form_#{col.to_s}\", :value=>0)", :eol,
          "              opts = {:type=>:checkbox, :name=>#{col.inspect}, :id=>\"form_#{col.to_s}\", :value=>1#{disabled}}", :eol,
          "              opts[:checked] = true if row[#{col.inspect}]", :eol,
          "              @g.input(opts)", :eol ])
      when :number
        source(["              opts = @g.input(:type=>:number, :name=>#{col.inspect}, :value=>row[#{col.inspect}], :size=>#{properties[:width]}, :id=>\"form_#{col}\"#{disabled})", :eol])
      when :text
        source(["              @g.input(:type=>:text, :name=>#{col.inspect}, :value=>row[#{col.inspect}], :size=>#{properties[:width]}, :id=>\"form_#{col}\"#{disabled})", :eol])
      when :date
        source(["              @g.input(:type=>:text, :name=>#{col.inspect}, :value=>row[#{col.inspect}].strftime(\"%Y-%m-%d\"), :size=>#{properties[:width]}, :id=>\"form_#{col}\"#{disabled})", :eol])
      when :datetime
        source(["              @g.input(:type=>:text, :name=>#{col.inspect}, :value=>row[#{col.inspect}].strftime(\"%Y-%m-%d %H:%M:%S\"), :size=>#{properties[:width]}, :id=>\"form_#{col}\"#{disabled})", :eol])
      when :time
        source(["              @g.input(:type=>:text, :name=>#{col.inspect}, :value=>row[#{col.inspect}].strftime(\"%H:%M:%S\"), :size=>#{properties[:width]}, :id=>\"form_#{col}\"#{disabled})", :eol])
      when :textarea
        source(["              @g.textarea(:name=>#{col.inspect}, :rows=>5, :cols=>#{properties[:width]}, :id=>\"form_#{col}\"#{disabled}) { row[#{col.inspect}] }", :eol])
      end
      source(["            end", :eol])
      source(["          end", :eol])
    end

  end

end
