require 'spec_helper'


describe Money do 

  it "should be able to add" do 
    a = Money.new(10.01)
    b = Money.new(10.01)
    (a + b).amount.should eq(BigDecimal.new(20.02,15))
  end

  it "should be able to subtract" do
    a = Money.new(20.10)
    b = Money.new(10.01)
    (a - b).amount.should eq(BigDecimal.new(10.09,15))    
  end
  it "should be able to multiply" do
    a = Money.new(10.01)
    b = Money.new(10.01)
    (a * b).amount.should eq(BigDecimal.new(100.2,15))    
  end
  it "should be able to compare for equality" do
    a = Money.new(10.01)
    b = Money.new(10.01)
    expect(a.amount).to eq(b.amount)
  end

  it "should be able to compare for >= " do
    a = Money.new(10.01)
    b = Money.new(5.01)
    (a >= b ).should eq(true)
    (b >= a ).should eq(false)
  end

  it "should be able to compare for <= " do
    a = Money.new(5.01)
    b = Money.new(10.01)
    (a <= b ).should eq(true)
    (b <= a ).should eq(false)
  end


  it "should be able to compare for <= " do
    a = Money.new(10.01)
    b = Money.new(10.01)
    (a <= b ).should eq(true)
    (b <= a ).should eq(true)
    (a >= b ).should eq(true)
    (b >= a ).should eq(true)
  end

  it "should be able to divide" do 
    a = Money.new(10.02)
    (a / 2 ).amount.should eq(BigDecimal.new(5.01,15))
  end

  it "should be able to divide and round the answer appropriately" do 
    a = Money.new(10.00)
    (a / 3 ).amount.should eq(BigDecimal.new(3.33,15))
  end
end 
