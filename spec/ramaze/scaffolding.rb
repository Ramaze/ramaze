# * Encoding: UTF-8
#
#          Copyright (c) 2009 Michael J. Welch, Ph.D. mjwelchphd@gmail.com
# All files in this distribution are subject to the terms of the MIT license.

require 'sqlite3'
require 'sequel'

require File.expand_path('../../../spec/helper', __FILE__)

require 'ramaze/scaffolding'

# create some test data
DB = Sequel.sqlite
DB::drop_table?(:coltypes)
DB::create_table(:coltypes) do          # common database type used
  primary_key :id                       # int(11) + primary key
  Integer :int11                        # int(11)
  String :vc255                         # varchar(255)
  String :vc50, :size=>50               # varchar(50)
  String :c255, :fixed=>true            # char(255)
  String :c50, :fixed=>true, :size=>50  # char(50)
  String :text, :text=>true             # text
  File :blob                            # blob
  Fixnum :fixnum                        # int(11)
  Bignum :bignum                        # bigint(20)
  Float :dblflt                         # double
  BigDecimal :bigdec                    # decimal(10,0)
  BigDecimal :big6dec, :size=>6         # decimal(6,0)
  BigDecimal :big10dec2, :size=>[10, 2] # decimal(10,2)
  Date :justdate                        # date
  DateTime :datetime                    # datetime
  Time :justtime                        # datetime
  Time :timeonly, :only_time=>true      # time
  Numeric :numeric                      # decimal(10,0)
  TrueClass :booltrue                   # tinyint(1)
  FalseClass :boolfalse                 # tinyint(1)
  DateTime :created_at                  # datetime
  DateTime :updated_at                  # datetime
end
dataset = DB[:coltypes]
dataset.insert(:vc255=>"Coco", :text=>"Species: Cocosaurus Rex", :blob=>"Good bird!", :created_at=>Time.now, :updated_at=>Time.now)

describe 'Ramaze::Scaffolding' do

known_code = <<END_TEXT
class NilClass
  def strftime(pattern)
    \"\"
  end
end

class ColtypeController < Controller

  map '/coltype'

  def initialize
    @columns = [:id, :int11, :vc255, :vc50, :c255, :c50, :text, :blob, :fixnum, :bignum, :dblflt, :bigdec, :big6dec, :big10dec2, :justdate, :datetime, :justtime, :timeonly, :numeric, :booltrue, :boolfalse, :created_at, :updated_at]
    @index_columns = [:id, :vc255, :int11]
    @new_columns = [:id, :vc255, :int11]
    @show_columns = [:id, :vc255, :int11]
    @edit_columns = [:id, :vc255, :int11]
  end

  def index
    @g = Ramaze::Gestalt.new
    @title = \"List of Coltypes\"
    @g.scaffolding do
      rows = Coltype.select(*@index_columns).all
      @g.h3 { @title }
      @g.p do
        @g.a(:href=>\"/coltype/new\") { \"new\" }
      end
      @g.table do
        # create the heading
        @g.tr do
          @index_columns.each do |col|
            @g.td do
              @g.strong { col.to_s.titleize }
            end
          end
        end
        # list all the rows
        rows.each do |row|
          @g.tr do
            row.each do |col,value|
              @g.td { value.to_s }
            end
            @g.td do
              @g.a(:href=>\"/coltype/show?id=%s\"%row[:id]) { \"show\" }
              @g << \" | \"
              @g.a(:href=>\"/coltype/edit?id=%s\"%row[:id]) { \"edit\" }
              @g << \" | \"
              @g.a(:href=>\"/coltype/show?id=%s&delete\"%row[:id]) { \"delete\" }
            end
          end
        end
      end
    end
    @g.to_s
  end

  def new
    @g = Ramaze::Gestalt.new
    @title = \"New Coltype\"
    @g.scaffolding do
      @g.h3 { @title }
      row = Coltype.new
      @g.form(:method=>:post, :action=>:save_new) do
        @g.table do
          @g.tr do
            @g.td { @g.strong { \"Id\" } }
            @g.td do
              opts = @g.input(:type=>:number, :name=>:id, :value=>row[:id], :size=>11, :id=>\"form_id\")
            end
          end
          @g.tr do
            @g.td { @g.strong { \"Vc255\" } }
            @g.td do
              @g.input(:type=>:text, :name=>:vc255, :value=>row[:vc255], :size=>32, :id=>\"form_vc255\")
            end
          end
          @g.tr do
            @g.td { @g.strong { \"Int11\" } }
            @g.td do
              opts = @g.input(:type=>:number, :name=>:int11, :value=>row[:int11], :size=>11, :id=>\"form_int11\")
            end
          end
        end
        @g.br
        @g.input(:type=>:submit, :id=>\"goto\", :name=>\"goto\", :value=>\"Back\")
        @g << \"&nbsp;\"
        @g.input(:type=>:submit, :id=>\"goto\", :name=>\"goto\", :value=>\"Save\")
      end
    end
    @g.to_s
  end

  def show
    @g = Ramaze::Gestalt.new
    @title = \"Show Coltype\"
    @g.scaffolding do
      @g.h3 { @title }
      row = Coltype.where(:id=>session.request.params['id']).first
      @g.form(:method=>:post, :action=>:save_show) do
        @g.input(:type=>:hidden, :name=>:id, :value=>row.id)
        @g.table do
          @g.tr do
            @g.td { @g.strong { \"Id\" } }
            @g.td do
              opts = @g.input(:type=>:number, :name=>:id, :value=>row[:id], :size=>11, :id=>\"form_id\", :disabled=>true)
            end
          end
          @g.tr do
            @g.td { @g.strong { \"Vc255\" } }
            @g.td do
              @g.input(:type=>:text, :name=>:vc255, :value=>row[:vc255], :size=>32, :id=>\"form_vc255\", :disabled=>true)
            end
          end
          @g.tr do
            @g.td { @g.strong { \"Int11\" } }
            @g.td do
              opts = @g.input(:type=>:number, :name=>:int11, :value=>row[:int11], :size=>11, :id=>\"form_int11\", :disabled=>true)
            end
          end
        end
        @g.br
        @g.input(:type=>:submit, :id=>\"goto\", :name=>\"goto\", :value=>\"Back\")
        if session.request.params.has_key?('delete')
          @g << \"&nbsp;\"
          @g.input(:type=>:submit, :id=>\"goto\", :name=>\"goto\", :value=>\"Delete\")
        end
      end
    end
    @g.to_s
  end

  def edit
    @g = Ramaze::Gestalt.new
    @title = \"Edit Coltype\"
    @g.scaffolding do
      @g.h3 { @title }
      row = Coltype.where(:id=>session.request.params['id']).first
      row.updated_at = Time.now
      @g.form(:method=>:post, :action=>:save_edit) do
        @g.input(:type=>:hidden, :name=>:id, :value=>row.id)
        @g.table do
          @g.tr do
            @g.td { @g.strong { \"Id\" } }
            @g.td do
              opts = @g.input(:type=>:number, :name=>:id, :value=>row[:id], :size=>11, :id=>\"form_id\")
            end
          end
          @g.tr do
            @g.td { @g.strong { \"Vc255\" } }
            @g.td do
              @g.input(:type=>:text, :name=>:vc255, :value=>row[:vc255], :size=>32, :id=>\"form_vc255\")
            end
          end
          @g.tr do
            @g.td { @g.strong { \"Int11\" } }
            @g.td do
              opts = @g.input(:type=>:number, :name=>:int11, :value=>row[:int11], :size=>11, :id=>\"form_int11\")
            end
          end
        end
        @g.br
        @g.input(:type=>:submit, :id=>\"goto\", :name=>\"goto\", :value=>\"Back\")
        @g << \"&nbsp;\"
        @g.input(:type=>:submit, :id=>\"goto\", :name=>\"goto\", :value=>\"Save\")
      end
    end
    @g.to_s
  end

  def save_new
    if session.request.params['goto']==\"Save\"
      row = Coltype.new
      row.set_fields(session.request.params, @new_columns, :missing=>:skip)
      row.id = nil
      row.created_at = Time.now if @columns.index(:created_at)
      row.updated_at = Time.now if @columns.index(:updated_at)
      row.save
    end
    redirect(\"/coltype/index\")
  end

  def save_show
    if session.request.params['goto']==\"Delete\"
      row = Coltype.where(:id=>session.request.params['id']).first
      row.delete
    end
    redirect(\"/coltype/index\")
  end

  def save_edit
    if session.request.params['goto']==\"Save\"
      row = Coltype.where(:id=>session.request.params['id']).first
      row.set_fields(session.request.params, @edit_columns, :missing=>:skip)
      row.updated_at = Time.now if @columns.index(:updated_at)
      row.save
      redirect(\"/coltype/index\")
    end
    redirect(\"/coltype/index\")
  end

end
END_TEXT

  it "should create a CRUD controller for ColtypeController" do
    test_code = Ramaze::Scaffolding.new.build_controller(
      :model=>:coltype,
      :index_columns=>[:id, :vc255, :int11],
      :new_columns=>[:id, :vc255, :int11],
      :show_columns=>[:id, :vc255, :int11],
      :edit_columns=>[:id, :vc255, :int11]
    )
    known_code_lines = known_code.split("\n")
    test_code_lines = test_code.split("\n")

    n = known_code_lines.size
    0.upto(n-1) do |i|
      known_code_lines[i].should == test_code_lines[i]
    end

  end

end
