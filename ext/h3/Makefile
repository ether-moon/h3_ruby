BUILD_DIR := build

all:
	cmake -S src -B $(BUILD_DIR) -DBUILD_SHARED_LIBS=ON -DBUILD_TESTING=OFF -DBUILD_FILTERS=OFF -DBUILD_BENCHMARKS=OFF -DBUILD_FUZZERS=OFF -DBUILD_GENERATORS=OFF -DENABLE_LINTING=OFF
	cmake --build $(BUILD_DIR) --target h3

install:
	test -n "$(sitearchdir)"
	cmake -E make_directory "$(sitearchdir)"
	cmake -E copy_directory $(BUILD_DIR)/lib "$(sitearchdir)"

clean:
	cmake -E remove_directory $(BUILD_DIR)
