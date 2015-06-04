require_relative '../credit_card'
require 'minitest/autorun'

describe 'Test hashing requirements' do
  before do
    @cc1 = CreditCard.new('4916603231464963', 'Mar-30-2020', 'Soumya Ray', 'Visa')
    @cc2 = CreditCard.new('4916603231464963', 'Mar-30-2020', 'Soumya Ray', 'Visa')
    @cc3 = CreditCard.new('5423661657234057', 'Feb-30-2020', 'Soumya Ray', 'Mastercard')
  end

  describe 'Test regular hashing' do
    it 'should find the same hash for identical cards' do
      # TODO: implement this test
      hash1 = @cc1.hash
      hash2 = @cc2.hash
      hash1.must_equal hash2
    end
    it 'should produce different hashes for different information' do
      # TODO: implement this test
      hash1 = @cc1.hash
      hash2 = @cc3.hash
      hash1.wont_equal hash2
    end
  end

  describe 'Test cryptographic hashing' do
    it 'should find the same hash for identical cards' do
      # TODO: implement this test
      hash1 = @cc1.hash_secure
      hash2 = @cc2.hash_secure
      hash1.must_equal hash2
    end
    it 'should produce different hashes for different information' do
      # TODO: implement this test
      hash1 = @cc1.hash_secure
      hash2 = @cc3.hash_secure
      hash1.wont_equal hash2
    end
    it 'should not produce the same regular vs. cryptographic hash' do
      # TODO: implement this test
      hash1 = @cc1.hash
      hash2 = @cc1.hash_secure
      hash1.wont_equal hash2
    end
  end
end
