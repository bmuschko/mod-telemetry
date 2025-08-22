#!/bin/bash

# Moderne CLI wrapper script with telemetry publishing
# This script wraps the Moderne CLI to handle telemetry collection and publishing

set -e

# Configuration - Use environment variables if set, otherwise use defaults
MOD_JAR="${MOD_JAR:-mod.jar}"  # Path to the Moderne CLI JAR
MIN_VERSION="3.45.0"  # Set minimum required version (versions less than 3.45.0 do not generate telemetry metrics)
TELEMETRY_DIR="$HOME/.moderne/cli/trace"  # Fixed telemetry directory
TELEMETRY_ENDPOINT="${TELEMETRY_ENDPOINT:-}"  # Set your BI system endpoint URL

# Color codes for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to compare versions
version_compare() {
    if [[ -z "$1" || -z "$2" ]]; then
        return 0
    fi
    
    IFS='.' read -ra V1 <<< "$1"
    IFS='.' read -ra V2 <<< "$2"
    
    for i in "${!V1[@]}"; do
        if [[ ${V1[i]} -gt ${V2[i]:-0} ]]; then
            return 0
        elif [[ ${V1[i]} -lt ${V2[i]:-0} ]]; then
            return 1
        fi
    done
    return 0
}

# Function to check CLI version
check_version() {
    if [[ -z "$MIN_VERSION" ]]; then
        return 0
    fi
    
    # Get current CLI version
    if [[ -f "$MOD_JAR" ]]; then
        CURRENT_VERSION=$(java -jar "$MOD_JAR" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    elif command -v mod &> /dev/null; then
        CURRENT_VERSION=$(mod --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    else
        echo -e "${RED}Error: Moderne CLI not found${NC}" >&2
        exit 1
    fi
    
    if [[ -z "$CURRENT_VERSION" ]]; then
        echo -e "${YELLOW}Warning: Could not determine CLI version${NC}" >&2
        return 0
    fi
    
    if ! version_compare "$CURRENT_VERSION" "$MIN_VERSION"; then
        echo -e "${RED}Error: Moderne CLI version $CURRENT_VERSION is below minimum required version $MIN_VERSION${NC}" >&2
        echo -e "${RED}Versions prior to $MIN_VERSION do not generate telemetry metrics${NC}" >&2
        echo -e "${RED}Please update your Moderne CLI: https://docs.moderne.io/installation${NC}" >&2
        exit 1
    fi
}

# Function to publish telemetry data
publish_telemetry() {
    if [[ ! -d "$TELEMETRY_DIR" ]]; then
        return 0
    fi
    
    # Find all CSV files in the telemetry directory
    shopt -s nullglob
    CSV_FILES=("$TELEMETRY_DIR"/*.csv)
    shopt -u nullglob
    
    if [[ ${#CSV_FILES[@]} -eq 0 ]]; then
        return 0
    fi
    
    echo "Publishing telemetry data..." >&2
    
    for csv_file in "${CSV_FILES[@]}"; do
        if [[ -f "$csv_file" ]]; then
            # Only attempt to publish if endpoint is configured
            if [[ -n "$TELEMETRY_ENDPOINT" ]]; then
                # Post CSV to BI system
                if curl -X POST \
                    -H "Content-Type: text/csv" \
                    --data-binary "@$csv_file" \
                    "$TELEMETRY_ENDPOINT" \
                    --silent --fail --show-error 2>/dev/null; then
                    
                    # Delete CSV on successful post
                    rm -f "$csv_file"
                    echo -e "${GREEN} Published: $(basename "$csv_file")${NC}" >&2
                else
                    echo -e "${YELLOW}� Failed to publish: $(basename "$csv_file")${NC}" >&2
                fi
            else
                echo -e "${YELLOW}Note: Telemetry endpoint not configured. Skipping: $(basename "$csv_file")${NC}" >&2
            fi
        fi
    done
}

# Main execution
main() {
    # Check CLI version if minimum version is configured
    check_version
    
    # Execute the Moderne CLI with forwarded arguments
    if [[ -f "$MOD_JAR" ]]; then
        java -jar "$MOD_JAR" "$@"
        CLI_EXIT_CODE=$?
    elif command -v mod &> /dev/null; then
        mod "$@"
        CLI_EXIT_CODE=$?
    else
        echo -e "${RED}Error: Moderne CLI not found at $MOD_JAR${NC}" >&2
        echo "Please set the correct path to the Moderne CLI JAR file" >&2
        exit 1
    fi
    
    # Publish telemetry data after CLI execution
    publish_telemetry
    
    # Exit with the same code as the CLI
    exit $CLI_EXIT_CODE
}

# Run main function
main "$@"