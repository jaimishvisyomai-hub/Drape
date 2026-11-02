import cv2
import numpy as np

cur = cv2.imread('crops/side_by_side_cur.png')
sv = cv2.imread('crops/side_by_side_sv.png')

# 1. Chest: Y in [140 .. 340], X in [100 .. 280]
c_cur = cur[140:340, 100:280]
c_sv = sv[140:340, 100:280]
chest_comp = np.hstack([c_cur, c_sv])
cv2.imwrite('crops/panel_eval_chest.png', chest_comp)

# 2. Pallu: Y in [400 .. 850], X in [120 .. 560]
p_cur = cur[400:850, 120:560]
p_sv = sv[400:850, 120:560]
pallu_comp = np.hstack([p_cur, p_sv])
cv2.imwrite('crops/panel_eval_pallu.png', pallu_comp)

# 3. Pleats: Y in [450 .. 860], X in [30 .. 250]
pl_cur = cur[450:860, 30:250]
pl_sv = sv[450:860, 30:250]
pleat_comp = np.hstack([pl_cur, pl_sv])
cv2.imwrite('crops/panel_eval_pleat.png', pleat_comp)

print("Saved panel evaluation crops.")

