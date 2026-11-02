import cv2
import numpy as np

# Load masks
p1_new = cv2.imread('drape-lab/mask_PATLI_01_NEW.png', cv2.IMREAD_UNCHANGED)
mh, mw = p1_new.shape[:2]
p1_alpha = p1_new[:, :, 3] if len(p1_new.shape) == 3 else p1_new
y_idx, x_idx = np.where(p1_alpha > 10)
print(f"PATLI_01_NEW bounds: X=[{np.min(x_idx)/mw:.3f} .. {np.max(x_idx)/mw:.3f}], Y=[{np.min(y_idx)/mh:.3f} .. {np.max(y_idx)/mh:.3f}]")

for name in ['mask_PATLI_01.png', 'mask_PATLI_02.png', 'mask_PATLI_03.png', 'mask_PATLI_04.png', 'mask_PATLI_05.png', 'mask_PATLI_06.png', 'mask_PATLI_07.png', 'mask_patli_08.png']:
    m = cv2.imread(f'drape-lab/{name}', cv2.IMREAD_UNCHANGED)
    alpha = m[:, :, 3] if len(m.shape) == 3 else m
    y, x = np.where(alpha > 10)
    print(f"{name:20s}: X=[{np.min(x)/mw:.3f} .. {np.max(x)/mw:.3f}], Y=[{np.min(y)/mh:.3f} .. {np.max(y)/mh:.3f}]")

