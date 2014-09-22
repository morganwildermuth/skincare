module Sync

  class Database

    def initialize(folder_path, files_to_sync)
      @folder_path = folder_path
      @files_to_sync = files_to_sync
      @hashed_files = []
    end

    def syncFiles
      @files_to_sync.slice(0..10).each do |file_name|
        @hashed_files << Sync::File.new(@folder_path + file_name).ingredient_list
      end
      syncWithDatabase
    end

    def syncWithDatabase
      @hashed_files.each do |product|
        product.each do |ingredient|
          p ingredient
          p "Name"
          p ingredient[:name]
          p "functions"
          p ingredient[:functions].join(", ") unless ingredient[:functions].empty?
          p "acne"
          p ingredient[:acne].to_i if !(ingredient[:acne].empty?)
          p "irritant"
          p ingredient[:irritant].to_i if !(ingredient[:irritant].empty?)
          p "safety"
          p ingredient[:safety] unless ingredient[:safety].nil?
          if ingredient[:uv]
            p "uva"
            p ingredient[:uv][:uva] unless  ingredient[:uv][:uva].nil?
            p "uvb"
            p ingredient[:uv][:uvb] unless  ingredient[:uv][:uvb].nil?
          end
          # t.string :name
          # t.integer :acne
          # t.integer :irritant
          # t.integer :safety
          # t.string :uva
          # t.string :uvb
          # t.string :functions
        end
      end
    end

  end

  class File
    attr_reader :product_name, :ingredient_list

    def initialize(file_path)
      @page = Nokogiri::HTML(open(file_path))
      @ingredient_list = []
      @product_name = ""
      parseCosDNAProduct
    end

    def parseCosDNAProduct
      parseName
      parseIngredients
    end

    def parseName
      @product_name = @page.css('.ProdTitleName').children.text
    end

    def createRowIndicators(table_rows)
      row_indicators = {}
      table_rows[0].children.children.each_with_index do |row, i|
        row_indicators[row.text.strip] = (i * 2)
      end
      row_indicators
    end

    def getBasicProductRows(row, row_indicators, *column_headers)
      rows = {}
      column_headers.each do |column|
        rows[column] = row.children[row_indicators[column]].children.text()
      end
      rows
    end

    def getFunctions(row, childRow)
      functions = row.children[childRow].children.children
      functionList = functions.map(&:text).reject{|element| element.blank?}
    end

    def getSafety(row, childRow)
      safety = row.children[childRow].children[0].attributes["src"]
      safetyImage = safety.value.split("/").last if safety
      case safetyImage
      when "d1.gif"
        rating = 0
      when "d2.gif"
        rating = 1
      when "d3.gif"
        rating = 2
      when "d4.gif"
        rating = 3
      when "d5.gif"
        rating = 4
      end
      rating
    end

    def getUVNumber(uvString)
      case uvString
      when "limited"
        return 1
      when "considerable"
        return 2
      when "extensive"
        return 3
      end
    end

    def getUVString(row, childRow, childRowTwo)
      data_exists = row.children[childRow].children[childRowTwo]
      data_exists.attributes["title"].value if data_exists
    end

    def getUV(row, childRow)
      if childRow
        uva = getUVString(row, childRow, 0)
        uvb = getUVString(row, childRow, 2)
        uva = getUVNumber(uva)
        uvb = getUVNumber(uvb)
        {uva: uva, uvb: uvb}
      else
        {}
      end
    end

    def ingredientDetailsExist?(row)
      row.children.length != 2
    end

    def parseIngredients
      table_rows = @page.css(".iStuffTable tr")
      row_indicators = createRowIndicators(table_rows)
      table_rows.each_with_index do |row, i|
        if i != 0 && ingredientDetailsExist?(row)
          product_rows = getBasicProductRows(row, row_indicators, "Ingredient", "Acne", "Irritant")
          functions = getFunctions(row, row_indicators["Function"])
          safety = getSafety(row, row_indicators["Safety"])
          uv = getUV(row, row_indicators["UV"])
          @ingredient_list << {name: product_rows["Ingredient"], functions: functions, acne: product_rows["Acne"], irritant: product_rows["Irritant"], safety: safety, uv: uv}
        end
      end
    end
  end
end