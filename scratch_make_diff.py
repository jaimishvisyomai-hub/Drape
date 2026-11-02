import cv2
import numpy as np

cur = cv2.imread('crops/hybrid_draped_result.png')
sv = cv2.imread(r'C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\.user_uploaded\media_1793595637172_bc78bab3.jpg')

# Normalize cur to 586 x 886 for exact visual comparison
cur_resized = cv2.resize(cur, (586, 886))

# Let's crop:
# 1. Chest: [150:350, 100:300]
# 2. Pallu: [450:850, 120:550]
# 3. Pleats: [450:850, 50:280]

cv2.imwrite('crops/side_by_side_cur.png', cur_resized)
cv2.imwrite('crops/side_by_side_sv.png', sv)

# Save combined side-by-side
combined = np.hstack([cur_resized, sv])
cv2.imwrite('crops/side_by_side_diff.png', combined)
print("Saved side-by-side comparison images.")

