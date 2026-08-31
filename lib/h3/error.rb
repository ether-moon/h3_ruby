module H3
  class Error < ArgumentError
    NAMES = {
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
    }.freeze

    attr_reader :code, :name

    def initialize(code, description)
      @code = code
      @name = NAMES.fetch(code, "E_UNKNOWN")
      super("#{name} (#{code}): #{description}")
    end
  end
end
