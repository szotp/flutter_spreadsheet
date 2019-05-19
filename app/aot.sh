source ./macos_fde/Config/Release.xcconfig
/Users/pszot/Documents/flutter/bin/flutter clean
/Users/pszot/Documents/flutter/bin/flutter build bundle --local-engine=$FLUTTER_ENGINE_OUT_DIR --debug

$FLUTTER_ENGINE_OUT_DIR/dart                              \
$FLUTTER_ENGINE_OUT_DIR/frontend_server.dart.snapshot     \
--sdk-root $FLUTTER_ENGINE_OUT_DIR/flutter_patched_sdk/   \
--strong                                                  \
--target=flutter                                          \
--aot                                                     \
--embed-source-text \
--tfa                                                     \
-Ddart.vm.product=true                                    \
--packages .packages                                      \
--output-dill build/kernel_snapshot.dill                  \
main.dart

$FLUTTER_ENGINE_OUT_DIR/gen_snapshot                          \
--causal_async_stacks                                         \
--deterministic                                               \
--snapshot_kind=app-aot-blobs                                 \
--vm_snapshot_data=build/vm_snapshot_data                     \
--isolate_snapshot_data=build/isolate_snapshot_data           \
--vm_snapshot_instructions=build/vm_snapshot_instr            \
--isolate_snapshot_instructions=build/isolate_snapshot_instr  \
build/kernel_snapshot.dill
