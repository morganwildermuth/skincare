module Sync
  class Database
    attr_reader :productName, :ingredientList

    def initialize(file_path)
      @page = Nokogiri::HTML(open(file_path))
      @ingredientList = []
      @productName = ""
    end

    def parseCosDNAProduct
      parseName
      parseIngredients
    end

    def parseName
      @productName = @page.css('.ProdTitleName').children.text
    end

    def createRowIndicators(table_rows)
      row_indicators = {}
      table_rows[0].children.children.each_with_index do |row, i|
        row_indicators[row.text.strip] = (i * 2)
      end
      row_indicators
    end

    def setIngredientName(row, childRow)
      row.children[childRow].children.text()
    end

    def setFunctions(row, childRow)
      functions = row.children[childRow].children.children
      functionList = functions.map(&:text).reject{|element| element.blank?}
    end

    def setAcne(row, childRow)
      row.children[childRow].children.text()
    end

    def setIrritant(row, childRow)
      row.children[childRow].children.text()
    end

    def setSafety(row, childRow)
      safety = row.children[childRow].children[0].attributes["src"]
      safetyImage = safety.value().split("/").last if safety
    end

    def setUV(row, childRow)
      if childRow
        uva = row.children[childRow].children[0]
        uva = uva.attributes["title"].value if uva
        uvb = row.children[childRow].children[2]
        uvb = uvb.attributes["title"].value if uvb
        {uva: uva, uvb: uvb}
      else
        {}
      end
    end

    def parseIngredients
      table_rows = @page.css(".iStuffTable tr")
      row_indicators = createRowIndicators(table_rows)
      table_rows.each_with_index do |row, i|
        if i != 0
          name = setIngredientName(row, row_indicators["Ingredient"])
          functions = setFunctions(row, row_indicators["Function"])
          acne = setAcne(row, row_indicators["Acne"])
          irritant = setIrritant(row, row_indicators["Irritant"])
          safety = setSafety(row, row_indicators["Safety"])
          uv = setUV(row, row_indicators["UV"])
          @ingredientList << {name: name, functions: functions, acne: acne, irritant: irritant, safety: safety, uv: uv}
        end
      end
    end
  end
end