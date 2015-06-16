class Checkout
  attr_accessor :discounts
  attr_reader :products

  def initialize(discounts)
    @discounts = discounts
    @products = Hash.new
  end

  def regular_prices
    # Read only prices
    {
      'AM' => 3.11,
      'AC' => 5,
      'CA' => 11.23
    }
  end

  def scan(product_code)
    # Product existence validation
    if self.regular_prices.include? product_code
      # We add the current article type to our shopping list
      self.products[product_code] = Array.new unless self.products.include? product_code

      # ...and get the price of this very precise item, depending on the discounts 
      product_price = if self.discounts.include? product_code
        self.compute_discounts(product_code)
      else
        self.regular_prices[product_code]
      end

      self.products[product_code].push product_price
      product_price
    else
      raise 'Product not recognized'
    end
  end

  def total
    tmp_total = self.products.values.flatten.reduce(:+)

    tmp_total.is_a?(Numeric) ? tmp_total : 0
  end

  protected

    def compute_discounts(product_code)
      if self.discounts.include? product_code
        product_discount = self.discounts[product_code]
        real_product_length = self.products[product_code].length + 1

        case product_discount

          # 2x1 discount: one of every 2 items is free
          when '2x1'
            if real_product_length.odd?
              self.regular_prices[product_code]
            else
              0
            end

          # 3x2 discount: one of every 3 items is free
          when '3x2'
            if real_product_length % 3 == 0
              0
            else
              self.regular_prices[product_code]
            end

          # quantity discount: the first position of the array sets what's the minimum of items to buy to apply, the second one is the new price
          when Array
            if real_product_length >= product_discount[0]
              self.products[product_code].map!{ |x| x = product_discount[1] } unless self.products[product_code][0] == product_discount[1]

              product_discount[1]
            else
              self.regular_prices[product_code]
            end

          else
            # Discount existence validacion
            raise 'Discount unknown'
        end
      else
        self.regular_prices[product_code]
      end
    end
end