import json
import cv2
import numpy as np

# Load masks
p6_mask = cv2.imread('drape-lab/mask_PATLI_06.png', cv2.IMREAD_UNCHANGED)
mh, mw = p6_mask.shape[:2]
print(f"Mask dimensions: {mw} x {mh}")

# Rows 0..6
y_r = [0.504, 0.578, 0.648, 0.717, 0.786, 0.854, 0.927]
for r, yn in enumerate(y_r):
    ypx = int(yn * mh)
    row = p6_mask[ypx, :, 3] if len(p6_mask.shape) == 3 else p6_mask[ypx, :]
    nz = np.where(row > 10)[0]
    if len(nz) > 0:
        min_x = nz[0] / mw
        max_x = nz[-1] / mw
        print(f"Row {r} (Y={yn:.3f}, py={ypx}): minX={min_x:.3f}, maxX={max_x:.3f}, width={max_x-min_x:.3f}")
    else:
        # Check +/- 5 pixels
        nearby = p6_mask[max(0, ypx-5):min(mh, ypx+6), :, 3] if len(p6_mask.shape) == 3 else p6_mask[max(0, ypx-5):min(mh, ypx+6), :]
        nz_n = np.where(nearby > 10)
        if len(nz_n[1]) > 0:
            min_x = np.min(nz_n[1]) / mw
            max_x = np.max(nz_n[1]) / mw
            print(f"Row {r} (Y={yn:.3f}, nearby): minX={min_x:.3f}, maxX={max_x:.3f}, width={max_x-min_x:.3f}")
        else:
            print(f"Row {r} (Y={yn:.3f}): EMPTY")

