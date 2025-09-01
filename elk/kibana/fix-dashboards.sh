#!/bin/bash

set -e

echo "Deleting existing dashboard objects..."

# Delete existing build dashboard objects
curl -X DELETE "localhost:5601/api/saved_objects/dashboard/moderne-telemetry-overview" \
  -H "kbn-xsrf: true" 2>/dev/null || true

curl -X DELETE "localhost:5601/api/saved_objects/visualization/build-success-rate" \
  -H "kbn-xsrf: true" 2>/dev/null || true

curl -X DELETE "localhost:5601/api/saved_objects/visualization/build-duration-histogram" \
  -H "kbn-xsrf: true" 2>/dev/null || true

curl -X DELETE "localhost:5601/api/saved_objects/visualization/builds-by-tool" \
  -H "kbn-xsrf: true" 2>/dev/null || true

curl -X DELETE "localhost:5601/api/saved_objects/visualization/builds-over-time" \
  -H "kbn-xsrf: true" 2>/dev/null || true

# Delete existing run dashboard objects
curl -X DELETE "localhost:5601/api/saved_objects/dashboard/moderne-run-metrics" \
  -H "kbn-xsrf: true" 2>/dev/null || true

curl -X DELETE "localhost:5601/api/saved_objects/visualization/run-success-rate" \
  -H "kbn-xsrf: true" 2>/dev/null || true

curl -X DELETE "localhost:5601/api/saved_objects/visualization/recipes-executed" \
  -H "kbn-xsrf: true" 2>/dev/null || true

curl -X DELETE "localhost:5601/api/saved_objects/visualization/file-visitation-rate" \
  -H "kbn-xsrf: true" 2>/dev/null || true

curl -X DELETE "localhost:5601/api/saved_objects/visualization/runs-over-time" \
  -H "kbn-xsrf: true" 2>/dev/null || true

echo "Creating new visualizations..."

# Create Build Success Rate Pie Chart
curl -X POST "localhost:5601/api/saved_objects/visualization/build-success-rate" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "attributes": {
      "title": "Build Success Rate",
      "visState": "{\"title\":\"Build Success Rate\",\"type\":\"pie\",\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"count\",\"params\":{\"emptyAsNull\":false},\"schema\":\"metric\"},{\"id\":\"2\",\"enabled\":true,\"type\":\"terms\",\"params\":{\"field\":\"buildStatus\",\"orderBy\":\"1\",\"order\":\"desc\",\"size\":5,\"otherBucket\":false,\"otherBucketLabel\":\"Other\",\"missingBucket\":false,\"missingBucketLabel\":\"Missing\"},\"schema\":\"segment\"}],\"params\":{\"type\":\"pie\",\"addTooltip\":true,\"legendPosition\":\"right\",\"nestedLegend\":false,\"truncateLegend\":true,\"maxLegendLines\":1,\"palette\":{\"type\":\"palette\",\"name\":\"status\"},\"distinctColors\":null,\"labels\":{\"show\":true,\"values\":true,\"last_level\":true,\"truncate\":100},\"row\":true}}",
      "uiStateJSON": "{}",
      "kibanaSavedObjectMeta": {
        "searchSourceJSON": "{\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[],\"indexRefName\":\"kibanaSavedObjectMeta.searchSourceJSON.index\"}"
      }
    },
    "references": [
      {
        "name": "kibanaSavedObjectMeta.searchSourceJSON.index",
        "type": "index-pattern",
        "id": "build-metrics-*"
      }
    ]
  }' > /dev/null

# Create Build Duration Histogram
curl -X POST "localhost:5601/api/saved_objects/visualization/build-duration-histogram" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "attributes": {
      "title": "Build Duration Distribution",
      "visState": "{\"title\":\"Build Duration Distribution\",\"type\":\"histogram\",\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"count\",\"params\":{\"emptyAsNull\":false},\"schema\":\"metric\"},{\"id\":\"2\",\"enabled\":true,\"type\":\"histogram\",\"params\":{\"field\":\"buildDurationSeconds\",\"interval\":30,\"used_interval\":30,\"min_doc_count\":false,\"extended_bounds\":{\"min\":0,\"max\":600}},\"schema\":\"segment\"}],\"params\":{\"type\":\"histogram\",\"grid\":{\"categoryLines\":false,\"valueAxis\":\"ValueAxis-1\"},\"categoryAxes\":[{\"id\":\"CategoryAxis-1\",\"type\":\"category\",\"position\":\"bottom\",\"show\":true,\"style\":{},\"scale\":{\"type\":\"linear\"},\"labels\":{\"show\":true,\"filter\":true,\"truncate\":100},\"title\":{}}],\"valueAxes\":[{\"id\":\"ValueAxis-1\",\"name\":\"LeftAxis-1\",\"type\":\"value\",\"position\":\"left\",\"show\":true,\"style\":{},\"scale\":{\"type\":\"linear\",\"mode\":\"normal\"},\"labels\":{\"show\":true,\"rotate\":0,\"filter\":false,\"truncate\":100},\"title\":{\"text\":\"Count\"}}],\"seriesParams\":[{\"show\":true,\"type\":\"histogram\",\"mode\":\"stacked\",\"data\":{\"label\":\"Count\",\"id\":\"1\"},\"valueAxis\":\"ValueAxis-1\",\"drawLinesBetweenPoints\":true,\"lineWidth\":2,\"showCircles\":true,\"circlesRadius\":1}],\"addTooltip\":true,\"addLegend\":true,\"legendPosition\":\"right\",\"times\":[],\"addTimeMarker\":false,\"labels\":{\"show\":false},\"thresholdLine\":{\"show\":false,\"value\":10,\"width\":1,\"style\":\"full\",\"color\":\"#E7664C\"}}}",
      "uiStateJSON": "{}",
      "kibanaSavedObjectMeta": {
        "searchSourceJSON": "{\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[],\"indexRefName\":\"kibanaSavedObjectMeta.searchSourceJSON.index\"}"
      }
    },
    "references": [
      {
        "name": "kibanaSavedObjectMeta.searchSourceJSON.index",
        "type": "index-pattern",
        "id": "build-metrics-*"
      }
    ]
  }' > /dev/null

# Create Builds by Tool Pie Chart
curl -X POST "localhost:5601/api/saved_objects/visualization/builds-by-tool" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "attributes": {
      "title": "Builds by Tool",
      "visState": "{\"title\":\"Builds by Tool\",\"type\":\"pie\",\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"count\",\"params\":{\"emptyAsNull\":false},\"schema\":\"metric\"},{\"id\":\"2\",\"enabled\":true,\"type\":\"terms\",\"params\":{\"field\":\"primaryBuildTool\",\"orderBy\":\"1\",\"order\":\"desc\",\"size\":10,\"otherBucket\":false,\"otherBucketLabel\":\"Other\",\"missingBucket\":false,\"missingBucketLabel\":\"Missing\"},\"schema\":\"segment\"}],\"params\":{\"type\":\"pie\",\"addTooltip\":true,\"legendPosition\":\"right\",\"nestedLegend\":false,\"truncateLegend\":true,\"maxLegendLines\":1,\"palette\":{\"type\":\"palette\",\"name\":\"default\"},\"distinctColors\":null,\"labels\":{\"show\":true,\"values\":true,\"last_level\":true,\"truncate\":100},\"row\":true}}",
      "uiStateJSON": "{}",
      "kibanaSavedObjectMeta": {
        "searchSourceJSON": "{\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[],\"indexRefName\":\"kibanaSavedObjectMeta.searchSourceJSON.index\"}"
      }
    },
    "references": [
      {
        "name": "kibanaSavedObjectMeta.searchSourceJSON.index",
        "type": "index-pattern",
        "id": "build-metrics-*"
      }
    ]
  }' > /dev/null

# Create Builds Over Time Line Chart
curl -X POST "localhost:5601/api/saved_objects/visualization/builds-over-time" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "attributes": {
      "title": "Builds Over Time",
      "visState": "{\"title\":\"Builds Over Time\",\"type\":\"line\",\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"count\",\"params\":{\"emptyAsNull\":false},\"schema\":\"metric\"},{\"id\":\"2\",\"enabled\":true,\"type\":\"date_histogram\",\"params\":{\"field\":\"buildStartTimeParsed\",\"timeRange\":{\"from\":\"now-90d\",\"to\":\"now\"},\"useNormalizedOpenInterval\":true,\"scaleMetricValues\":false,\"interval\":\"auto\",\"used_interval\":\"1d\",\"drop_partials\":false,\"min_doc_count\":1,\"extended_bounds\":{}},\"schema\":\"segment\"}],\"params\":{\"type\":\"line\",\"grid\":{\"categoryLines\":false,\"valueAxis\":\"ValueAxis-1\"},\"categoryAxes\":[{\"id\":\"CategoryAxis-1\",\"type\":\"category\",\"position\":\"bottom\",\"show\":true,\"style\":{},\"scale\":{\"type\":\"linear\"},\"labels\":{\"show\":true,\"filter\":true,\"truncate\":100},\"title\":{}}],\"valueAxes\":[{\"id\":\"ValueAxis-1\",\"name\":\"LeftAxis-1\",\"type\":\"value\",\"position\":\"left\",\"show\":true,\"style\":{},\"scale\":{\"type\":\"linear\",\"mode\":\"normal\"},\"labels\":{\"show\":true,\"rotate\":0,\"filter\":false,\"truncate\":100},\"title\":{\"text\":\"Build Count\"}}],\"seriesParams\":[{\"show\":true,\"type\":\"line\",\"mode\":\"normal\",\"data\":{\"label\":\"Count\",\"id\":\"1\"},\"valueAxis\":\"ValueAxis-1\",\"drawLinesBetweenPoints\":true,\"lineWidth\":2,\"interpolate\":\"linear\",\"showCircles\":true}],\"addTooltip\":true,\"addLegend\":true,\"legendPosition\":\"right\",\"times\":[],\"addTimeMarker\":false,\"labels\":{},\"thresholdLine\":{\"show\":false,\"value\":10,\"width\":1,\"style\":\"full\",\"color\":\"#E7664C\"}}}",
      "uiStateJSON": "{}",
      "kibanaSavedObjectMeta": {
        "searchSourceJSON": "{\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[],\"indexRefName\":\"kibanaSavedObjectMeta.searchSourceJSON.index\"}"
      }
    },
    "references": [
      {
        "name": "kibanaSavedObjectMeta.searchSourceJSON.index",
        "type": "index-pattern",
        "id": "build-metrics-*"
      }
    ]
  }' > /dev/null

echo "Creating dashboard..."

# Create Dashboard
curl -X POST "localhost:5601/api/saved_objects/dashboard/moderne-telemetry-overview" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "attributes": {
      "title": "Moderne Build Metrics",
      "hits": 0,
      "description": "Metrics for mod build command executions",
      "panelsJSON": "[{\"version\":\"8.15.0\",\"gridData\":{\"x\":0,\"y\":0,\"w\":24,\"h\":15,\"i\":\"1\"},\"panelIndex\":\"1\",\"embeddableConfig\":{},\"panelRefName\":\"panel_1\"},{\"version\":\"8.15.0\",\"gridData\":{\"x\":24,\"y\":0,\"w\":24,\"h\":15,\"i\":\"2\"},\"panelIndex\":\"2\",\"embeddableConfig\":{},\"panelRefName\":\"panel_2\"},{\"version\":\"8.15.0\",\"gridData\":{\"x\":0,\"y\":15,\"w\":24,\"h\":15,\"i\":\"3\"},\"panelIndex\":\"3\",\"embeddableConfig\":{},\"panelRefName\":\"panel_3\"},{\"version\":\"8.15.0\",\"gridData\":{\"x\":24,\"y\":15,\"w\":24,\"h\":15,\"i\":\"4\"},\"panelIndex\":\"4\",\"embeddableConfig\":{},\"panelRefName\":\"panel_4\"}]",
      "timeRestore": true,
      "timeFrom": "now-90d",
      "timeTo": "now",
      "optionsJSON": "{\"useMargins\":true,\"syncColors\":false,\"syncCursor\":true,\"syncTooltips\":false,\"hidePanelTitles\":false}",
      "kibanaSavedObjectMeta": {
        "searchSourceJSON": "{\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[]}"
      }
    },
    "references": [
      {
        "name": "panel_1",
        "type": "visualization",
        "id": "build-success-rate"
      },
      {
        "name": "panel_2",
        "type": "visualization",
        "id": "build-duration-histogram"
      },
      {
        "name": "panel_3",
        "type": "visualization",
        "id": "builds-by-tool"
      },
      {
        "name": "panel_4",
        "type": "visualization",
        "id": "builds-over-time"
      }
    ]
  }' > /dev/null

echo "Creating Run Metrics visualizations..."

# Create Run Success Rate Pie Chart
curl -X POST "localhost:5601/api/saved_objects/visualization/run-success-rate" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "attributes": {
      "title": "Recipe Run Success Rate",
      "visState": "{\"title\":\"Recipe Run Success Rate\",\"type\":\"pie\",\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"count\",\"params\":{\"emptyAsNull\":false},\"schema\":\"metric\"},{\"id\":\"2\",\"enabled\":true,\"type\":\"terms\",\"params\":{\"field\":\"runStatus\",\"orderBy\":\"1\",\"order\":\"desc\",\"size\":5,\"otherBucket\":false,\"otherBucketLabel\":\"Other\",\"missingBucket\":false,\"missingBucketLabel\":\"Missing\"},\"schema\":\"segment\"}],\"params\":{\"type\":\"pie\",\"addTooltip\":true,\"legendPosition\":\"right\",\"nestedLegend\":false,\"truncateLegend\":true,\"maxLegendLines\":1,\"palette\":{\"type\":\"palette\",\"name\":\"status\"},\"distinctColors\":null,\"labels\":{\"show\":true,\"values\":true,\"last_level\":true,\"truncate\":100},\"row\":true}}",
      "uiStateJSON": "{}",
      "kibanaSavedObjectMeta": {
        "searchSourceJSON": "{\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[],\"indexRefName\":\"kibanaSavedObjectMeta.searchSourceJSON.index\"}"
      }
    },
    "references": [
      {
        "name": "kibanaSavedObjectMeta.searchSourceJSON.index",
        "type": "index-pattern",
        "id": "run-metrics-*"
      }
    ]
  }' > /dev/null

# Create Recipes Executed Bar Chart
curl -X POST "localhost:5601/api/saved_objects/visualization/recipes-executed" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "attributes": {
      "title": "Top Recipes Executed",
      "visState": "{\"title\":\"Top Recipes Executed\",\"type\":\"horizontal_bar\",\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"count\",\"params\":{\"emptyAsNull\":false},\"schema\":\"metric\"},{\"id\":\"2\",\"enabled\":true,\"type\":\"terms\",\"params\":{\"field\":\"runRecipe\",\"orderBy\":\"1\",\"order\":\"desc\",\"size\":10,\"otherBucket\":false,\"otherBucketLabel\":\"Other\",\"missingBucket\":false,\"missingBucketLabel\":\"Missing\"},\"schema\":\"segment\"}],\"params\":{\"type\":\"histogram\",\"grid\":{\"categoryLines\":false,\"valueAxis\":\"ValueAxis-1\"},\"categoryAxes\":[{\"id\":\"CategoryAxis-1\",\"type\":\"category\",\"position\":\"left\",\"show\":true,\"style\":{},\"scale\":{\"type\":\"linear\"},\"labels\":{\"show\":true,\"filter\":false,\"truncate\":200},\"title\":{}}],\"valueAxes\":[{\"id\":\"ValueAxis-1\",\"name\":\"LeftAxis-1\",\"type\":\"value\",\"position\":\"bottom\",\"show\":true,\"style\":{},\"scale\":{\"type\":\"linear\",\"mode\":\"normal\"},\"labels\":{\"show\":true,\"rotate\":0,\"filter\":false,\"truncate\":100},\"title\":{\"text\":\"Execution Count\"}}],\"seriesParams\":[{\"show\":true,\"type\":\"histogram\",\"mode\":\"stacked\",\"data\":{\"label\":\"Count\",\"id\":\"1\"},\"valueAxis\":\"ValueAxis-1\",\"drawLinesBetweenPoints\":true,\"lineWidth\":2,\"showCircles\":true,\"circlesRadius\":1}],\"addTooltip\":true,\"addLegend\":false,\"legendPosition\":\"right\",\"times\":[],\"addTimeMarker\":false,\"labels\":{},\"thresholdLine\":{\"show\":false,\"value\":10,\"width\":1,\"style\":\"full\",\"color\":\"#E7664C\"}}}",
      "uiStateJSON": "{}",
      "kibanaSavedObjectMeta": {
        "searchSourceJSON": "{\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[],\"indexRefName\":\"kibanaSavedObjectMeta.searchSourceJSON.index\"}"
      }
    },
    "references": [
      {
        "name": "kibanaSavedObjectMeta.searchSourceJSON.index",
        "type": "index-pattern",
        "id": "run-metrics-*"
      }
    ]
  }' > /dev/null

# Create File Visitation Gauge
curl -X POST "localhost:5601/api/saved_objects/visualization/file-visitation-rate" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "attributes": {
      "title": "Average File Visitation Rate",
      "visState": "{\"title\":\"Average File Visitation Rate\",\"type\":\"gauge\",\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"avg\",\"params\":{\"field\":\"fileVisitationPercentage\",\"emptyAsNull\":false},\"schema\":\"metric\"}],\"params\":{\"type\":\"gauge\",\"addTooltip\":true,\"addLegend\":true,\"isDisplayWarning\":false,\"gauge\":{\"alignment\":\"automatic\",\"extendRange\":true,\"percentageMode\":true,\"gaugeType\":\"Arc\",\"gaugeStyle\":\"Full\",\"backStyle\":\"Full\",\"orientation\":\"vertical\",\"colorSchema\":\"Green to Red\",\"colorsRange\":[{\"from\":0,\"to\":50},{\"from\":50,\"to\":75},{\"from\":75,\"to\":100}],\"invertColors\":false,\"labels\":{\"show\":true,\"color\":\"black\"},\"scale\":{\"show\":true,\"labels\":false,\"color\":\"rgba(105,112,125,0.2)\"},\"type\":\"meter\",\"style\":{\"bgWidth\":0.9,\"width\":0.9,\"mask\":false,\"bgMask\":false,\"maskBars\":50,\"bgFill\":\"rgba(105,112,125,0.2)\",\"bgColor\":true,\"subText\":\"\",\"fontSize\":60}}}}",
      "uiStateJSON": "{}",
      "kibanaSavedObjectMeta": {
        "searchSourceJSON": "{\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[],\"indexRefName\":\"kibanaSavedObjectMeta.searchSourceJSON.index\"}"
      }
    },
    "references": [
      {
        "name": "kibanaSavedObjectMeta.searchSourceJSON.index",
        "type": "index-pattern",
        "id": "run-metrics-*"
      }
    ]
  }' > /dev/null

# Create Runs Over Time Line Chart
curl -X POST "localhost:5601/api/saved_objects/visualization/runs-over-time" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "attributes": {
      "title": "Recipe Runs Over Time",
      "visState": "{\"title\":\"Recipe Runs Over Time\",\"type\":\"line\",\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"count\",\"params\":{\"emptyAsNull\":false},\"schema\":\"metric\"},{\"id\":\"2\",\"enabled\":true,\"type\":\"date_histogram\",\"params\":{\"field\":\"runStartTimeParsed\",\"timeRange\":{\"from\":\"now-90d\",\"to\":\"now\"},\"useNormalizedOpenInterval\":true,\"scaleMetricValues\":false,\"interval\":\"auto\",\"used_interval\":\"1d\",\"drop_partials\":false,\"min_doc_count\":1,\"extended_bounds\":{}},\"schema\":\"segment\"}],\"params\":{\"type\":\"line\",\"grid\":{\"categoryLines\":false,\"valueAxis\":\"ValueAxis-1\"},\"categoryAxes\":[{\"id\":\"CategoryAxis-1\",\"type\":\"category\",\"position\":\"bottom\",\"show\":true,\"style\":{},\"scale\":{\"type\":\"linear\"},\"labels\":{\"show\":true,\"filter\":true,\"truncate\":100},\"title\":{}}],\"valueAxes\":[{\"id\":\"ValueAxis-1\",\"name\":\"LeftAxis-1\",\"type\":\"value\",\"position\":\"left\",\"show\":true,\"style\":{},\"scale\":{\"type\":\"linear\",\"mode\":\"normal\"},\"labels\":{\"show\":true,\"rotate\":0,\"filter\":false,\"truncate\":100},\"title\":{\"text\":\"Run Count\"}}],\"seriesParams\":[{\"show\":true,\"type\":\"line\",\"mode\":\"normal\",\"data\":{\"label\":\"Count\",\"id\":\"1\"},\"valueAxis\":\"ValueAxis-1\",\"drawLinesBetweenPoints\":true,\"lineWidth\":2,\"interpolate\":\"linear\",\"showCircles\":true}],\"addTooltip\":true,\"addLegend\":true,\"legendPosition\":\"right\",\"times\":[],\"addTimeMarker\":false,\"labels\":{},\"thresholdLine\":{\"show\":false,\"value\":10,\"width\":1,\"style\":\"full\",\"color\":\"#E7664C\"}}}",
      "uiStateJSON": "{}",
      "kibanaSavedObjectMeta": {
        "searchSourceJSON": "{\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[],\"indexRefName\":\"kibanaSavedObjectMeta.searchSourceJSON.index\"}"
      }
    },
    "references": [
      {
        "name": "kibanaSavedObjectMeta.searchSourceJSON.index",
        "type": "index-pattern",
        "id": "run-metrics-*"
      }
    ]
  }' > /dev/null

# Create Run Metrics Dashboard
curl -X POST "localhost:5601/api/saved_objects/dashboard/moderne-run-metrics" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "attributes": {
      "title": "Moderne Run Metrics",
      "hits": 0,
      "description": "Metrics for mod run command executions",
      "panelsJSON": "[{\"version\":\"8.15.0\",\"gridData\":{\"x\":0,\"y\":0,\"w\":24,\"h\":15,\"i\":\"1\"},\"panelIndex\":\"1\",\"embeddableConfig\":{},\"panelRefName\":\"panel_1\"},{\"version\":\"8.15.0\",\"gridData\":{\"x\":24,\"y\":0,\"w\":24,\"h\":15,\"i\":\"2\"},\"panelIndex\":\"2\",\"embeddableConfig\":{},\"panelRefName\":\"panel_2\"},{\"version\":\"8.15.0\",\"gridData\":{\"x\":0,\"y\":15,\"w\":24,\"h\":15,\"i\":\"3\"},\"panelIndex\":\"3\",\"embeddableConfig\":{},\"panelRefName\":\"panel_3\"},{\"version\":\"8.15.0\",\"gridData\":{\"x\":24,\"y\":15,\"w\":24,\"h\":15,\"i\":\"4\"},\"panelIndex\":\"4\",\"embeddableConfig\":{},\"panelRefName\":\"panel_4\"}]",
      "timeRestore": true,
      "timeFrom": "now-90d",
      "timeTo": "now",
      "optionsJSON": "{\"useMargins\":true,\"syncColors\":false,\"syncCursor\":true,\"syncTooltips\":false,\"hidePanelTitles\":false}",
      "kibanaSavedObjectMeta": {
        "searchSourceJSON": "{\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[]}"
      }
    },
    "references": [
      {
        "name": "panel_1",
        "type": "visualization",
        "id": "run-success-rate"
      },
      {
        "name": "panel_2",
        "type": "visualization",
        "id": "recipes-executed"
      },
      {
        "name": "panel_3",
        "type": "visualization",
        "id": "file-visitation-rate"
      },
      {
        "name": "panel_4",
        "type": "visualization",
        "id": "runs-over-time"
      }
    ]
  }' > /dev/null

echo "Dashboards recreated successfully!"
echo "Available dashboards:"
echo "  • Build Metrics: http://localhost:5601/app/dashboards → 'Moderne Build Metrics'"
echo "  • Run Metrics: http://localhost:5601/app/dashboards → 'Moderne Run Metrics'"