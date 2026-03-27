# Local pod overrides for development.
#
# This file is auto-managed by scripts/local-pod.
# Do not edit manually — use the script instead:
#
#   scripts/local-pod enable    # switch CoreSDK + OpenTelemetry to local sources
#   scripts/local-pod disable   # switch back to remote
#   scripts/local-pod status    # show current state
#
# Required folder structure (all repos cloned as siblings):
#   ios/
#   ├── ios-sdk/           # GliaCoreSDK sources
#   ├── ios-sdk-widgets/   # this repo
#   └── ios-telemetry/     # GliaOpenTelemetry sources

# def local_core_sdk
#   pod 'GliaCoreSDK', path: '../ios-sdk/GliaCoreSDK.sources.podspec'
# end

# def local_telemetry_sdk
#   pod 'GliaOpenTelemetry', path: '../ios-telemetry/GliaOpenTelemetry.sources.podspec'
# end
