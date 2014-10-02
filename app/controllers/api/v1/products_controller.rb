class Api::V1::ProductsController < API::V1::BaseController
  respond_to :json

  def index
    product_objects  = create_product_objects(params)

    product_objects = product_objects.partition{|product| product[:record] == nil || product[:record].variety != product[:variety]}
    suggestions = set_suggestions(product_objects)
    suggestions.select! do |suggestion|
      if suggestion[:fixed] == true
        suggestion[:record] = Product.find_by(name: suggestion[:name])
        if suggestion[:record]
          product_objects[1] << suggestion
        else
          suggestion[:fixed] = false
        end
      end
      suggestion[:fixed] == nil ||  suggestion[:fixed] == false
    end
    product_objects = product_objects[1]

    product_objects = product_objects.map!{|product|
      product[:record].update_attributes(variety: product[:variety]) if product[:record].variety == nil
    }

    render json: {data: {products: product_objects, suggestions: suggestions}}
  end

  private

  def permit_params
    params.permit(:user_id, :recording_id, :email, :state, :token) # Assuming we will get response without info wrapped in patient object
  end

  def create_product_objects(params)
    product_objects = []
    params = params.select{|key, value| key != "action" && key != "controller" && key != "format"}
    params.each do |key, value|
      product_objects << {variety: key, record: Product.find_by(name: value), name: value}
    end
    product_objects
  end

  def set_suggestions(product_objects)
    suggestions = product_objects[0]
    suggestions.map!{|product| product[:record].nil? ? product = set_db_suggestion(product) : product = set_type_suggestion(product); product} if suggestions
    suggestions
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