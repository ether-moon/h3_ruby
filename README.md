# H3 Ruby

![h3](https://user-images.githubusercontent.com/98526/50283275-48177300-044d-11e9-8337-eba8d3cc88a2.png)

![Build Status](https://github.com/ether-moon/h3_ruby/actions/workflows/ruby_ci.yml/badge.svg)

Ruby-to-C bindings for Uber's [H3 library](https://uber.github.io/h3/).

Please consult [the H3 documentation](https://uber.github.io/h3/#/documentation/overview/introduction) for a full explanation of terminology and concepts.

## Supported H3 Versions

Version `4.5.0` of this gem embeds the official Uber H3 `v4.5.0` source at commit `1b536c34225191ba24a75a840f634d4a48c3b206`. The gem's major and minor versions identify its H3 C API compatibility; the patch version may advance independently for Ruby-only fixes.

H3 source updates must change the `ext/h3/src` submodule to an exact stable release commit and update `H3::C_VERSION`, tests, and this documentation in the same change. The build never searches for a system-installed `libh3`.

## Naming Conventions

We have changed camel-case method names to snake-case, as per the Ruby convention.

In addition, some methods using the `get` verb have been renamed i.e. `getH3UnidirectionalEdgesFromHexagon` becomes `unidirectional_edges_from_hexagon`.

We have also suffixed predicate methods with a question mark, as per the Ruby convention, and removed `h3Is` from the name i.e. `h3IsPentagon` becomes `pentagon?`

## Getting Started

This gem uses FFI to link directly into the H3 library (written in C). CI supports Ruby 3.4 and Ruby 4.0.6; Ruby 4.0.6 is the primary downstream target.

The official H3 source is packaged with the gem and built as a private shared library during gem installation. H3 is not installed system-wide, so it will not interfere with any other versions on the host.

Installation requires CMake 3.20 or newer, Make, and a C compiler. See the official [H3 source-install instructions](https://github.com/uber/h3/blob/v4.5.0/website/docs/installation.mdx#install-from-source) for platform-specific packages.

CI builds and tests `x86_64-linux-gnu`, `aarch64-linux-gnu`, and `arm64-darwin`. This release builds from source rather than distributing precompiled platform gems.

## Installing

Until version 4.5.0 is published, build and install it from this checkout:

    git submodule update --init --recursive
    gem build h3.gemspec
    gem install ./h3-4.5.0.gem

After a 4.5 release is published, applications can use:

```ruby
# Gemfile
gem "h3", "~> 4.5"
```

## Migrating from 3.7

Version 4.5 is a breaking major upgrade because the bundled C library moves from H3 3.7 to H3 4.5. The established Ruby names remain available, including `parent`, `center_child`, `children`, `valid?`, `compact`, `uncompact`, `from_geo_coordinates`, and `to_geo_coordinates`.

Native H3 failures now raise `H3::Error`, an `ArgumentError` subclass with `code` and `name` attributes. Code that rescues invalid-input failures can continue rescuing `ArgumentError`, while migrations can distinguish H3 error codes explicitly. Requests for children below the input cell's resolution retain the 3.7 Ruby behavior: `children` returns an empty array and `max_children` returns zero.

Average area and edge-length results use the official H3 4.5 constants and can differ from H3 3.7. Rebuild the native library after switching versions. See [Hoian's pinned-call audit and migration checklist](docs/hoian-v4-migration.md) for the downstream compatibility scope.

## Usage

Require the gem in your code

```ruby
require "h3"
```

Call H3 functions via the `H3` namespace

```ruby
H3.from_geo_coordinates([53.959130, -1.079230], 8).to_s(16)
=> "8819429a9dfffff"
H3.valid?("8819429a9dfffff".to_i(16))
=> true
H3.pentagon?("8819429a9dfffff".to_i(16))
=> false
H3.to_boundary("8819429a9dfffff".to_i(16))
=> [[53.962987505331384, -1.079984346847996], [53.9618315234061, -1.0870313428985856], [53.95744798515881, -1.0882421079017874], [53.95422067486053, -1.082406760751464], [53.955376670617454, -1.0753609232787642], [53.95975996282198, -1.074149274503605]]
```

## Documentation

Please read [the Gem Documentation](https://www.rubydoc.info/gems/h3) for a full reference of available methods.

## Development

Initialize the pinned submodule before the first build:

    git submodule update --init --recursive

The development environment requires the H3 library to be compiled from source before tests can be executed.

This is done automatically by the test suite. However, Rake tasks are provided to handle building H3 in a more fine-grained manner.

### Building H3

    bundle exec rake build

You can remove the compiled H3 library with `rake clean`, or rebuild it with `rake rebuild`.

### Running Tests

The test suite exercises the public Ruby API and the H3 4.5 conformance cases.

    bundle exec rake spec

## License

The Ruby bindings are distributed under the [MIT License](LICENSE.md). The bundled Uber H3 source retains its [Apache License 2.0](ext/h3/src/LICENSE) and [NOTICE](ext/h3/src/NOTICE); both are included in the built gem.

## Contributing

Pull requests and issues are welcome! Please read [the Contributing Guide](./CONTRIBUTING.md) for more info.
