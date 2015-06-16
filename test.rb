require_relative 'checkout'

discounts = {
  'AM' => '2x1',
  'AC' => [ 3, 4.5 ]
}

# Example 1. Items purchased: AM, AC, AM, AM, CA. Expected price: 22.45
example_1_items = %w(AM AC AM AM CA)
p "Example 1. Items purchased: #{example_1_items.join(', ')}. Expected price: 22.45"
co = Checkout.new(discounts)
example_1_items.each do |product_code|
  co.scan product_code
end
p "Example 1 total price: #{co.total}"
p '=================================================='

# Example 2. Items purchased: AM, AM. Expected price: 3.11
example_2_items = %w(AM AM)
p "Example 2. Items purchased: #{example_2_items.join(', ')}. Expected price: 3.11"
co = Checkout.new(discounts)
example_2_items.each do |product_code|
  co.scan product_code
end
p "Example 2 total price: #{co.total}"
p '=================================================='

# Example 3. Items purchased: AC, AC, AM, AC. Expected price: 16.61
example_3_items = %w(AC AC AM AC)
p "Example 3. Items purchased: #{example_3_items.join(', ')}. Expected price: 16.61"
co = Checkout.new(discounts)
example_3_items.each do |product_code|
  co.scan product_code
end
p "Example 3 total price: #{co.total}"
p '=================================================='