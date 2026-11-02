import json

# Read updated mapping.json
with open('drape-lab/mapping.json', 'r') as f:
    mapping = json.load(f)

# Update default_template.json in both drape-lab/templates/ and assets/templates/
for tpath in ['drape-lab/templates/default_template.json', 'assets/templates/default_template.json']:
    with open(tpath, 'r') as f:
        template = json.load(f)
    for k, v in mapping.items():
        if k in template['layers']:
            template['layers'][k]['dst_pts'] = v['dst_pts']
    with open(tpath, 'w') as f:
        json.dump(template, f, indent=2)

print("Synchronized default_template.json files with updated dst_pts.")

