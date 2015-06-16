require 'spec_helper'
 
describe Checkout do
  before :each do
    discounts = {
      'AM' => '2x1',
      'AC' => [ 3, 4.5 ]
    }

    @checkout = Checkout.new(discounts)
  end

  describe "#new" do
    it "takes one parameter and returns a Checkout object" do
      expect(@checkout).to be_a Checkout
    end
  end

  describe "#scan" do
    it "takes a product code and returns a number" do
      expect(@checkout.scan 'AM').to be_a Numeric
    end

    it "takes the water product code and returns its regular price: 3.11" do
      expect(@checkout.scan 'AM').to equal 3.11
    end

    it "takes the oil product code and returns its regular price: 5" do
      expect(@checkout.scan 'AC').to equal 5
    end

    it "takes the coffee product code and returns its regular price: 11.23" do
      expect(@checkout.scan 'CA').to equal 11.23
    end

    it "takes an unknown product code and returns an exception" do
      expect{@checkout.scan 'UNKNOWN'}.to raise_error 'Product not recognized'
    end
  end

  describe "#discounts" do
    context "we don't change anything" do
      it "returns a hash" do
        expect(@checkout.discounts).to be_a Hash
      end

      it "returns an array" do
        original_discounts = {
          'AM' => '2x1',
          'AC' => [ 3, 4.5 ]
        }

        expect(@checkout.discounts).to eq original_discounts
      end
    end

    context "we add new valid discounts" do
      before :each do
        @checkout.discounts = {
          'CA' => '2x1'
        }
      end

      it "returns a hash" do
        expect(@checkout.discounts).to be_a Hash
      end

      it "returns an array" do
        new_valid_discounts = {
          'CA' => '2x1'
        }

        expect(@checkout.discounts).to eq new_valid_discounts
      end
    end

    context "we add an invalid discount and try to scan its item" do
      before :each do
        @checkout.discounts = {
          'CA' => '5x1'
        }
      end

      it "returns a \"Discount unknown\" exception" do
        expect{@checkout.scan 'CA'}.to raise_error 'Discount unknown'
      end
    end
  end

  describe "#total" do
    context "we don't scan anything" do
      it "returns a number" do
        expect(@checkout.total).to be_a Numeric
      end

      it "returns 0" do
        expect(@checkout.total).to equal 0
      end
    end

    it "returns a number after scanning a product" do
      @checkout.scan 'AM'

      expect(@checkout.total).to be_a Numeric
    end

    it "returns 22.45 after scanning AM, AC, AM, AM and CA (2x1 discount plus other items)" do
      @checkout.scan 'AM'
      @checkout.scan 'AC'
      @checkout.scan 'AM'
      @checkout.scan 'AM'
      @checkout.scan 'CA'

      expect(@checkout.total).to equal 22.45
    end

    it "returns 3.11 after scanning AM and AM (2x1 discount)" do
      @checkout.scan 'AM'
      @checkout.scan 'AM'

      expect(@checkout.total).to equal 3.11
    end

    it "returns 16.61 after scanning AC, AC, AM and AC (2x1 discount with more than 2 items)" do
      @checkout.scan 'AC'
      @checkout.scan 'AC'
      @checkout.scan 'AM'
      @checkout.scan 'AC'

      expect(@checkout.total).to equal 16.61
    end

    context "we change the pricing rules (discounts), applying the 3x2 discount instead of 2x1 to the water" do
      before :each do
        @checkout.discounts = {
          'AM' => '3x2'
        }
      end

      it "returns 6.22 after scanning AM, AM and AM (3x2 discount)" do
        @checkout.scan 'AM'
        @checkout.scan 'AM'
        @checkout.scan 'AM'

        expect(@checkout.total).to equal 6.22
      end

      it "returns 9.33 after scanning AM, AM, AM and AM (3x2 discount plus 1 extra item, which has to be paid)" do
        @checkout.scan 'AM'
        @checkout.scan 'AM'
        @checkout.scan 'AM'
        @checkout.scan 'AM'

        expect(@checkout.total).to equal 9.33
      end
    end

    context "we change the pricing rules (discounts), setting the price of the oil to 3 for purchases of 5 items or more" do
      before :each do
        @checkout.discounts = {
          'AC' => [ 5, 3 ]
        }
      end

      it "returns 21 after scanning AC, AC, AC, AC, AC, AC and AC" do
        @checkout.scan 'AC'
        @checkout.scan 'AC'
        @checkout.scan 'AC'
        @checkout.scan 'AC'
        @checkout.scan 'AC'
        @checkout.scan 'AC'
        @checkout.scan 'AC'

        expect(@checkout.total).to equal 21
      end
    end
  end

  describe '#products' do
    context "we don't have any products in our shopping list" do
      it "returns an empty hash" do
        expect(@checkout.products).to eq Hash.new
      end
    end

    context "we scan the three available products" do
      before :each do
        @checkout.scan 'AM'
        @checkout.scan 'AC'
        @checkout.scan 'CA'
      end

      it "returns a hash with these three product codes as keys" do
        expect(@checkout.products.keys.sort).to eq %w(AM AC CA).sort
      end

      it "returns a hash with \"AC\" as a key and an array as value (containing the original price of the oil)" do
        expect(@checkout.products['AM']).to eq [ 3.11 ]
      end

      it "returns a hash with \"AC\" as a key and an array as value (containing the original price of the oil)" do
        expect(@checkout.products['AC']).to eq [ 5 ]
      end

      it "returns a hash with \"AC\" as a key and an array as value (containing the original price of the oil)" do
        expect(@checkout.products['CA']).to eq [ 11.23 ]
      end
    end
  end
end