#!/bin/bash

# Moderne CLI wrapper script with telemetry publishing
# This script wraps the Moderne CLI to handle telemetry collection and publishing

set -e

# Configuration - Use environment variables if set, otherwise use defaults
MOD_JAR="${MOD_JAR:-mod.jar}"  # Path to the Moderne CLI JAR
MIN_VERSION="3.45.0"  # Set minimum required version (versions less than 3.45.0 do not generate telemetry metrics)
TELEMETRY_DIR="$HOME/.moderne/cli/trace"  # Telemetry directory in user's home
BI_ENDPOINT="${BI_ENDPOINT:-}"  # Set your BI system endpoint URL

# Authentication configuration (optional)
BI_AUTH_USER="${BI_AUTH_USER:-}"  # Username for basic auth
BI_AUTH_PASS="${BI_AUTH_PASS:-}"  # Password for basic auth

# Proxy configuration (optional)
HTTP_PROXY="${HTTP_PROXY:-}"  # HTTP Proxy URL (e.g., http://proxy.example.com:8080)
HTTPS_PROXY="${HTTPS_PROXY:-}"  # HTTPS Proxy URL (e.g., https://proxy.example.com:443)
PROXY_USER="${PROXY_USER:-}"  # Proxy username
PROXY_PASS="${PROXY_PASS:-}"  # Proxy password

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
        CURRENT_VERSION=$(java -jar "$MOD_JAR" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | tail -1)
    elif command -v mod &> /dev/null; then
        CURRENT_VERSION=$(mod --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | tail -1)
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
    local command_name="$1"
    
    # Skip if no command name provided
    if [[ -z "$command_name" ]]; then
        return 0
    fi
    
    if [[ ! -d "$TELEMETRY_DIR" ]]; then
        return 0
    fi
    
    # Look for CSV files under the command subdirectory
    local search_dir="$TELEMETRY_DIR/$command_name"
    if [[ ! -d "$search_dir" ]]; then
        return 0
    fi
    
    # Find all CSV files in the search directory and subdirectories recursively
    # Using find for compatibility with older bash versions (macOS default is 3.2)
    CSV_FILES=()
    while IFS= read -r -d '' file; do
        CSV_FILES+=("$file")
    done < <(find "$search_dir" -name "*.csv" -type f -print0 2>/dev/null)
    
    if [[ ${#CSV_FILES[@]} -eq 0 ]]; then
        return 0
    fi
    
    echo "Publishing telemetry data to $BI_ENDPOINT..." >&2
    
    for csv_file in "${CSV_FILES[@]}"; do
        if [[ -f "$csv_file" ]]; then
            parent_dir="$(dirname "$csv_file")"
            # Get relative path from current directory
            relative_path="${csv_file#$(pwd)/}"
            echo "Processing: $relative_path" >&2
            # Only attempt to publish if endpoint is configured
            if [[ -n "$BI_ENDPOINT" ]]; then
                # Build curl command with optional parameters
                CURL_CMD=(curl -X POST -H "Content-Type: text/csv" -H "X-Event-Type: $command_name" --data-binary "@$csv_file")
                
                # Add basic authentication if configured
                if [[ -n "$BI_AUTH_USER" && -n "$BI_AUTH_PASS" ]]; then
                    CURL_CMD+=(--user "$BI_AUTH_USER:$BI_AUTH_PASS")
                fi
                
                # Add proxy configuration if configured
                # Determine which proxy to use based on endpoint URL
                PROXY_URL=""
                if [[ "$BI_ENDPOINT" == https://* && -n "$HTTPS_PROXY" ]]; then
                    PROXY_URL="$HTTPS_PROXY"
                elif [[ -n "$HTTP_PROXY" ]]; then
                    PROXY_URL="$HTTP_PROXY"
                fi
                
                if [[ -n "$PROXY_URL" ]]; then
                    CURL_CMD+=(--proxy "$PROXY_URL")
                    
                    # Add proxy authentication if configured
                    if [[ -n "$PROXY_USER" && -n "$PROXY_PASS" ]]; then
                        CURL_CMD+=(--proxy-user "$PROXY_USER:$PROXY_PASS")
                    fi
                fi
                
                # Add endpoint and common options
                CURL_CMD+=("$BI_ENDPOINT" --silent --fail --show-error)
                
                # Execute curl command
                ERROR_MSG=$("${CURL_CMD[@]}" 2>&1)
                
                if [[ $? -eq 0 ]]; then
                    # Delete parent directory on successful post (e.g., 20250822153915-gemmm/)
                    rm -rf "$parent_dir"
                    echo -e "${GREEN}[OK] Published: $relative_path${NC}" >&2
                else
                    echo -e "${YELLOW}[WARN] Failed to publish: $relative_path${NC}" >&2
                    echo -e "${YELLOW}       Error: $ERROR_MSG${NC}" >&2
                fi
            else
                echo -e "${YELLOW}Note: Telemetry endpoint not configured. Skipping: $relative_path${NC}" >&2
            fi
        fi
    done
}

# Main execution
main() {
    # Extract the first command argument (e.g., "build" from "mod.sh build .")
    local command_name="$1"
    
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
    
    # Add a newline after mod output
    echo >&2
    
    # Publish telemetry data after CLI execution, passing the command name
    publish_telemetry "$command_name"
    
    # Exit with the same code as the CLI
    exit $CLI_EXIT_CODE
}

# Run main function
main "$@"