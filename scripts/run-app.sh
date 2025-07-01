#!/bin/bash

# F1 Dash Swift - Run Script
# This script builds and runs the F1 Dash application

set -e

echo "🏁 F1 Dash Swift Runner"
echo "======================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "Package.swift" ]; then
    echo -e "${RED}Error: Package.swift not found. Please run this script from the project root.${NC}"
    exit 1
fi

# Parse command line arguments
MODE=${1:-"all"}

case $MODE in
    "server")
        echo -e "${YELLOW}Building F1 Dash Server...${NC}"
        swift build --product F1DashServer
        echo -e "${GREEN}✓ Server built successfully${NC}"
        echo -e "${YELLOW}Starting server...${NC}"
        .build/debug/F1DashServer serve
        ;;
    
    "app")
        echo -e "${YELLOW}Building F1 Dash App...${NC}"
        swift build --product F1DashMacApp
        echo -e "${GREEN}✓ App built successfully${NC}"
        echo -e "${YELLOW}Launching app...${NC}"
        .build/debug/F1DashMacApp
        ;;
    
    "saver")
        echo -e "${YELLOW}Building F1 Dash Saver...${NC}"
        swift build --product F1DashSaver
        echo -e "${GREEN}✓ Saver built successfully${NC}"
        echo -e "${YELLOW}Run with: .build/debug/F1DashSaver --help${NC}"
        ;;
    
    "test")
        echo -e "${YELLOW}Running tests...${NC}"
        swift test
        echo -e "${GREEN}✓ All tests passed${NC}"
        ;;
    
    "all")
        echo -e "${YELLOW}Building all targets...${NC}"
        swift build
        echo -e "${GREEN}✓ Build completed successfully${NC}"
        echo ""
        echo "To run components:"
        echo "  Server: ./scripts/run-app.sh server"
        echo "  App:    ./scripts/run-app.sh app"
        echo "  Saver:  ./scripts/run-app.sh saver"
        echo "  Tests:  ./scripts/run-app.sh test"
        ;;
    
    *)
        echo "Usage: $0 [server|app|saver|test|all]"
        echo ""
        echo "Options:"
        echo "  server - Build and run the F1 Dash server"
        echo "  app    - Build and run the macOS app"
        echo "  saver  - Build the data saver utility"
        echo "  test   - Run all tests"
        echo "  all    - Build all targets (default)"
        exit 1
        ;;
esac
