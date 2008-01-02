# Copyright (C) 2007, Wes Hays
# All Rights Reserved.

require 'test/helper'
testcase_requires 'roo'

describe 'Ruport::Data::TableFromODS' do
  before(:each) do
    @ods_file_column_names = %w(Name Age DOB)
    @ods_file = 'test/samples/people.ods'
    @csv_file = 'test/samples/data.csv'
    @rows = [ ['Andy',    27.0, Date.parse('01/20/1980')], 
              ['Bob',     26.0, Date.parse('02/11/1981')],
              ['Charlie', 20.0, Date.parse('03/14/1987')],
              ['David',   73.0, Date.parse('04/26/1997')] ]
  end

  # ==== File check ====
  # Raise error if file is not found
  it "should raise if ods file is not found" do
    lambda do
      Ruport::Data::Table.load_ods('people.ods')
    end.should raise_error
  end
  
  # Raise error if file is not found
  it "shouldn't raise if ods file exists" do
    lambda do
      Ruport::Data::Table.load_ods(@ods_file)
    end.should_not raise_error
  end  
  
  
  # ==== Constructor check ====
  it "shouldn't be nil if a ods file is passed" do
    table = Ruport::Data::Table(@ods_file)
    table.should_not be_nil
  end  
  
  it "shouldn't be nil if a Openoffice object is passed" do
    oo = Openoffice.new(@ods_file)
    oo.default_sheet = oo.sheets.first
    table = Ruport::Data::Table(oo) # This will be passed to the base Ruport::Data::Table class.
    table.should_not be_nil
  end
  
  it "shouldn't be nil if a Ruport::Data::Ruport::Data::Table parameter is passed" do
    table = Ruport::Data::Table(@csv_file) # Pass cs file
    table.should_not be_nil
  end  
  
  
  # ==== Constructor check with options params ====
  it "shouldn't be nil if a ods file is passed with options params" do
    table = Ruport::Data::Table(@ods_file, {:has_column_names => false})
    table.should_not be_nil
  end  
  
  it "shouldn't be nil if a Openoffice object is passed with options params using parse_ods method" do
    oo = Openoffice.new(@ods_file)
    oo.default_sheet = oo.sheets.first
    table = Ruport::Data::Table.parse_ods(oo, {:has_column_names => false})
    table.should_not be_nil
  end
  
  it "shouldn't be nil if a Ruport::Data::Ruport::Data::Table parameter is passed with options params" do
    table = Ruport::Data::Table(@csv_file, {:has_column_names => false}) # Pass cs file
    table.should_not be_nil
  end  
  
  
  # ==== Ruport::Data::Table load check ====
  it "table should be valid without column names loaded from ods file " do
    # Load data from ods file but do not load column headers.
    table = Ruport::Data::Table(@ods_file, {:has_column_names => false})
    table.should_not be_nil
    table.column_names.should == [] 
    
    # Add headers to the first position
    @rows.insert(0, @ods_file_column_names)
    
    table.each { |r| r.to_a.should == @rows.shift
                     r.attributes.should == [0, 1, 2] }  
  end
  
  it "table should be valid with column names loaded from ods file " do
    # Load data from ods file but do not load column headers.
    table = Ruport::Data::Table(@ods_file)
    table.should_not be_nil
    table.column_names.should == @ods_file_column_names
    
    
    table.each { |r| r.to_a.should == @rows.shift
                     r.attributes.should == @ods_file_column_names }  
  end  
  
  it "should be valid if an Openoffice object is passed using parse_ods method" do
    oo = Openoffice.new(@ods_file)
    oo.default_sheet = oo.sheets.first
    table = Ruport::Data::Table.parse_ods(oo)
    table.should_not be_nil
    
    table.column_names.should == @ods_file_column_names
    
    table.each { |r| r.to_a.should == @rows.shift
                     r.attributes.should == @ods_file_column_names }    
  end  
  
end

    
    
  