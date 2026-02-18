---
description: Verify SSH connection and FlyTo works on the Liquid Galaxy rig
---

# Test LG Connection Workflow

## Prerequisites

- Liquid Galaxy rig (or VM) is running
- Google Earth is launched on the master node
- You know the IP, port, username, and password

## Step 1: Configure Settings

Open the app → Settings → Enter:

- Host IP (e.g. `192.168.56.101`)
- Port: `22`
- Username: `lg`
- Password: `lg`
- Screen Count: `3`
  Save settings.

## Step 2: Connect

On the Home screen, tap **"Connect to LG"**.

- ✅ Green indicator = connected and verified
- ❌ Red indicator = connection failed (check IP/credentials)

## Step 3: Test FlyTo

Tap **"Fly to NYC"** button.

- ✅ Google Earth should fly to New York City
- Verify the camera moves on the rig screens

## Step 4: Test Cleanup

Tap **"Clean & Reset"** button.

- ✅ All KML overlays should be removed
- ✅ Camera should reset to world view

## Step 5: Disconnect

Tap **"Disconnect"**.

- ✅ Indicator should turn red

## Troubleshooting

| Symptom                          | Fix                                                    |
| -------------------------------- | ------------------------------------------------------ |
| Can't connect                    | Check IP, ensure VM is running, verify port 22 is open |
| Connected but FlyTo doesn't work | Check `/tmp/query.txt` permissions on the rig          |
| KMLs don't appear                | Check `/var/www/html/kml/` directory exists            |
| Camera doesn't move              | Verify Google Earth is running on the master node      |
