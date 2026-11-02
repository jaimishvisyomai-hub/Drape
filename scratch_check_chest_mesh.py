import json
import numpy as np

# Load base mapping template to get dst_pts
with open('drape-lab/mapping.json', 'r') as f:
    mapping = json.load(f)

# Inspect CHAST_01 dst_pts
c1 = mapping['mask_CHAST_01.png']
dst = np.array(c1['dst_pts'])
print("CHAST_01 dst_pts shape:", dst.shape)
for r in range(c1['mesh_rows']):
    p0 = dst[r*2]
    p1 = dst[r*2 + 1]
    dx = p1[0] - p0[0]
    dy = p1[1] - p0[1]
    print(f"Row {r}: Col0=(X={p0[0]:.3f}, Y={p0[1]:.3f}) -> Col1=(X={p1[0]:.3f}, Y={p1[1]:.3f}) | Width={dx:.3f}")

