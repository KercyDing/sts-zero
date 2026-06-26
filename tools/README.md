# Tools

This directory contains local development tools used by the project.

## impellerc-linux-x64

`impellerc-linux-x64` is Flutter Impeller's offline shader compiler. This
checked-in binary is only for Linux x64 hosts.

In this project it turns GLSL fragment shaders into Impeller runtime stage
`.iplr` files.

Build a shader by name:

```sh
only s map
# or:
# ./tools/impellerc-linux-x64 --runtime-stage-metal --runtime-stage-vulkan --input=src/assets/shaders/map.frag --input-type=frag --sl=src/assets/shaders/map.iplr --spirv=/tmp/sts-zero-map.spv --iplr --verbose
```

### Notes

- `.iplr` includes Metal and Vulkan runtime stages.
- Do not pass `--reflection-json` when compiling multiple runtime stages.
- `impellerc` only supports reflection output for a single target.
