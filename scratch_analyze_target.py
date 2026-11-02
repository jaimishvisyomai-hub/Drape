import cv2
import numpy as np

sv = cv2.imread(r'C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\.user_uploaded\media_1793595637172_bc78bab3.jpg')
h, w, _ = sv.shape
print(f"Target SareeViz dimensions: {w} x {h}")

hsv = cv2.cvtColor(sv, cv2.COLOR_BGR2HSV)
mask_red = cv2.inRange(hsv, np.array([0, 70, 70]), np.array([12, 255, 255])) | cv2.inRange(hsv, np.array([168, 70, 70]), np.array([180, 255, 255]))

# Find Lotus in SareeViz (bottom right drape)
# Usually y in [600 .. 850], x in [200 .. 550]
med_sv = mask_red[600:850, 200:550]
y_idx, x_idx = np.where(med_sv > 0)
if len(y_idx) > 0:
    min_x = 200 + np.min(x_idx)
    max_x = 200 + np.max(x_idx)
    min_y = 600 + np.min(y_idx)
    max_y = 600 + np.max(y_idx)
    print(f"SareeViz Pallu Medallion:")
    print(f"  X: [{min_x} .. {max_x}] (Width = {max_x - min_x} px, Norm X = [{min_x/w:.3f} .. {max_x/w:.3f}])")
    print(f"  Y: [{min_y} .. {max_y}] (Height = {max_y - min_y} px, Norm Y = [{min_y/h:.3f} .. {max_y/h:.3f}])")
    print(f"  Aspect Ratio (W/H) in SareeViz = {(max_x - min_x)/(max_y - min_y):.2f}")

# Find Chest Bird in SareeViz
# Upper chest: y in [180 .. 300], x in [150 .. 260]
bird_sv = mask_red[180:300, 150:260]
by_idx, bx_idx = np.where(bird_sv > 0)
if len(by_idx) > 0:
    min_bx = 150 + np.min(bx_idx)
    max_bx = 150 + np.max(bx_idx)
    min_by = 180 + np.min(by_idx)
    max_by = 180 + np.max(by_idx)
    print(f"SareeViz Chest Bird:")
    print(f"  X: [{min_bx} .. {max_bx}] (Width = {max_bx - min_bx} px, Norm X = [{min_bx/w:.3f} .. {max_bx/w:.3f}])")
    print(f"  Y: [{min_by} .. {max_by}] (Height = {max_by - min_by} px, Norm Y = [{min_by/h:.3f} .. {max_by/h:.3f}])")

