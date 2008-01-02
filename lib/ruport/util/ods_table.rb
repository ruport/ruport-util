require 'ruport'

# === Overview
#
# This class extends the core class Ruport::Data::Table and adds support for loading Openoffice
# spreadsheet files using roo. The idea is to get data from speadsheets that may contain
# already calculated values entered by non-programmers.
#
# Once your data is in a Table object, it can be manipulated
# to suit your needs, then used to build a report.
#
# Copyright (C) 2007, Wes Hays
# All Rights Reserved.
#
class Ruport::Data::Table

  # === Overview
  #
  # This module provides facilities for creating tables from Openoffice spreadsheet file (ods).
  #
  module FromODS
    # Loads a ods file directly into a Table using the roo library.
    #
    # Example:
    #   
    #   # Load data from Openoffice ods file with defaults
    #   table = Table.load_ods('myspreadsheet.ods')
    #
    #   # do not assume the data has column names - default is false.
    #   table = Table.load_ods('myspreadsheet.ods',{:has_column_names => false})
    #
    #   # Select sheet - default is the first sheet.
    #   table = Table.load_ods('myspreadsheet.ods', {:select_sheet => 1})
    #
    def load_ods(ods_file, options={})
      get_table_from_ods_file(ods_file, options)
    end

    # Creates a Table from an Openoffice object (from roo library). 
    #
    # Example:
    #   
    #   # parse openoffice object with defaults. 
    #   table = Table.parse_ods(openoffice_object)
    #
    #   # do not assume the data has column names.
    #   table = Table.parse_ods(openoffice_object,{:has_column_names => false})
    #
    #   # Select sheet - default is the first sheet.
    #   table = Table.parse_ods(openoffice_object, {:select_sheet => 1})
    #
    def parse_ods(ods_object, options={})
      get_table_from_ods(ods_object, options)
    end      

    private

    def get_table_from_ods_file(ods_file, options) #:nodoc:
      require 'roo'
      oo = Openoffice.new(ods_file)
      get_table_from_ods(oo, options)
    end

    def get_table_from_ods(oo, options) #:nodoc:
      # Don't need to require 'roo' here because 
      oo.default_sheet = oo.sheets.first
      options = {:has_column_names => true, :select_sheet => oo.sheets.first}.merge(options)        
      start_row = options[:has_column_names] == true ? 2 : 1

      table = self.new(options) do |feeder|            
        
        # This is fine because they should all be strings
        feeder.data.column_names = oo.row(1) if options[:has_column_names] == true
        
        # don't loop through the rows if they are none
        unless oo.last_row.nil?
          # Loop through and grab each cell that way the data types
          # are captured as well.
          start_row.upto(oo.last_row) do |row|
            tempArr = []
            1.upto(oo.last_column) do |col|
              tempArr << oo.cell(row,col)
            end
            feeder << tempArr
          end 
        end
        
      end

      return table        
    end

  end # End FromODS

  extend FromODS

end # End class Table
    

module Kernel
  
  # Use Ruport's original Table method if this Table method is not needed.
  alias :RuportTableMethod :Table
  
  # Updates the Ruport interface for creating Data::Tables with
  # the ability to pass in a ODS file or Roo Openoffice object.
  #
  #   t = Table("myspreadsheet.ods")
  #   t = Table("myspreadsheet.ods", :has_column_names => true)
  def Table(*args,&block)
    table=
    case(args[0])
    when /\.ods/
      Ruport::Data::Table.load_ods(*args)
    else
      RuportTableMethod(*args,&block)
    end             
    
    return table
  end
end  
