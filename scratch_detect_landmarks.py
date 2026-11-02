import cv2
import numpy as np

raw = cv2.imread('crops/raw_uploaded_saree.jpg')
h, w, _ = raw.shape
hsv = cv2.cvtColor(raw, cv2.COLOR_BGR2HSV)
gray = cv2.cvtColor(raw, cv2.COLOR_BGR2GRAY)

mask_red = cv2.inRange(hsv, np.array([0, 70, 70]), np.array([12, 255, 255])) | cv2.inRange(hsv, np.array([168, 70, 70]), np.array([180, 255, 255]))

# 1. Medallion Bounding Box in Y in [1100 .. 1400]
med_red = mask_red[1100:1400, :]
y_indices, x_indices = np.where(med_red > 0)
min_x, max_x = np.min(x_indices), np.max(x_indices)
min_y, max_y = 1100 + np.min(y_indices), 1100 + np.max(y_indices)

print(f"Twin Swans & Lotus Medallion Bounding Box:")
print(f"  X: [{min_x} .. {max_x}] (Width = {max_x - min_x} px, Norm U = [{min_x/w:.3f} .. {max_x/w:.3f}])")
print(f"  Y: [{min_y} .. {max_y}] (Height = {max_y - min_y} px, Norm V = [{min_y/h:.3f} .. {max_y/h:.3f}])")
print(f"  Aspect Ratio (W/H) = {(max_x - min_x)/(max_y - min_y):.2f}")

# 2. Left and Right Borders
# Look at vertical edge brightness and texture in grayscale
left_col_means = np.mean(gray[200:800, :180], axis=0)
print(f"Left border columns 0..30 mean: {np.mean(left_col_means[:30]):.1f}, cols 120..150: {np.mean(left_col_means[120:150]):.1f}, cols 150..180 (body): {np.mean(left_col_means[150:180]):.1f}")

# Find sharp boundary between border and body (drop in brightness / texture)
diffs = np.abs(np.diff(left_col_means))
border_edge_x = np.argmax(diffs[80:150]) + 80
print(f"Detected Left Decorative Border Width = {border_edge_x} px (Norm U = {border_edge_x/w:.3f})")

# Right border
right_col_means = np.mean(gray[200:800, -180:], axis=0)
diffs_r = np.abs(np.diff(right_col_means))
border_r_x = w - 180 + np.argmax(diffs_r[30:100]) + 30
print(f"Detected Right Decorative Border Start = {border_r_x} px (Norm U = {border_r_x/w:.3f})")

# 3. Zari Stripes between Body and Lotus Medallion
# Between y = 850 and y = 1150
print(f"Upper Pallu Stripes: Y in [860 .. 1120] (Norm V in [{860/h:.3f} .. {1120/h:.3f}])")
# 4. Lower Pallu Stripes below Lotus Medallion
print(f"Lower Pallu Stripes: Y in [1380 .. 1550] (Norm V in [{1380/h:.3f} .. {1550/h:.3f}])")
# 5. Bottom Hem / Fringe
print(f"Bottom Hem / Fringe: Y in [1550 .. 1600] (Norm V in [{1550/h:.3f} .. 1.000])")

