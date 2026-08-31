module H3
  module Bindings
    # Private H3 functions which should not be called directly.
    module Private
      extend H3::Bindings::Base

      class << self
        def call_with_out(out_type, method, *args)
          out = FFI::MemoryPointer.new(out_type)
          check_error(public_send(method, *args, out))
          out.public_send("read_#{out_type}")
        end

        def check_error(code)
          return if code.zero?

          raise H3::Error.new(code, describe_h3_error(code))
        end
      end

      attach_function :describe_h3_error, :describeH3Error, [:h3_error], :string

      # Indexing
      attach_function :lat_lng_to_cell, :latLngToCell,
                      [GeoCoord, Resolution, :pointer], :h3_error
      attach_function :cell_to_lat_lng, :cellToLatLng,
                      [:h3_index, GeoCoord], :h3_error
      attach_function :cell_to_boundary, :cellToBoundary,
                      [:h3_index, GeoBoundary], :h3_error
      attach_function :string_to_h3, :stringToH3, %i[string pointer], :h3_error
      attach_function :h3_to_string, :h3ToString,
                      %i[h3_index buffer_out size_t], :h3_error

      # Inspection
      attach_function :get_resolution, :getResolution, [:h3_index], :int
      attach_function :get_base_cell_number, :getBaseCellNumber, [:h3_index], :int
      attach_function :is_valid_cell, :isValidCell, [:h3_index], :int
      attach_function :is_res_class_iii, :isResClassIII, [:h3_index], :int
      attach_function :is_pentagon, :isPentagon, [:h3_index], :int
      attach_function :max_face_count, :maxFaceCount,
                      %i[h3_index pointer], :h3_error
      attach_function :get_icosahedron_faces, :getIcosahedronFaces,
                      %i[h3_index pointer], :h3_error

      # Hierarchy
      attach_function :cell_to_parent, :cellToParent,
                      [:h3_index, Resolution, :pointer], :h3_error
      attach_function :cell_to_children_size, :cellToChildrenSize,
                      [:h3_index, Resolution, :pointer], :h3_error
      attach_function :cell_to_children, :cellToChildren,
                      [:h3_index, Resolution, H3IndexesOut], :h3_error
      attach_function :cell_to_center_child, :cellToCenterChild,
                      [:h3_index, Resolution, :pointer], :h3_error
      attach_function :compact_cells, :compactCells,
                      [H3IndexesIn, H3IndexesOut, :int64], :h3_error
      attach_function :uncompact_cells_size, :uncompactCellsSize,
                      [H3IndexesIn, :int64, Resolution, :pointer], :h3_error
      attach_function :uncompact_cells, :uncompactCells,
                      [H3IndexesIn, :int64, H3IndexesOut, :int64, Resolution], :h3_error

      # Traversal
      attach_function :max_grid_disk_size, :maxGridDiskSize,
                      %i[k_distance pointer], :h3_error
      attach_function :grid_disk_unsafe, :gridDiskUnsafe,
                      [:h3_index, :k_distance, H3IndexesOut], :h3_error
      attach_function :grid_disk_distances_unsafe, :gridDiskDistancesUnsafe,
                      [:h3_index, :k_distance, H3IndexesOut, :pointer], :h3_error
      attach_function :grid_disks_unsafe, :gridDisksUnsafe,
                      [H3IndexesIn, :int, :k_distance, H3IndexesOut], :h3_error
      attach_function :grid_disk, :gridDisk,
                      [:h3_index, :k_distance, H3IndexesOut], :h3_error
      attach_function :grid_disk_distances, :gridDiskDistances,
                      [:h3_index, :k_distance, H3IndexesOut, :pointer], :h3_error
      attach_function :grid_ring_unsafe, :gridRingUnsafe,
                      [:h3_index, :k_distance, H3IndexesOut], :h3_error
      attach_function :grid_distance, :gridDistance,
                      %i[h3_index h3_index pointer], :h3_error
      attach_function :grid_path_cells_size, :gridPathCellsSize,
                      %i[h3_index h3_index pointer], :h3_error
      attach_function :grid_path_cells, :gridPathCells,
                      [:h3_index, :h3_index, H3IndexesOut], :h3_error

      # Regions
      attach_function :max_polygon_to_cells_size, :maxPolygonToCellsSize,
                      [GeoPolygon, Resolution, :uint32, :pointer], :h3_error
      attach_function :polygon_to_cells, :polygonToCells,
                      [GeoPolygon, Resolution, :uint32, H3IndexesOut], :h3_error
      attach_function :cells_to_linked_multi_polygon, :cellsToLinkedMultiPolygon,
                      [H3IndexesIn, :int, LinkedGeoPolygon], :h3_error
      attach_function :destroy_linked_multi_polygon, :destroyLinkedMultiPolygon,
                      [LinkedGeoPolygon], :void

      # Directed edges
      attach_function :are_neighbor_cells, :areNeighborCells,
                      %i[h3_index h3_index pointer], :h3_error
      attach_function :cells_to_directed_edge, :cellsToDirectedEdge,
                      %i[h3_index h3_index pointer], :h3_error
      attach_function :is_valid_directed_edge, :isValidDirectedEdge,
                      [:h3_index], :int
      attach_function :get_directed_edge_origin, :getDirectedEdgeOrigin,
                      %i[h3_index pointer], :h3_error
      attach_function :get_directed_edge_destination, :getDirectedEdgeDestination,
                      %i[h3_index pointer], :h3_error
      attach_function :directed_edge_to_cells, :directedEdgeToCells,
                      [:h3_index, H3IndexesOut], :h3_error
      attach_function :origin_to_directed_edges, :originToDirectedEdges,
                      [:h3_index, H3IndexesOut], :h3_error
      attach_function :directed_edge_to_boundary, :directedEdgeToBoundary,
                      [:h3_index, GeoBoundary], :h3_error

      # Measurement
      attach_function :degs_to_rads, :degsToRads, [:double], :double
      attach_function :rads_to_degs, :radsToDegs, [:double], :double
      attach_function :great_circle_distance_rads, :greatCircleDistanceRads,
                      [GeoCoord, GeoCoord], :double
      attach_function :great_circle_distance_km, :greatCircleDistanceKm,
                      [GeoCoord, GeoCoord], :double
      attach_function :great_circle_distance_m, :greatCircleDistanceM,
                      [GeoCoord, GeoCoord], :double
      attach_function :get_hexagon_area_avg_km2, :getHexagonAreaAvgKm2,
                      [Resolution, :pointer], :h3_error
      attach_function :get_hexagon_area_avg_m2, :getHexagonAreaAvgM2,
                      [Resolution, :pointer], :h3_error
      attach_function :cell_area_rads2, :cellAreaRads2,
                      %i[h3_index pointer], :h3_error
      attach_function :cell_area_km2, :cellAreaKm2,
                      %i[h3_index pointer], :h3_error
      attach_function :cell_area_m2, :cellAreaM2,
                      %i[h3_index pointer], :h3_error
      attach_function :get_hexagon_edge_length_avg_km, :getHexagonEdgeLengthAvgKm,
                      [Resolution, :pointer], :h3_error
      attach_function :get_hexagon_edge_length_avg_m, :getHexagonEdgeLengthAvgM,
                      [Resolution, :pointer], :h3_error
      attach_function :edge_length_rads, :edgeLengthRads,
                      %i[h3_index pointer], :h3_error
      attach_function :edge_length_km, :edgeLengthKm,
                      %i[h3_index pointer], :h3_error
      attach_function :edge_length_m, :edgeLengthM,
                      %i[h3_index pointer], :h3_error
      attach_function :get_num_cells, :getNumCells,
                      [Resolution, :pointer], :h3_error
      attach_function :res_0_cell_count, :res0CellCount, [], :int
      attach_function :get_res_0_cells, :getRes0Cells,
                      [H3IndexesOut], :h3_error
      attach_function :pentagon_count, :pentagonCount, [], :int
      attach_function :get_pentagons, :getPentagons,
                      [Resolution, H3IndexesOut], :h3_error
    end
  end
end
