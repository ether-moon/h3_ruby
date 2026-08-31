module H3
  module Bindings
    # Base for FFI Bindings.
    #
    # When extended, this module sets up FFI to use the H3 C library.
    module Base
      def self.extended(base)
        base.extend FFI::Library
        base.extend Gem::Deprecate
        base.include Structs
        base.include Types
        base.ffi_lib native_library
        base.typedef :uint64, :h3_index
        base.typedef :uint32, :h3_error
        base.typedef :int, :k_distance
      end

      def self.native_library
        gem_root = File.expand_path("../../..", __dir__)
        directories = [File.join(gem_root, "ext/h3/build/lib")]
        spec = Gem.loaded_specs["h3"]
        directories << spec.extension_dir if spec&.full_gem_path == gem_root

        library = directories.product(%w[libh3.dylib libh3.so]).find do |directory, name|
          File.file?(File.join(directory, name))
        end
        return File.join(*library) if library

        raise LoadError, "bundled H3 library is missing; rebuild or reinstall the h3 gem"
      end

      private_class_method :native_library
    end
  end
end
