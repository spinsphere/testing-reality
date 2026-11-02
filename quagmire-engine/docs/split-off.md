# Splitting Quagmire Engine into its own repository

The engine lives in `quagmire-engine/` and has no dependency on the rest of this repository.
To move it out:

1. `git subtree split --prefix=quagmire-engine -b quagmire-engine-history` (keeps the commit
   history of the folder), then push that branch to the new repository.
2. In the new repository the workspace root is the old `quagmire-engine/` folder:
   `Cargo.toml` (workspace), `.cargo/config.toml` (wasm flags), `core/`, `sdk-godot/`
   (including its `build.sh`, the per-target build), `docs/`, `README.md`,
   `rust-toolchain.toml`. Nothing in the folder refers to the app.
3. In this repository, replace the folder with a dependency:
   - `app/addons/quagmire/` keeps the `.gdextension` file; the binaries (`.so`, `.dll`,
     `.wasm`) come from the engine's releases, or from a git submodule + `tools/build-sdk.sh`,
     which only calls `<engine>/sdk-godot/build.sh <target>` and copies what it prints —
     change the engine path there.
4. The Godot SDK's `quagmire.gdextension` and the GDScript API (`QuagmireSystem`,
   `QuagmireScreen`, `QuagmireProfile`) are documented in `sdk-godot/src/lib.rs` doc comments;
   the C ABI crate (`capi/`) for Unity/Unreal is the next planned addition and should follow
   the opaque-handle, caller-allocated-buffer conventions in `docs/design/architecture.md` of
   the app repository (copy that section here when splitting).

Golden tests (`core/tests/golden.rs`) encode the Testing Reality site's numbers and should be
kept as the engine's conformance suite; they do not depend on the app.
