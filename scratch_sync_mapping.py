import json
from fabric_panel_mapper import FabricPanelMapper

mapper = FabricPanelMapper()
new_mapping = mapper.generate_panel_mapping()

# Overwrite drape-lab/mapping.json
with open('drape-lab/mapping.json', 'w') as f:
    json.dump(new_mapping, f, indent=2)

print("Synchronized drape-lab/mapping.json with FabricPanelMapper.")

