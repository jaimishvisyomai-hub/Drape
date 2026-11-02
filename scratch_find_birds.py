import cv2
import numpy as np

# Load raw saree
raw = cv2.imread('crops/raw_uploaded_saree.jpg')
h, w, _ = raw.shape
hsv = cv2.cvtColor(raw, cv2.COLOR_BGR2HSV)
mask_red = cv2.inRange(hsv, np.array([0, 70, 70]), np.array([12, 255, 255])) | cv2.inRange(hsv, np.array([168, 70, 70]), np.array([180, 255, 255]))

# Find red components in upper body (Y < 800)
num_labels, labels, stats, centroids = cv2.connectedComponentsWithStats(mask_red[:800, :])
print(f"Detected {num_labels} red components in body region (Y < 800):")
birds = []
for i in range(1, num_labels):
    area = stats[i, cv2.CC_STAT_AREA]
    if area > 100:
        bx = stats[i, cv2.CC_STAT_LEFT]
        by = stats[i, cv2.CC_STAT_TOP]
        bw = stats[i, cv2.CC_STAT_WIDTH]
        bh = stats[i, cv2.CC_STAT_HEIGHT]
        print(f"  Component {i}: Area={area:4d}, BBox=[X:{bx:3d}..{bx+bw:3d}, Y:{by:3d}..{by+bh:3d}]")
        birds.append((bx, by, bw, bh))

