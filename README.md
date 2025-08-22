# Moderne CLI Wrapper Script

## Prerequisites

You need to use a Moderne CLI version >= 3.45.0. Earlier versions did not produce telemetry metrics. Copy the `mod.sh` into a desired directory. Add this directory to the `PATH` environment variable so that you can execute it from any path.

## Example usage

The entrypoint for executing the Moderne CLI is the `mod.sh` script. It allows to provide any command you'd usually use when run directly from the `mod` executable. The following example shows the command for building the LST.

```
MOD_JAR="/Users/bmuschko/.moderne/bin/moderne-cli-3.45.2.jar" \
TELEMETRY_ENDPOINT="http://localhost:8080" \
mod.sh build .
```