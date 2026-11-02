import json

# Inspect mask_PATLI_06 dst_pts
with open('drape-lab/mapping.json', 'r') as f:
    mapping = json.load(f)

p6 = mapping['mask_PATLI_06.png']
print("PATLI_06 mesh_rows:", p6['mesh_rows'], "mesh_cols:", p6['mesh_cols'])
for r in range(p6['mesh_rows']):
    p0 = p6['dst_pts'][r*2]
    p1 = p6['dst_pts'][r*2 + 1]
    dx = p1[0] - p0[0]
    dy = p1[1] - p0[1]
    print(f"Row {r}: Col0=({p0[0]:.3f}, {p0[1]:.3f}) -> Col1=({p1[0]:.3f}, {p1[1]:.3f}) | Width={dx:.3f}")

