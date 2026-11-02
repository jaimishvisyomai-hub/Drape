import cv2
import numpy as np
import json

raw = cv2.imread('crops/raw_uploaded_saree.jpg')
h, w, _ = raw.shape

# 1. Convert to HSV and Grayscale
gray = cv2.cvtColor(raw, cv2.COLOR_BGR2GRAY)
hsv = cv2.cvtColor(raw, cv2.COLOR_BGR2HSV)

# Red/Orange mask (for flowers and lotus medallion):
# H in [0..10] or [170..180], S > 80, V > 60
mask_red1 = cv2.inRange(hsv, np.array([0, 70, 70]), np.array([12, 255, 255]))
mask_red2 = cv2.inRange(hsv, np.array([168, 70, 70]), np.array([180, 255, 255]))
mask_red = mask_red1 | mask_red2

# Gold/Yellow mask (for zari stripes, border highlights, swan wings):
# H in [15..35], S > 50, V > 100
mask_gold = cv2.inRange(hsv, np.array([15, 40, 100]), np.array([38, 255, 255]))

# Silver/Zari border mask (left & right borders):
# High value, low saturation or specific silvery-gold
# Left border is x in [0 .. 150]
# Right border is x in [840 .. 960]

# Horizontal stripe detection along Y axis:
# Sum of gold & red pixels along each row y
row_gold = np.sum(mask_gold > 0, axis=1)
row_red = np.sum(mask_red > 0, axis=1)

print(f"Saree Image Dimensions: {w} x {h}")
# Analyze vertical segments along Y
for y_band in range(0, h, 100):
    g_sum = np.sum(row_gold[y_band:y_band+100])
    r_sum = np.sum(row_red[y_band:y_band+100])
    print(f"Y [{y_band:4d} .. {y_band+100:4d}]: Gold={g_sum:6d}, Red={r_sum:6d}")

# Find peak red and gold in lower half (Y > 800)
lower_red = row_red[800:]
max_red_y = 800 + np.argmax(lower_red)
print(f"Max red intensity in lower half at Y = {max_red_y} (Lotus medallion center)")

# Find stripes region (dense gold stripes above lotus)
stripes_y = np.where(row_gold[800:1200] > 150)[0] + 800
if len(stripes_y) > 0:
    print(f"Zari stripes span Y = [{stripes_y[0]} .. {stripes_y[-1]}]")

# Detect left border width
col_std = np.std(gray[:800, :], axis=0) # in body section
col_gold = np.sum(mask_gold[:800, :] > 0, axis=0)
border_left_end = np.where(col_gold > 100)[0]
print(f"Left border active columns: min={border_left_end[0] if len(border_left_end) else 0}, max={border_left_end[-1] if len(border_left_end) else 0}")

