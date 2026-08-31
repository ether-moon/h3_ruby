RSpec.describe H3 do
  include_context "constants"

  describe ".polyfill" do
    let(:geojson) do
      File.read(File.join(File.dirname(__FILE__), "support/fixtures/banbury_without_holes.json"))
    end
    let(:resolution) { 9 }
    let(:expected_count) { 14_369 }

    subject(:polyfill) { H3.polyfill(geojson, resolution) }

    it "has the correct number of hexagons" do
      expect(polyfill.count).to eq expected_count
    end

    context "when banbury area has two holes in it" do
      let(:geojson) do
        File.read(File.join(File.dirname(__FILE__), "support/fixtures/banbury.json"))
      end
      let(:expected_count) { 13_526 }

      it "has fewer hexagons" do
        expect(polyfill.count).to eq expected_count
      end
    end

    context "when polyfilling australia" do
      let(:geojson) do
        File.read(File.join(File.dirname(__FILE__), "support/fixtures/australia.json"))
      end
      let(:expect_count) { 92 }

      it "has the correct number of hexagons" do
        expect(polyfill.count).to eq expect_count
      end
    end

    it "keeps polygon backing memory alive through native calls" do
      with_holes = File.read(File.join(File.dirname(__FILE__), "support/fixtures/banbury.json"))
      polygon = H3.send(:build_polygon, H3.geo_json_to_coordinates(with_holes))

      expect(polygon.instance_variable_get(:@retained)).to contain_exactly(
        an_instance_of(FFI::MemoryPointer),
        an_instance_of(FFI::MemoryPointer),
        an_instance_of(FFI::MemoryPointer),
        an_instance_of(FFI::MemoryPointer)
      )

      GC.start(full_mark: true, immediate_sweep: true)
      GC.compact if GC.respond_to?(:compact)

      expect(
        H3::Bindings::Private.call_with_out(
          :int64, :max_polygon_to_cells_size, polygon, 9, 0
        )
      ).to eq(47_018)
    end
  end

  describe ".max_polyfill_size" do
    let(:geojson) do
      File.read(File.join(File.dirname(__FILE__), "support/fixtures/banbury.json"))
    end
    let(:resolution) { 9 }
    let(:expected_count) { 47_018 }

    subject(:max_polyfill_size) { H3.max_polyfill_size(geojson, resolution) }

    it "has the correct number of hexagons" do
      expect(max_polyfill_size).to eq expected_count
    end
  end

  describe ".h3_set_to_linked_geo" do
    let(:geojson) do
      File.read(File.join(File.dirname(__FILE__), "support/fixtures/banbury.json"))
    end
    let(:resolution) { 8 }
    let(:hexagons) { H3.polyfill(geojson, resolution) }

    subject(:h3_set_to_linked_geo) { H3.h3_set_to_linked_geo(hexagons) }
    
    it "has 3 outlines" do
      expect(h3_set_to_linked_geo.count).to eq(3)
    end

    it "can be converted to GeoJSON" do
      expect(H3.coordinates_to_geo_json(h3_set_to_linked_geo)).to be_truthy
    end

    it "returns nil for an empty set" do
      expect(H3.h3_set_to_linked_geo([])).to be_nil
    end

    it "rejects disconnected polygons without dropping data" do
      disconnected = %w[8928308291bffff 89283082943ffff].map { |cell| cell.to_i(16) }

      expect { H3.h3_set_to_linked_geo(disconnected) }
        .to raise_error(H3::MultiPolygonError, /2 disjoint regions/) { |error|
          expect(error).to be_a(ArgumentError)
        }
    end

    it "preserves native errors" do
      expect { H3.h3_set_to_linked_geo(["fffffffffffffff".to_i(16)]) }
        .to raise_error(H3::Error) { |error| expect(error.name).to eq("E_CELL_INVALID") }
    end
  end
end
