#!/bin/bash

# Set a variable for the screenshot file
SCREENSHOT="/tmp/screenshot.png"
BLURRED_SCREENSHOT="/tmp/screenshot_blurred.png"

# Take a screenshot with grim
grim "$SCREENSHOT"

# Blur the screenshot using ImageMagick (adjust the blur radius as needed)
magick "$SCREENSHOT" -resize 50% -blur 0x8 -resize 200% "$BLURRED_SCREENSHOT"

# Set the blurred image as the background in swaylock
swaylock -f -i "$BLURRED_SCREENSHOT"

# Clean up the temporary screenshot files after use
rm "$SCREENSHOT" "$BLURRED_SCREENSHOT"
