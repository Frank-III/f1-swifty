#!/bin/bash

echo "Starting F1DashServer..."
./.build/debug/F1DashServer --development --simulate=./scripts/Austria\ Sprint\ Race\ Data\ 2023.txt &
PID=$!

echo "Server PID: $PID"
echo "Waiting 5 seconds..."
sleep 5

echo "Sending SIGINT (Ctrl+C) to process..."
kill -INT $PID

echo "Waiting for process to terminate..."
wait $PID 2>/dev/null
EXIT_CODE=$?

if ps -p $PID > /dev/null 2>&1; then
    echo "ERROR: Process still running after SIGINT"
    echo "Forcing kill..."
    kill -9 $PID
else
    echo "SUCCESS: Process terminated gracefully"
    echo "Exit code: $EXIT_CODE"
fi

# Check if port is still in use
if lsof -i :8080 > /dev/null 2>&1; then
    echo "ERROR: Port 8080 is still in use"
    lsof -i :8080
else
    echo "SUCCESS: Port 8080 is free"
fi