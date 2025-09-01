#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Initializing ELK Stack...${NC}"

# Wait for Elasticsearch to be ready
echo "Waiting for Elasticsearch to be ready..."
until curl -s http://elasticsearch:9200/_cluster/health | grep -q '"status":"yellow"\|"status":"green"'; do
  sleep 5
done
echo -e "${GREEN}✓ Elasticsearch is ready${NC}"

# Create index templates
echo "Creating Elasticsearch index templates..."

# Build metrics template
curl -X PUT "elasticsearch:9200/_index_template/build-metrics-template" \
  -H 'Content-Type: application/json' \
  -d '{
  "index_patterns": ["build-metrics-*"],
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 0,
      "index.refresh_interval": "5s"
    },
    "mappings": {
      "properties": {
        "origin": { "type": "keyword" },
        "path": { "type": "text", "fields": { "keyword": { "type": "keyword" } } },
        "branch": { "type": "keyword" },
        "developer": { "type": "keyword" },
        "buildSuccess": { "type": "boolean" },
        "buildStatus": { "type": "keyword" },
        "buildStartTime": { "type": "date" },
        "buildEndTime": { "type": "date" },
        "buildStartTimeParsed": { "type": "date" },
        "buildEndTimeParsed": { "type": "date" },
        "buildLog": { "type": "text" },
        "buildId": { "type": "keyword" },
        "buildChangeset": { "type": "keyword" },
        "buildDependencyResolutionTimeMs": { "type": "long" },
        "buildMavenVersion": { "type": "keyword" },
        "buildGradleVersion": { "type": "keyword" },
        "buildBazelVersion": { "type": "keyword" },
        "buildDotnetVersion": { "type": "keyword" },
        "buildPythonVersion": { "type": "keyword" },
        "buildNodeVersion": { "type": "keyword" },
        "buildSourceFileCount": { "type": "integer" },
        "buildLineCount": { "type": "long" },
        "buildParseErrorCount": { "type": "integer" },
        "buildWeight": { "type": "integer" },
        "buildMaxWeight": { "type": "integer" },
        "buildMaxWeightSourceFile": { "type": "text" },
        "buildElapsedTimeMs": { "type": "long" },
        "buildDurationSeconds": { "type": "float" },
        "cloneSuccess": { "type": "boolean" },
        "cloneCloneUri": { "type": "text", "fields": { "keyword": { "type": "keyword" } } },
        "cloneStartTime": { "type": "date" },
        "cloneEndTime": { "type": "date" },
        "cloneStartTimeParsed": { "type": "date" },
        "cloneEndTimeParsed": { "type": "date" },
        "cloneLog": { "type": "text" },
        "cloneChangeset": { "type": "keyword" },
        "cloneElapsedTimeMs": { "type": "long" },
        "cloneDurationSeconds": { "type": "float" },
        "organization": { "type": "keyword" },
        "repositoryOwner": { "type": "keyword" },
        "repositoryName": { "type": "keyword" },
        "primaryBuildTool": { "type": "keyword" },
        "processed_at": { "type": "date" },
        "data_type": { "type": "keyword" }
      }
    }
  }
}' > /dev/null 2>&1

echo -e "${GREEN}✓ Build metrics template created${NC}"

# Run metrics template
curl -X PUT "elasticsearch:9200/_index_template/run-metrics-template" \
  -H 'Content-Type: application/json' \
  -d '{
  "index_patterns": ["run-metrics-*"],
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 0,
      "index.refresh_interval": "5s"
    },
    "mappings": {
      "properties": {
        "origin": { "type": "keyword" },
        "path": { "type": "text", "fields": { "keyword": { "type": "keyword" } } },
        "branch": { "type": "keyword" },
        "developer": { "type": "keyword" },
        "runSuccess": { "type": "boolean" },
        "runStatus": { "type": "keyword" },
        "runStartTime": { "type": "date" },
        "runEndTime": { "type": "date" },
        "runStartTimeParsed": { "type": "date" },
        "runEndTimeParsed": { "type": "date" },
        "runLog": { "type": "text" },
        "runId": { "type": "keyword" },
        "runChangeset": { "type": "keyword" },
        "runMavenVersion": { "type": "keyword" },
        "runGradleVersion": { "type": "keyword" },
        "runBazelVersion": { "type": "keyword" },
        "runDotnetVersion": { "type": "keyword" },
        "runPythonVersion": { "type": "keyword" },
        "runNodeVersion": { "type": "keyword" },
        "runRecipe": { "type": "keyword" },
        "runRecipesChanged": { "type": "text" },
        "recipesChangedList": { "type": "keyword" },
        "recipesChangedCount": { "type": "integer" },
        "runSourceFileCount": { "type": "integer" },
        "runVisitedSourceFileCount": { "type": "integer" },
        "runLineCount": { "type": "long" },
        "runVisitedLineCount": { "type": "long" },
        "runRecipeRunElapsedTimeMs": { "type": "long" },
        "runElapsedTimeMs": { "type": "long" },
        "runDurationSeconds": { "type": "float" },
        "recipeRunDurationSeconds": { "type": "float" },
        "fileVisitationPercentage": { "type": "float" },
        "lineVisitationPercentage": { "type": "float" },
        "organization": { "type": "keyword" },
        "repositoryOwner": { "type": "keyword" },
        "repositoryName": { "type": "keyword" },
        "primaryBuildTool": { "type": "keyword" },
        "processed_at": { "type": "date" },
        "data_type": { "type": "keyword" }
      }
    }
  }
}' > /dev/null 2>&1

echo -e "${GREEN}✓ Run metrics template created${NC}"

# Wait for Kibana to be ready
echo "Waiting for Kibana to be ready..."
until curl -s http://kibana:5601/api/status | grep -q '"level":"available"'; do
  sleep 5
done
echo -e "${GREEN}✓ Kibana is ready${NC}"

# Create index patterns first
echo "Creating Kibana index patterns..."

# Create build metrics index pattern
curl -X POST "kibana:5601/api/saved_objects/index-pattern/build-metrics-*" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "attributes": {
      "title": "build-metrics-*",
      "timeFieldName": "buildStartTimeParsed"
    }
  }' > /dev/null 2>&1

echo -e "${GREEN}✓ Build metrics index pattern created${NC}"

# Create run metrics index pattern
curl -X POST "kibana:5601/api/saved_objects/index-pattern/run-metrics-*" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "attributes": {
      "title": "run-metrics-*",
      "timeFieldName": "runStartTimeParsed"
    }
  }' > /dev/null 2>&1

echo -e "${GREEN}✓ Run metrics index pattern created${NC}"

# Import dashboards
echo "Importing Kibana dashboards..."
curl -X POST "kibana:5601/api/saved_objects/_import?overwrite=true" \
  -H "kbn-xsrf: true" \
  --form file=@/init/dashboards.ndjson \
  > /dev/null 2>&1

echo -e "${GREEN}✓ Dashboards imported successfully${NC}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}ELK Stack initialization complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Access points:"
echo "  • Kibana: http://localhost:5601"
echo "  • Elasticsearch: http://localhost:9200"
echo "  • Logstash: http://localhost:8080"
echo ""
echo "To view dashboards:"
echo "  1. Open http://localhost:5601"
echo "  2. Navigate to Dashboard"
echo "  3. Select 'Moderne Build Metrics' or 'Moderne Run Metrics'"