import cv2
import numpy as np

cur = cv2.imread('crops/hybrid_draped_result.png')
h, w, _ = cur.shape
print(f"Current draped result dimensions: {w} x {h}")

hsv = cv2.cvtColor(cur, cv2.COLOR_BGR2HSV)
mask_red = cv2.inRange(hsv, np.array([0, 70, 70]), np.array([12, 255, 255])) | cv2.inRange(hsv, np.array([168, 70, 70]), np.array([180, 255, 255]))

# Pallu Medallion in cur:
# Look in Y > 0.60 * h, X > 0.20 * w
med_cur = mask_red[int(0.60*h):int(0.95*h), int(0.20*w):int(0.95*w)]
y_idx, x_idx = np.where(med_cur > 0)
if len(y_idx) > 0:
    min_x = int(0.20*w) + np.min(x_idx)
    max_x = int(0.20*w) + np.max(x_idx)
    min_y = int(0.60*h) + np.min(y_idx)
    max_y = int(0.60*h) + np.max(y_idx)
    print(f"Current Output Pallu Medallion:")
    print(f"  X: [{min_x} .. {max_x}] (Width = {max_x - min_x} px, Norm X = [{min_x/w:.3f} .. {max_x/w:.3f}])")
    print(f"  Y: [{min_y} .. {max_y}] (Height = {max_y - min_y} px, Norm Y = [{min_y/h:.3f} .. {max_y/h:.3f}])")
    print(f"  Aspect Ratio (W/H) in Current = {(max_x - min_x)/(max_y - min_y):.2f}")

# Chest Bird in cur:
bird_cur = mask_red[int(0.18*h):int(0.35*h), int(0.15*w):int(0.45*w)]
by_idx, bx_idx = np.where(bird_cur > 0)
if len(by_idx) > 0:
    min_bx = int(0.15*w) + np.min(bx_idx)
    max_bx = int(0.15*w) + np.max(bx_idx)
    min_by = int(0.18*h) + np.min(by_idx)
    max_by = int(0.18*h) + np.max(by_idx)
    print(f"Current Output Chest Bird:")
    print(f"  X: [{min_bx} .. {max_bx}] (Width = {max_bx - min_bx} px, Norm X = [{min_bx/w:.3f} .. {max_bx/w:.3f}])")
    print(f"  Y: [{min_by} .. {max_by}] (Height = {max_by - min_by} px, Norm Y = [{min_by/h:.3f} .. {max_by/h:.3f}])")

