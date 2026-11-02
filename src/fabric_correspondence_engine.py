"""
Fabric Correspondence Warping Engine (Reference-Guided)
======================================================
Implements piecewise affine and dense feature-anchored correspondence warping
for saree fabric panels onto target garment silhouettes.
"""

import cv2
import numpy as np
from scipy.spatial import Delaunay

class FabricCorrespondenceEngine:
    def __init__(self, target_shape=(731, 483)):
        self.target_shape = target_shape # (H, W)
        self.regions = {}

    def add_region(self, region_name, src_anchors, tgt_anchors, target_mask=None):
        """
        src_anchors: List of (x, y) coordinates on the flat fabric
        tgt_anchors: List of (x, y) coordinates on the target garment
        target_mask: Optional binary uint8 mask for region clipping
        """
        src_pts = np.float32(src_anchors)
        tgt_pts = np.float32(tgt_anchors)
        
        # Build Delaunay triangulation on the target garment domain
        tri = Delaunay(tgt_pts)
        
        self.regions[region_name] = {
            'src_pts': src_pts,
            'tgt_pts': tgt_pts,
            'tri': tri,
            'mask': target_mask
        }

    @staticmethod
    def _warp_triangle(img_src, img_dst, tri_src, tri_dst):
        r_src = cv2.boundingRect(np.float32([tri_src]))
        r_dst = cv2.boundingRect(np.float32([tri_dst]))

        tri_src_cropped = []
        tri_dst_cropped = []
        tri_dst_cropped_int = []

        for i in range(3):
            tri_src_cropped.append(((tri_src[i][0] - r_src[0]), (tri_src[i][1] - r_src[1])))
            tri_dst_cropped.append(((tri_dst[i][0] - r_dst[0]), (tri_dst[i][1] - r_dst[1])))
            tri_dst_cropped_int.append(((int(tri_dst[i][0] - r_dst[0])), (int(tri_dst[i][1] - r_dst[1]))))

        src_cropped = img_src[max(0, r_src[1]):r_src[1] + r_src[3], max(0, r_src[0]):r_src[0] + r_src[2]]
        if src_cropped.shape[0] == 0 or src_cropped.shape[1] == 0:
            return

        warp_mat = cv2.getAffineTransform(np.float32(tri_src_cropped), np.float32(tri_dst_cropped))
        dst_cropped = cv2.warpAffine(src_cropped, warp_mat, (r_dst[2], r_dst[3]), None,
                                    flags=cv2.INTER_LINEAR, borderMode=cv2.BORDER_REFLECT_101)

        mask = np.zeros((r_dst[3], r_dst[2], 3), dtype=np.float32)
        cv2.fillConvexPoly(mask, np.int32(tri_dst_cropped_int), (1.0, 1.0, 1.0), 16, 0)

        y1, y2 = max(0, r_dst[1]), min(img_dst.shape[0], r_dst[1] + r_dst[3])
        x1, x2 = max(0, r_dst[0]), min(img_dst.shape[1], r_dst[0] + r_dst[2])
        
        my1, my2 = y1 - r_dst[1], y2 - r_dst[1]
        mx1, mx2 = x1 - r_dst[0], x2 - r_dst[0]

        img_dst[y1:y2, x1:x2] = img_dst[y1:y2, x1:x2] * (1.0 - mask[my1:my2, mx1:mx2]) + \
                                dst_cropped[my1:my2, mx1:mx2] * mask[my1:my2, mx1:mx2]

    def warp_panel(self, region_name, source_image):
        """Warp an individual panel from source image to target canvas"""
        reg = self.regions[region_name]
        H, W = self.target_shape
        panel_canvas = np.zeros((H, W, 3), dtype=np.float32)
        
        src_f = source_image.astype(np.float32)
        for simplex in reg['tri'].simplices:
            t_src = reg['src_pts'][simplex]
            t_tgt = reg['tgt_pts'][simplex]
            self._warp_triangle(src_f, panel_canvas, t_src, t_tgt)
            
        panel_uint8 = np.clip(panel_canvas, 0, 255).astype(np.uint8)
        if reg['mask'] is not None:
            m = (reg['mask'] > 0)[:, :, np.newaxis]
            panel_uint8 = panel_uint8 * m
            
        return panel_uint8

    def render_full_composite(self, source_image, blend_order=None):
        """Composite all warped panels in correct layering order"""
        H, W = self.target_shape
        composite = np.zeros((H, W, 3), dtype=np.uint8)
        composite_mask = np.zeros((H, W), dtype=np.uint8)
        
        if blend_order is None:
            blend_order = list(self.regions.keys())
            
        rendered_panels = {}
        for name in blend_order:
            panel = self.warp_panel(name, source_image)
            rendered_panels[name] = panel
            
            # Panel coverage mask
            p_mask = (panel.sum(axis=2) > 0).astype(np.uint8) * 255
            if self.regions[name]['mask'] is not None:
                p_mask = cv2.bitwise_and(p_mask, self.regions[name]['mask'])
                
            # Alpha composite
            p_bool = (p_mask > 0)[:, :, np.newaxis]
            composite = np.where(p_bool, panel, composite)
            composite_mask = np.bitwise_or(composite_mask, p_mask)
            
        return composite, composite_mask, rendered_panels

