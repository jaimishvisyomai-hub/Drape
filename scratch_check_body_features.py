import cv2
import numpy as np

# Load raw saree
raw = cv2.imread('crops/raw_uploaded_saree.jpg')
h, w, _ = raw.shape

# Let's inspect rows around Y in [140 .. 350] and X in [140 .. 600]
crop_body = raw[140:350, 140:600]
cv2.imwrite('crops/sample_chest_body.png', crop_body)
print("Saved sample chest body crop. Dimensions:", crop_body.shape)

