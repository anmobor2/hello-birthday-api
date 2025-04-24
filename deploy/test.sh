#!/bin/bash
set -euo pipefail

# Test script for Hello API application
# This script runs comprehensive tests before deployment
# Usage: ./test.sh [test_type]

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TEST_TYPE=${1:-"all"}
PYTHON_VERSION=$(python -V 2>&1 | cut -d " " -f 2 | cut -d "." -f 1-2)
echo -e "${BLUE}Running tests with Python ${PYTHON_VERSION}${NC}"

# Prepare directory for test results
mkdir -p test-results

run_unit_tests() {
    echo -e "${YELLOW}Running unit tests...${NC}"

    # Create and activate virtual environment if it doesn't exist
    if [ ! -d ".venv" ]; then
        echo -e "${YELLOW}Creating virtual environment...${NC}"
        python -m venv .venv
    fi

    # Activate virtual environment
    source .venv/bin/activate || source .venv/Scripts/activate

    # Install dependencies
    echo -e "${YELLOW}Installing dependencies...${NC}"
    pip install -r requirements.txt
    pip install -r requirements-dev.txt

    # Run pytest with coverage
    echo -e "${YELLOW}Running pytest...${NC}"
    set +e
    pytest --cov=app --cov-report=xml:test-results/coverage.xml --junitxml=test-results/junit.xml -v
    TEST_EXIT_CODE=$?
    set -e

    # Deactivate virtual environment
    deactivate

    if [ $TEST_EXIT_CODE -ne 0 ]; then
        echo -e "${RED}Unit tests failed!${NC}"
        return $TEST_EXIT_CODE
    else
        echo -e "${GREEN}Unit tests passed!${NC}"
        return 0
    fi
}

run_integration_tests() {
    echo -e "${YELLOW}Running integration tests...${NC}"

    # Check if the API is running
    if [ "${INTEGRATION_TEST_URL:-}" == "" ]; then
        echo -e "${YELLOW}Starting the API locally for integration tests...${NC}"

        # Activate virtual environment
        source .venv/bin/activate || source .venv/Scripts/activate

        # Start the API in the background
        python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 &
        API_PID=$!

        # Give the API time to start
        sleep 3

        # Run integration tests
        echo -e "${YELLOW}Running integration tests against localhost...${NC}"
        set +e
        pytest tests_integration/ -v --junitxml=test-results/junit-integration.xml
        INTEGRATION_EXIT_CODE=$?
        set -e

        # Kill the API process
        kill $API_PID

        # Deactivate virtual environment
        deactivate
    else
        echo -e "${YELLOW}Running integration tests against ${INTEGRATION_TEST_URL}...${NC}"

        # Activate virtual environment
        source .venv/bin/activate || source .venv/Scripts/activate

        # Run integration tests against remote URL
        set +e
        INTEGRATION_TEST_URL="${INTEGRATION_TEST_URL}" pytest tests_integration/ -v --junitxml=test-results/junit-integration.xml
        INTEGRATION_EXIT_CODE=$?
        set -e

        # Deactivate virtual environment
        deactivate
    fi

    if [ $INTEGRATION_EXIT_CODE -ne 0 ]; then
        echo -e "${RED}Integration tests failed!${NC}"
        return $INTEGRATION_EXIT_CODE
    else
        echo -e "${GREEN}Integration tests passed!${NC}"
        return 0
    fi
}

run_security_tests() {
    echo -e "${YELLOW}Running security tests...${NC}"

    # Run bandit for security vulnerabilities
    echo -e "${YELLOW}Running bandit security tests...${NC}"

    # Activate virtual environment
    source .venv/bin/activate || source .venv/Scripts/activate

    # Install bandit if not already installed
    pip install bandit

    # Run bandit
    set +e
    bandit -r app/ -f json -o test-results/bandit-results.json
    BANDIT_EXIT_CODE=$?
    set -e

    # Run safety check on dependencies
    echo -e "${YELLOW}Checking dependencies for vulnerabilities...${NC}"
    pip install safety
    set +e
    safety check --full-report -o json > test-results/safety-results.json
    SAFETY_EXIT_CODE=$?
    set -e

    # Deactivate virtual environment
    deactivate

    # Check for critical issues
    if [ $BANDIT_EXIT_CODE -eq 1 ]; then
        echo -e "${RED}Security tests found high severity issues!${NC}"
        return 1
    elif [ $SAFETY_EXIT_CODE -eq 1 ]; then
        echo -e "${YELLOW}Vulnerable dependencies found. Review test-results/safety-results.json${NC}"
        # Continue even with vulnerable dependencies in non-production environments
        if [ "${ENVIRONMENT:-dev}" == "prod" ]; then
            return 1
        fi
    else
        echo -e "${GREEN}Security tests passed!${NC}"
        return 0
    fi
}

run_docker_tests() {
    echo -e "${YELLOW}Testing Docker image build...${NC}"

    # Build a test image
    docker build -t hello-api:test -f docker/Dockerfile .

    # Run container tests
    echo -e "${YELLOW}Testing container startup...${NC}"
    docker run --name hello-api-test -d -p 8001:8000 hello-api:test

    # Wait for container to start
    sleep 5

    # Test if container is responding
    set +e
    curl -s http://localhost:8001/health > test-results/container-health.json
    CURL_EXIT_CODE=$?
    set -e

    # Capture logs
    docker logs hello-api-test > test-results/container-logs.txt

    # Stop and remove container
    docker stop hello-api-test
    docker rm hello-api-test

    # Check results
    if [ $CURL_EXIT_CODE -ne 0 ]; then
        echo -e "${RED}Container tests failed! The container did not respond.${NC}"
        return 1
    else
        echo -e "${GREEN}Container tests passed!${NC}"
        return 0
    fi
}

# Main testing flow
case $TEST_TYPE in
    unit)
        run_unit_tests
        ;;
    integration)
        run_integration_tests
        ;;
    security)
        run_security_tests
        ;;
    docker)
        run_docker_tests
        ;;
    all)
        echo -e "${BLUE}Running all tests...${NC}"
        run_unit_tests
        run_integration_tests
        run_security_tests
        run_docker_tests
        echo -e "${GREEN}All tests completed successfully!${NC}"
        ;;
    *)
        echo -e "${RED}Unknown test type: $TEST_TYPE${NC}"
        echo "Usage: $0 [unit|integration|security|docker|all]"
        exit 1
        ;;
esac

echo -e "${BLUE}Test results saved to test-results directory${NC}"
exit 0