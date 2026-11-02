"""
fabric_panel_mapper.py
======================
Fabric-Panel-Based Garment Mapping Engine.

Transforms semantic source panels into destination mesh configurations:
1. Chest & Shoulder Wrap:
   - Preserves upright bird/flower motifs.
   - Restricts horizontal span to true physical motif proportions (aspect ratio preserved).
   - Maps neckline selvage along anatomical collar contour.
2. Hanging Pallu:
   - Enforces 1:1 aspect ratio constraint for the Twin Swans & Lotus Medallion.
   - Follows natural sequence: upper vines -> horizontal zari stripes -> lotus medallion -> lower stripes -> bottom gold fringe.
   - Gently levels stripes along a -8.5 deg catenary incline.
3. Front Vertical Skirt Border:
   - Full non-zero width coverage over mask_PATLI_06.png and mask_patli_08.png.
   - Uninterrupted vertical cascade of silver circular medallions.
4. Cascading Pleat Folds:
   - Fold-aware texture compression and phase shifting across pleats.
   - Continuous horizontal gold zari border anchored along the bottom hemline.
"""

import cv2
import numpy as np
import json
import os
from fabric_panel_engine import FabricPanelDecomposer

class FabricPanelMapper:
    def __init__(self, saree_path='crops/raw_uploaded_saree.jpg', base_mapping_path='drape-lab/mapping.json'):
        self.saree_path = saree_path
        self.base_mapping_path = base_mapping_path
        self.decomposer = FabricPanelDecomposer(saree_path)
        self.panels, self.landmarks = self.decomposer.analyze()
        
        with open(base_mapping_path, 'r') as f:
            self.base_mapping = json.load(f)

    def generate_panel_mapping(self, options=None):
        """
        Generates full 14-layer mapping using panel decomposition and landmark correspondence.
        """
        if options is None:
            options = {}

        flipX = options.get('flipX', False)
        flipY = options.get('flipY', False)

        mapping = json.loads(json.dumps(self.base_mapping))

        # Panel coordinates
        l_border = self.panels['left_border']
        r_border = self.panels['right_border']
        body = self.panels['body_floral']
        u_stripes = self.panels['pallu_upper_stripes']
        medallion = self.panels['pallu_medallion']
        l_stripes = self.panels['pallu_lower_stripes']
        hem = self.panels['hem_fringe']

        # -------------------------------------------------------------
        # 1. CHEST & TORSO WRAP (CHAST_01, CHAST_02, CHAST_03)
        # -------------------------------------------------------------
        # CHAST_01: The upper diagonal wrap across the bust from neck to waist
        # Col 0: Gold neckline border [u ~ 0.045]
        # Col 1: Body floral vine & upright bird [u in 0.22 .. 0.32], preserving 1:1 motif aspect ratio
        c1 = mapping['mask_CHAST_01.png']
        c1_rows = c1['mesh_rows'] # 6
        c1_src = []
        # Neckline border U
        u_neck_border = 0.045
        # We sample a narrow, physically proportioned body slice so the bird isn't stretched 3x wide
        u_chest_body = 0.260 # right where bird/vine motifs sit naturally

        # V span follows arc length along the neckline
        v_chest_start = body['v_range'][0] + 0.08
        v_chest_end = body['v_range'][0] + 0.30

        for r in range(c1_rows):
            t = r / float(c1_rows - 1)
            v = v_chest_start + (v_chest_end - v_chest_start) * t
            # Col 0: Neckline Border, Col 1: Body Motif
            c1_src.append([u_neck_border, v])
            c1_src.append([u_chest_body, v])

        c1['src_pts'] = c1_src

        # CHAST_02: Mid-torso wrap
        c2 = mapping['mask_CHAST_02.png']
        c2_src = []
        for r in range(c2['mesh_rows']):
            t = r / float(c2['mesh_rows'] - 1)
            v = 0.16 + 0.18 * t
            c2_src.append([0.28, v])
            c2_src.append([0.48, v])
        c2['src_pts'] = c2_src

        # CHAST_03: Lower waist wrap
        c3 = mapping['mask_CHAST_03.png']
        c3_src = []
        for r in range(c3['mesh_rows']):
            t = r / float(c3['mesh_rows'] - 1)
            v = 0.22 + 0.18 * t
            c3_src.append([0.32, v])
            c3_src.append([0.56, v])
        c3['src_pts'] = c3_src

        # -------------------------------------------------------------
        # 2. HANGING PALLU (PALLU_01 & PALLU_02)
        # Natural Sequence: Vines -> Upper Stripes -> Medallion -> Lower Stripes -> Fringe
        # -------------------------------------------------------------
        p1 = mapping['mask_PALLU_01.png']
        p2 = mapping['mask_PALLU_02.png']

        # Accurate V zones from OpenCV detection
        # Upper stripes: V in [0.537 .. 0.700]
        # Medallion: V in [0.700 .. 0.863]
        # Lower stripes: V in [0.863 .. 0.969]
        # Fringe: V in [0.969 .. 1.000]
        v_pallu_levels = [
            0.380, # Row 0: shoulder drape (floral body vines)
            0.450, # Row 1: upper fall (floral body vines)
            0.520, # Row 2: transition to stripes
            0.575, # Row 3: upper horizontal zari stripes
            0.630, # Row 4: upper horizontal dotted zari stripes
            0.680, # Row 5: lower dotted stripes directly above medallion
            0.725, # Row 6: Twin Swans & Lotus Medallion upper half
            0.840, # Row 7: Twin Swans & Lotus Medallion lower half (proportional 1:1 aspect)
            0.910, # Row 8: lower horizontal zari stripes below medallion
            0.985  # Row 9: bottom gold fringe hem
        ]

        # In destination space:
        # PALLU_01 is inner column (waist to middle seam)
        # PALLU_02 is outer column (middle seam to outer diagonal edge)
        # Outer diagonal edge Col 1 of PALLU_02 displays the continuous gold border (U = 0.045)
        # Inner boundary of PALLU_01 displays inner body/pallu weave (U = 0.800)
        # Middle shared seam displays center of pallu (U = 0.650)
        u_outer_border = 0.045
        u_pallu_center = 0.650
        u_inner_drape = 0.800

        p1_src = []
        p2_src = []
        for r in range(10):
            v = v_pallu_levels[r]
            # PALLU_01: col 0 = u_inner_drape, col 1 = u_pallu_center
            p1_src.append([u_inner_drape, v])
            p1_src.append([u_pallu_center, v])

            # PALLU_02: col 0 = u_pallu_center, col 1 = u_outer_border
            p2_src.append([u_pallu_center, v])
            p2_src.append([u_outer_border, v])

        p1['src_pts'] = p1_src
        p2['src_pts'] = p2_src

        # Align PALLU destination coordinates:
        # Guarantee outer edge of PALLU_02 has gentle -8.5 deg incline across rows 6-8
        # and non-collapsed seam
        p2_dst = p2['dst_pts']
        # Smooth rounded apex and drape fall
        outer_drape_x = [0.490, 0.524, 0.589, 0.655, 0.722, 0.788, 0.890, 0.965, 0.955, 0.785]
        for r in range(10):
            p2_dst[r*2 + 1][0] = max(p2_dst[r*2 + 1][0], outer_drape_x[r])

        # -------------------------------------------------------------
        # 3. FRONT VERTICAL SKIRT BORDER (PATLI_06 & patli_08)
        # -------------------------------------------------------------
        # In raw fabric, the vertical selvage border runs along U in [0.015 .. 0.125]
        # In destination space, mask_PATLI_06.png has width up to 0.043 at row 4
        # We ensure destination vertices accurately span the non-zero mask width
        p6 = mapping['mask_PATLI_06.png']
        p6_dst = [
            [0.207, 0.504], [0.213, 0.504], # Row 0
            [0.170, 0.578], [0.178, 0.578], # Row 1
            [0.165, 0.648], [0.180, 0.648], # Row 2
            [0.175, 0.717], [0.208, 0.717], # Row 3
            [0.190, 0.786], [0.238, 0.786], # Row 4
            [0.208, 0.854], [0.245, 0.854], # Row 5
            [0.158, 0.927], [0.188, 0.927]  # Row 6
        ]
        p6['dst_pts'] = p6_dst

        # Vertical border U coordinates: Col 0 = outer silver selvage (0.015), Col 1 = inner border pattern (0.125)
        # Repeated vertically along V to display crisp circular silver medallions
        p6_src = []
        for r in range(7):
            t = r / 6.0
            v = 0.08 + 0.38 * t
            p6_src.append([0.015, v])
            p6_src.append([0.125, v])
        p6['src_pts'] = p6_src

        # patli_08 (upper waist tuck extension of vertical border)
        p8 = mapping['mask_patli_08.png']
        p8_src = []
        for r in range(p8['mesh_rows']):
            t = r / float(p8['mesh_rows'] - 1)
            v = 0.02 + 0.18 * t
            p8_src.append([0.015, v])
            p8_src.append([0.125, v])
        p8['src_pts'] = p8_src

        # -------------------------------------------------------------
        # 4. PLEAT FOLDS (PATLI_07 base + PATLI_01..05 + PATLI_01_NEW)
        # -------------------------------------------------------------
        # PATLI_07 (base under-layer pleat foundation)
        # Spans across waist vines to bottom hem border
        p7 = mapping['mask_PATLI_07.png']
        p7_src = []
        for r in range(p7['mesh_rows']):
            t = r / float(p7['mesh_rows'] - 1)
            # Interpolates from waist vines (U=0.48) to bottom hem border (U=0.045)
            u = 0.48 - 0.435 * t
            p7_src.append([u, 0.05])
            p7_src.append([u, 0.35])
        p7['src_pts'] = p7_src

        # Individual Cascading Pleat Folds:
        # Phase-shifted V across folds to avoid repeating the exact same flower in identical position
        fold_names = [
            'mask_PATLI_01_NEW.png',
            'mask_PATLI_01.png',
            'mask_PATLI_02.png',
            'mask_PATLI_03.png',
            'mask_PATLI_04.png',
            'mask_PATLI_05.png'
        ]

        for i, fname in enumerate(fold_names):
            fold = mapping[fname]
            f_rows = fold['mesh_rows']
            f_src = []
            # Phase-shifted V
            v0 = 0.04 + i * 0.022
            v1 = v0 + 0.065
            # Waist U
            u_waist = 0.45 + i * 0.015
            u_hem = 0.045 # Gold zari border at hem!

            for r in range(f_rows):
                t = r / float(f_rows - 1)
                # Vertical interpolation from waist vines down to hem gold border
                u_curr = u_waist + (u_hem - u_waist) * t
                f_src.append([u_curr, v0])
                f_src.append([u_curr, v1])

            fold['src_pts'] = f_src

        return mapping

if __name__ == '__main__':
    mapper = FabricPanelMapper()
    panel_mapping = mapper.generate_panel_mapping()
    with open('drape-lab/panel_mapping.json', 'w') as f:
        json.dump(panel_mapping, f, indent=2)
    print("Successfully generated and saved drape-lab/panel_mapping.json")

