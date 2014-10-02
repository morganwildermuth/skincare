module SearchObjectFactory
  class SearchObject
    attr_reader :product_objects, :suggestion_objects
    def initialize(params)
      @initial_params = params
      @params = parse_product_params(@initial_params)
      @product_objects = []
      @suggestion_objects = []
      create_objects
    end

    private

    def create_objects
      create_basic_objects(@params)
      @product_objects = product_objects.partition{|product| product[:record] == nil || product[:record].variety != product[:variety]}
      create_suggestion_product_objects
    end

    def update_product_objects
      @product_objects = @product_objects.map!{|product|
        product[:record].update_attributes(variety: product[:variety]) if product[:record].variety == nil
        product
      }
    end

    def parse_product_params(params)
      params = params.select{|key, value| key != "action" && key != "controller" && key != "format"}
    end

    def create_basic_objects(params)
      params.each do |key, value|
        @product_objects << {variety: key, record: Product.find_by(name: value), name: value}
      end
    end

    def create_suggestion_product_objects
      set_suggestions
      reassess_suggestions_for_products
      @product_objects = @product_objects[1]
      update_product_objects
    end

    def reassess_suggestions_for_products
      @suggestion_objects.select! do |suggestion|
        if suggestion[:fixed] == true
          suggestion[:record] = Product.find_by(name: suggestion[:name])
          if suggestion[:record]
            @product_objects[1] << suggestion
          else
            suggestion[:fixed] = false
          end
        end
        suggestion[:fixed] == nil ||  suggestion[:fixed] == false
      end
    end

    def set_suggestions
      @suggestion_objects = @product_objects[0]
      @suggestion_objects.map!{|product| product[:record].nil? ? product = set_db_suggestion(product) : product = set_type_suggestion(product); product} if @suggestion_objects.length > 0
    end

    def set_db_suggestion(product)
      product[:issue] = "db"
      cosdna_links = search_cosdna(product)
      if cosdna_links.length == 1
        product = add_cosdna_product_to_database(cosdna_links[0], product)
        product[:fixed] = true
      else
        create_suggestion_hash_for_cosdna_links(cosdna_links)
        ## add relevant hash to product hash
      end
      product
    end

    def set_type_suggestion(product)
      product[:issue] = "type"
      product
    end

    def search_cosdna(product)
      product_name = product[:name]
      cosdna_query = product_name.gsub(" ", "+")
      links_with_unique_names = []
      page = Mechanize.new.get('http://cosdna.com/eng/product.php?q=' + cosdna_query)
      links = page.links_with(:href => %r{^cosmetic_}).slice(0, 3)
      unique_links = links.uniq{|link| link.text}
    end

    def add_cosdna_product_to_database(cosdna_link, product)
      cosdna_file = Sync::Cosdna::File.new("http://cosdna.com/eng/" + cosdna_link.href)
      sync_database = Sync::Cosdna::Database.new
      sync_database.syncWithDatabase(cosdna_file)
      product[:potential_intended_search_name] = cosdna_file.name
      product
    end
  end
end