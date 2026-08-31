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
    expect(H3::Error::NAMES).to eq(
      1 => "E_FAILED",
      2 => "E_DOMAIN",
      3 => "E_LATLNG_DOMAIN",
      4 => "E_RES_DOMAIN",
      5 => "E_CELL_INVALID",
      6 => "E_DIR_EDGE_INVALID",
      7 => "E_UNDIR_EDGE_INVALID",
      8 => "E_VERTEX_INVALID",
      9 => "E_PENTAGON",
      10 => "E_DUPLICATE_INPUT",
      11 => "E_NOT_NEIGHBORS",
      12 => "E_RES_MISMATCH",
      13 => "E_MEMORY_ALLOC",
      14 => "E_MEMORY_BOUNDS",
      15 => "E_OPTION_INVALID",
      16 => "E_INDEX_INVALID",
      17 => "E_BASE_CELL_DOMAIN",
      18 => "E_DIGIT_DOMAIN",
      19 => "E_DELETED_DIGIT"
    )
  end
end
