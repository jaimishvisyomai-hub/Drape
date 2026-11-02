const fs = require('fs');

function getMaskBoundingBox(filePath) {
    // Read raw file
    const buf = fs.readFileSync(filePath);
    // Find IHDR
    const w = buf.readUInt32BE(16);
    const h = buf.readUInt32BE(20);
    return { w, h };
}

console.log('Done');

