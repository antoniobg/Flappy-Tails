require_relative '../vector'

RSpec.describe GameVector do
  it "can set itself" do
    v1 = GameVector.new(1, 2)
    v2 = GameVector.new(3, 4)
    v1.set!(v2)
    expect(v1).to eq(v2)
    expect(v1).not_to be(v2)
  end

  it "does vector addition" do
    expect(GameVector.new(1,2) + GameVector.new(3, 4)).to eq(GameVector.new(4, 6))
  end

  it "does vector substraction" do
    expect(GameVector.new(1,2) - GameVector.new(1, 2)).to eq(GameVector.new(0, 0))
  end

  it "does scalar multiplication" do
    expect(5 * GameVector.new(1,2)).to eq(GameVector.new(5, 10))
  end

  it "does vector negation" do
    expect(-GameVector.new(1,2)).to eq(GameVector.new(-1, -2))
  end
end