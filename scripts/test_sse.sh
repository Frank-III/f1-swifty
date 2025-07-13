#!/bin/bash

echo "Testing SSE connection to F1DashServer..."
echo "Press Ctrl+C to stop"
echo ""

# Connect to SSE endpoint and show first few events
curl -N -H "Accept: text/event-stream" http://127.0.0.1:8080/v1/live/sse 2>/dev/null | while IFS= read -r line; do
    if [[ $line == data:* ]]; then
        # Extract just the data line and pretty print if it's JSON
        data="${line#data:}"
        if [[ $data == {* ]]; then
            # It's JSON, show just the keys
            echo "Event data keys: $(echo "$data" | jq -r 'keys | join(", ")' 2>/dev/null || echo "Invalid JSON")"
            
            # Check for specific data
            if echo "$data" | jq -e '.raceControlMessages' >/dev/null 2>&1; then
                echo "  → Race control messages found!"
            fi
            if echo "$data" | jq -e '.positionData' >/dev/null 2>&1; then
                echo "  → Position data found!"
            fi
            if echo "$data" | jq -e '.timingData' >/dev/null 2>&1; then
                echo "  → Timing data found!"
            fi
        else
            echo "Event data: $data"
        fi
    elif [[ $line == event:* ]]; then
        echo "Event type: ${line#event:}"
    fi
done