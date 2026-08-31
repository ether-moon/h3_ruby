# Hoian H3 4.5 migration

This audit covers `karrot-emu/hoian-webapp` at commit `c1c350ccc7456eec300092c9e6b3aae69e29f7cf`. Hoian itself was not modified.

## Current dependency and calls

The pinned Hoian revision uses Ruby 4.0.6 and locks `h3` 3.7.4 from `gem "h3", "~> 3.7"`. A repository-wide source and test audit found these direct public calls:

- Index conversion: `from_geo_coordinates`, `to_geo_coordinates`, `to_string`, `resolution`, and `valid?`.
- Hierarchy: `parent`, `center_child`, `children`, and `compact`.
- Traversal and distance: `k_ring`, `k_ring_distances`, and `distance`.
- Regions and boundaries: `polyfill`, `coordinates_to_geo_json`, and `to_boundary`.
- Measurement: `edge_length_m`.

All of these Ruby method names and their existing argument shapes remain available in h3 4.5.0. `uncompact` is also retained for compatibility even though the pinned Hoian revision does not call it directly.

## Behavior to account for

- Invalid native operations raise `H3::Error`. It subclasses `ArgumentError`, exposes the numeric `code` and symbolic `name`, and does not substitute a fallback value.
- `children(cell, lower_resolution)` still returns `[]`, and `max_children` still returns `0`, preserving h3_ruby 3.7 behavior even though H3 v4 reports a resolution mismatch at the C boundary.
- Average area and edge-length values come from H3 4.5 and may differ from H3 3.7.
- The gem loads only its own absolute native-library path. A host `libh3.so` or `libh3.dylib` is neither required nor used.

## Follow-up migration

1. Publish or otherwise pin an approved h3_ruby 4.5.0 artifact. This worktree does not publish a gem or create a release.
2. Replace Hoian's `~> 3.7` constraint with `~> 4.5` only after that artifact exists, then refresh the lockfile on Ruby 4.0.6.
3. Run the Hoian tests around location indexing, hierarchy expansion, search/feed coverage, polygon fills, and distance calculations on Linux GNU.
4. At external-input boundaries, rescue `H3::Error` only where Hoian has a defined invalid-location response. Do not convert unexpected H3 failures into empty or default results.
5. Review thresholds or snapshots that depend on average area or edge-length values before deployment.
