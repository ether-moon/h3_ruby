RSpec.describe "H3 v4.5.0 conformance" do
  let(:cell) { "8928308280fffff".to_i(16) }
  let(:parent) { "8828308281fffff".to_i(16) }

  it "reports both the gem and bundled H3 C versions" do
    versions = {
      gem: H3::VERSION,
      h3: H3.const_defined?(:C_VERSION, false) ? H3::C_VERSION : nil
    }

    expect(versions).to eq(gem: "4.5.0", h3: "4.5.0")
  end

  it "matches the official cell inspection and hierarchy results" do
    expect(H3.valid?(cell)).to be(true)
    expect(H3.resolution(cell)).to eq(9)
    expect(H3.parent(cell, 8)).to eq(parent)
  end

  it "round-trips official children through compact and uncompact" do
    children = %w[
      89283082803ffff 89283082807ffff 8928308280bffff 8928308280fffff
      89283082813ffff 89283082817ffff 8928308281bffff
    ].map { |index| index.to_i(16) }

    expect(H3.children(parent, 9)).to eq(children)
    expect(H3.compact(children)).to eq([parent])
    expect(H3.uncompact([parent], 9)).to eq(children)
  end

  it "identifies an official pentagon cell" do
    expect(H3.pentagon?("821c07fffffffff".to_i(16))).to be(true)
  end

  it "maps every H3 v4.5 error code" do
    expect(H3::Error::NAMES.keys).to eq((1..19).to_a)
    expect(H3::Error::NAMES.values.last(5)).to eq(
      %w[E_OPTION_INVALID E_INDEX_INVALID E_BASE_CELL_DOMAIN E_DIGIT_DOMAIN E_DELETED_DIGIT]
    )
  end
end
