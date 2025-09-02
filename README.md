# Moderne CLI Wrapper Script

## Prerequisites

You need to use a Moderne CLI version >= 3.45.0. Earlier versions did not produce telemetry metrics. Copy the [`mod.sh`](./mod.sh) into a desired directory. Add this directory to the `PATH` environment variable so that you can execute it from any path.

## Example usage

The entrypoint for executing the Moderne CLI is the `mod.sh` script. It allows to provide any command you'd usually use when run directly from the `mod` executable.

The following example shows the command for building the LST:

```
MOD_JAR="/Users/bmuschko/.moderne/bin/moderne-cli-3.45.5.jar" \
BI_ENDPOINT="http://localhost:8080" \
mod.sh build .
```

In the directory `~/.moderne/cli/trace`, you will find a `build` subdirectory. In that subdirectory, you will see a trace file, e.g. `trace-20250828083744-UZyvw.csv`.

The following example shows the command for running a recipe:

```
MOD_JAR="/Users/bmuschko/.moderne/bin/moderne-cli-3.45.5.jar" \
BI_ENDPOINT="http://localhost:8080" \
mod.sh run . --recipe DependencyVulnerabilityCheck
```

In the directory `~/.moderne/cli/trace`, you will find a `run` subdirectory. In that subdirectory, you will see a trace file, e.g. `trace-20250828085011-lTsq2.csv`.

## Configuration Options

### Environment Variables

The `mod.sh` script supports several environment variables for configuration:

| Variable | Description | Example |
|----------|-------------|---------|
| `MOD_JAR` | Path to the Moderne CLI JAR file | `/path/to/moderne-cli-3.45.5.jar` |
| `BI_ENDPOINT` | BI system endpoint URL for telemetry data | `http://localhost:8080` |
| `BI_AUTH_USER` | Username for basic authentication (optional) | `apiuser` |
| `BI_AUTH_PASS` | Password for basic authentication (optional) | `apipass` |
| `HTTP_PROXY` | HTTP proxy URL (optional) | `http://proxy.example.com:8080` |
| `HTTPS_PROXY` | HTTPS proxy URL (optional) | `https://proxy.example.com:443` |
| `PROXY_USER` | Proxy username (optional) | `proxyuser` |
| `PROXY_PASS` | Proxy password (optional) | `proxypass` |

### Authentication

If your BI endpoint requires basic authentication, you can provide credentials using the `BI_AUTH_USER` and `BI_AUTH_PASS` environment variables:

```bash
MOD_JAR="/path/to/moderne-cli.jar" \
BI_ENDPOINT="https://bi.example.com/ingest" \
BI_AUTH_USER="apiuser" \
BI_AUTH_PASS="secretpass" \
mod.sh build .
```

### Proxy Configuration

If you need to send telemetry data through a proxy server, you can configure it using standard proxy environment variables:

#### Simple proxy without authentication:
```bash
MOD_JAR="/path/to/moderne-cli.jar" \
BI_ENDPOINT="https://bi.example.com/ingest" \
HTTPS_PROXY="http://proxy.example.com:8080" \
mod.sh build .
```

#### Proxy with authentication:
```bash
MOD_JAR="/path/to/moderne-cli.jar" \
BI_ENDPOINT="https://bi.example.com/ingest" \
HTTPS_PROXY="http://proxy.example.com:8080" \
PROXY_USER="proxyuser" \
PROXY_PASS="proxypass" \
mod.sh build .
```

#### Different proxies for HTTP and HTTPS:
```bash
MOD_JAR="/path/to/moderne-cli.jar" \
BI_ENDPOINT="http://bi.example.com/ingest" \
HTTP_PROXY="http://proxy.example.com:8080" \
HTTPS_PROXY="https://secure-proxy.example.com:443" \
mod.sh build .
```

The script automatically selects the appropriate proxy based on the BI endpoint URL scheme:
- HTTPS endpoints will use `HTTPS_PROXY` if set
- HTTP endpoints will use `HTTP_PROXY` if set

### Complete Example with All Options

```bash
MOD_JAR="/path/to/moderne-cli.jar" \
BI_ENDPOINT="https://bi.example.com/ingest" \
BI_AUTH_USER="apiuser" \
BI_AUTH_PASS="secretpass" \
HTTPS_PROXY="http://proxy.example.com:8080" \
PROXY_USER="proxyuser" \
PROXY_PASS="proxypass" \
mod.sh run . --recipe DependencyVulnerabilityCheck
```

## ELK Stack Integration

For setting up and using the ELK stack (Elasticsearch, Logstash, Kibana) to visualize telemetry data, see [elk/README.md](./elk/README.md).