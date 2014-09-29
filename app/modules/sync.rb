module Sync
  module Cosdna
    class Database
      attr_reader :files if ENV['RACK_ENV'] = 'test'

      def initialize(folder_path, files_to_sync)
        @folder_path = folder_path
        @files_to_sync = files_to_sync
        @files = []
      end

      def syncFiles
        product_number = 0
        @files_to_sync.each do |file_name|
          product_number += 1
          syncWithDatabase(File.new(@folder_path + file_name))
          p "#{product_number} product(s) added to database"

        end
      end

      def insertProduct(product)
        formatted_name = format_name(product.name)
        if Product.find_by(name: formatted_name).nil?
          Product.create(name: formatted_name, image_cosdna: product.image_location)
        end
      end

      def insertIngredient(ingredient, product)
        ingredient_check = Ingredient.find_by(name: format_name(ingredient[:name]))
        if ingredient_check.nil?
          new_ingredient = Ingredient.create(
            name: format_name(ingredient[:name]),
            acne: ingredient[:acne],
            irritant: ingredient[:irritant],
            safety: ingredient[:safety],
            uva: ingredient[:uv][:uva],
            uvb: ingredient[:uv][:uvb],
            functions: ingredient[:functions].join(", ")
          )
          ProductIngredient.create(ingredient: new_ingredient, product: product)
        else
          ProductIngredient.create(ingredient: ingredient_check, product: product)
        end
      end

      def syncWithDatabase(file)
        new_product = insertProduct(file)
        if !(new_product.nil?)
          file.ingredient_list.each do |ingredient|
            insertIngredient(ingredient, new_product)
          end
        end
      end

      private

      def format_name(name)
        name.split(" ").map!{|w| w.capitalize}.join(" ")
      end
    end

    class File
      attr_reader :name, :ingredient_list, :image_location
      attr_writer :name if ENV['RACK_ENV'] = 'test'

      def initialize(file_path)
        @file_path = file_path
        @page = Nokogiri::HTML(open(file_path))
        @ingredient_list = []
        @name = ""
        @image_location
        parseCosDNAProduct
      end

      def parseCosDNAProduct
        p "Parsing product #{@file_path}..."
        parseName
        parseImageLocation
        parseIngredients
      end

      def parseName
        @name = @page.css('.ProdTitleName').children.text
      end

      def parseImageLocation
        image_array = @page.css('#Ing_ProdImg').children
        image_location = image_array[0].attributes["src"].value if image_array.length > 0
        @image_location = image_location unless (image_location.nil? || image_location.empty?)
      end

      def createRowIndicators(table_rows)
        p 1
        p "#{table_rows}" if @file_path == "app/cosdna_html/cosmetic_d7a0140117.html"
        p 2
        p "#{table_rows[0]}" if @file_path == "app/cosdna_html/cosmetic_d7a0140117.html"
        p 3
        p "#{table_rows[0].children}" if @file_path == "app/cosdna_html/cosmetic_d7a0140117.html"
        p 4
        p "#{table_rows[0].children.children}" if @file_path == "app/cosdna_html/cosmetic_d7a0140117.html"
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
end