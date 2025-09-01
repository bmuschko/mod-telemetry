# ELK Stack Setup for Moderne Telemetry

This guide explains how to set up and use the ELK stack (Elasticsearch, Logstash, Kibana) to collect and visualize Moderne CLI telemetry data.

## Prerequisites

- Docker and Docker Compose installed
- Moderne CLI version >= 3.45.0
- At least 4GB of available RAM for the ELK stack

## Quick Start

### 1. Start the ELK Stack

```bash
# Navigate to the elk directory
cd elk

# Start all ELK services
docker-compose up -d

# Check that all services are running
docker-compose ps
```

The following services will be available:
- **Elasticsearch**: http://localhost:9200
- **Logstash**: http://localhost:8080 (HTTP input for telemetry data)
- **Kibana**: http://localhost:5601

### 2. Automatic Setup

The ELK stack will automatically initialize when you start it:
- Index templates are created for build and run metrics
- Kibana dashboards and visualizations are imported
- All services are configured and ready to use

You can monitor the initialization progress:
```bash
docker-compose logs init
```

## Sending Telemetry Data

### For Build Metrics

1. Run a Moderne CLI build command:
```bash
MOD_JAR="/path/to/moderne-cli.jar" \
TELEMETRY_ENDPOINT="http://localhost:8080" \
./mod.sh build .
```

2. Send the generated trace file to Logstash:
```bash
# Navigate to the trace directory
cd ~/.moderne/cli/trace/build

# Send the trace file
curl -X POST http://localhost:8080 \
  -H "Content-Type: text/csv" \
  --data-binary @trace-YYYYMMDDHHMMSS-xxxxx.csv
```

### For Run Metrics

1. Run a Moderne CLI recipe:
```bash
MOD_JAR="/path/to/moderne-cli.jar" \
TELEMETRY_ENDPOINT="http://localhost:8080" \
./mod.sh run . --recipe DependencyVulnerabilityCheck
```

2. Send the generated trace file to Logstash:
```bash
# Navigate to the trace directory
cd ~/.moderne/cli/trace/run

# Send the trace file
curl -X POST http://localhost:8080 \
  -H "Content-Type: text/csv" \
  --data-binary @trace-YYYYMMDDHHMMSS-xxxxx.csv
```

## Viewing Metrics in Kibana

1. Open Kibana at http://localhost:5601
2. Navigate to **Dashboard** from the menu
3. Select the dashboard you want to view:
   - **Moderne Build Metrics** - for build command metrics
   - **Moderne Run Metrics** - for run command (recipe) metrics

## Advanced Configuration

### Using Different Logstash Pipelines

The setup includes two Logstash pipeline configurations:
- `build-metrics-pipeline.conf`: Processes build telemetry
- `run-metrics-pipeline.conf`: Processes recipe run telemetry

To switch between pipelines, update the docker-compose.yml to mount the desired configuration file.

### Customizing Index Settings

Edit `init/init-elk.sh` to modify:
- Number of shards and replicas
- Refresh intervals
- Field mappings

### Creating Custom Visualizations

1. Open Kibana at http://localhost:5601
2. Navigate to **Visualize Library**
3. Click **Create visualization**
4. Select your data source (`build-metrics-*` or `run-metrics-*`)
5. Build your custom visualization

## Data Fields Reference

### Build Metrics Fields
- `buildId`: Unique build identifier
- `developer`: Developer who ran the build
- `buildSuccess`: Boolean indicating build success
- `buildDurationSeconds`: Build duration in seconds
- `buildSourceFileCount`: Number of source files
- `buildLineCount`: Total lines of code
- `primaryBuildTool`: Main build tool used (Maven, Gradle, etc.)
- `organization`: Organization name
- `repositoryName`: Repository name

### Run Metrics Fields
- `runId`: Unique run identifier
- `runRecipe`: Recipe that was executed
- `recipesChangedCount`: Number of files changed
- `fileVisitationPercentage`: Percentage of files visited
- `lineVisitationPercentage`: Percentage of lines visited
- `runDurationSeconds`: Total run duration

## Troubleshooting

### Elasticsearch won't start
- Ensure you have at least 4GB RAM available
- Check Docker logs: `docker-compose logs elasticsearch`

### Logstash not receiving data
- Verify the endpoint URL matches the port in docker-compose.yml
- Check Logstash logs: `docker-compose logs logstash`

### Kibana dashboards not loading
- Ensure index patterns exist in Elasticsearch
- Re-run the import script: `./kibana/import-dashboards.sh`

## Stopping the Stack

```bash
# Stop all services
docker-compose down

# Stop and remove all data
docker-compose down -v
```

## Security Considerations

This setup has security features disabled for local development. For production use:
- Enable Elasticsearch security features
- Configure authentication for all services
- Use SSL/TLS for all connections
- Restrict network access appropriately