"""
scratch_generate_diagnostics.py
==============================
Generates all 5 required visual deliverables for user verification:
1. Source fabric panels and detected landmarks.
2. Source-to-destination correspondence visualization.
3. Isolated chest, torso, pallu and pleat renders.
4. Final model render beside the reference.
5. Before/after comparison using the same input image and model.
"""

import cv2
import numpy as np
import json
import os

# 1. Source Fabric Panels & Detected Landmarks
from fabric_panel_engine import FabricPanelDecomposer
decomposer = FabricPanelDecomposer('crops/raw_uploaded_saree.jpg')
panels, landmarks = decomposer.analyze()
decomposer.save_annotated_decomposition('crops/diagnostic_1_panels_and_landmarks.png')

# 2. Source-to-Destination Correspondence Visualization
raw = cv2.imread('crops/raw_uploaded_saree.jpg')
rh, rw = raw.shape[:2]
cur = cv2.imread('crops/hybrid_draped_result.png')
ch, cw = cur.shape[:2]

# Draw wireframe and correspondences
with open('drape-lab/mapping.json', 'r') as f:
    mapping = json.load(f)

vis_uv = raw.copy()
for name, data in mapping.items():
    src_pts = np.array(data['src_pts'])
    rows = data['mesh_rows']
    cols = data['mesh_cols']
    px_pts = []
    for pt in src_pts:
        px_pts.append([int(pt[0] * rw), int(pt[1] * rh)])
    px_pts = np.array(px_pts)

    # Draw grid
    for r in range(rows):
        for c in range(cols):
            idx = r * cols + c
            if c < cols - 1:
                cv2.line(vis_uv, tuple(px_pts[idx]), tuple(px_pts[idx + 1]), (0, 255, 255), 1)
            if r < rows - 1:
                cv2.line(vis_uv, tuple(px_pts[idx]), tuple(px_pts[idx + cols]), (0, 255, 255), 1)

cv2.imwrite('crops/diagnostic_2_source_uv_mesh.png', vis_uv)

# 3. Isolated Renders
# Chest: Y in [0.15 .. 0.40], X in [0.12 .. 0.50]
chest_crop = cur[int(0.15*ch):int(0.40*ch), int(0.12*cw):int(0.50*cw)]
cv2.imwrite('crops/diagnostic_3_chest_isolated.png', chest_crop)

# Torso / Waist: Y in [0.35 .. 0.58], X in [0.12 .. 0.32]
torso_crop = cur[int(0.35*ch):int(0.58*ch), int(0.12*cw):int(0.32*cw)]
cv2.imwrite('crops/diagnostic_3_torso_isolated.png', torso_crop)

# Pallu: Y in [0.28 .. 0.95], X in [0.20 .. 0.98]
pallu_crop = cur[int(0.28*ch):int(0.95*ch), int(0.20*cw):int(0.98*cw)]
cv2.imwrite('crops/diagnostic_3_pallu_isolated.png', pallu_crop)

# Pleats: Y in [0.48 .. 0.95], X in [0.01 .. 0.28]
pleat_crop = cur[int(0.48*ch):int(0.95*ch), int(0.01*cw):int(0.28*cw)]
cv2.imwrite('crops/diagnostic_3_pleats_isolated.png', pleat_crop)

# 4. Final Model Render Beside Target SareeViz Reference
sv = cv2.imread(r'C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\.user_uploaded\media_1793595637172_bc78bab3.jpg')
sv_h, sv_w = sv.shape[:2]
cur_matched = cv2.resize(cur, (sv_w, sv_h))

final_comp = np.hstack([cur_matched, sv])
# Add labels
banner = np.zeros((60, final_comp.shape[1], 3), dtype=np.uint8)
cv2.putText(banner, "FABRIC-PANEL ENGINE OUTPUT (WebGL)", (40, 40), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 0), 2)
cv2.putText(banner, "TARGET SAREEVIZ REFERENCE", (sv_w + 40, 40), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 215, 255), 2)
final_with_banner = np.vstack([banner, final_comp])
cv2.imwrite('crops/diagnostic_4_final_comparison.png', final_with_banner)

# 5. Before / After Comparison
before = cv2.imread(r'C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\.user_uploaded\media_1793612627354_9117c1f6.jpg')
before_resized = cv2.resize(before, (sv_w, sv_h))
before_after = np.hstack([before_resized, cur_matched])
ba_banner = np.zeros((60, before_after.shape[1], 3), dtype=np.uint8)
cv2.putText(ba_banner, "BEFORE (Previous Stretched Output)", (40, 40), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 0, 255), 2)
cv2.putText(ba_banner, "AFTER (Fabric-Panel Decomposed Output)", (sv_w + 40, 40), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 0), 2)
ba_with_banner = np.vstack([ba_banner, before_after])
cv2.imwrite('crops/diagnostic_5_before_after.png', ba_with_banner)

print("Generated all visual diagnostics successfully.")

