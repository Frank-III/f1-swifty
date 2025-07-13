#!/usr/bin/env python3
import json
import sseclient
import requests

def test_sse_connection():
    url = "http://127.0.0.1:8080/v1/live/sse"
    print(f"Connecting to {url}...")
    
    response = requests.get(url, stream=True)
    client = sseclient.SSEClient(response)
    
    event_count = 0
    for event in client.events():
        event_count += 1
        print(f"\n=== Event {event_count} ===")
        print(f"Event type: {event.event}")
        
        try:
            data = json.loads(event.data)
            print(f"Data keys: {list(data.keys())}")
            
            # Check for race control messages
            if 'raceControlMessages' in data:
                print(f"Race control messages found: {json.dumps(data['raceControlMessages'], indent=2)[:500]}...")
            
            # Check for position data (for track map)
            if 'positionData' in data:
                print(f"Position data found: {json.dumps(data['positionData'], indent=2)[:500]}...")
                
            # Check for session info (for track data)
            if 'sessionInfo' in data:
                print(f"Session info found: {json.dumps(data['sessionInfo'], indent=2)[:500]}...")
                
        except json.JSONDecodeError:
            print(f"Raw data: {event.data[:200]}...")
            
        # Stop after first few events to see structure
        if event_count >= 5:
            print("\nStopping after 5 events...")
            break

if __name__ == "__main__":
    test_sse_connection()