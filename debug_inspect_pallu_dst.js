const fs = require('fs');
const mapping = JSON.parse(fs.readFileSync('drape-lab/mapping.json', 'utf8'));

const p1 = mapping['mask_PALLU_01.png'];
const p2 = mapping['mask_PALLU_02.png'];

console.log('P1 rows:', p1.mesh_rows, 'cols:', p1.mesh_cols);
console.log('P2 rows:', p2.mesh_rows, 'cols:', p2.mesh_cols);

console.log('\nP1 dst_pts:');
p1.dst_pts.forEach((pt, i) => {
    const r = Math.floor(i / p1.mesh_cols);
    const c = i % p1.mesh_cols;
    if (r === 0 || r === 4 || r === 9) {
        console.log(`r=${r}, c=${c}: [${pt[0].toFixed(3)}, ${pt[1].toFixed(3)}]`);
    }
});

console.log('\nP2 dst_pts:');
p2.dst_pts.forEach((pt, i) => {
    const r = Math.floor(i / p2.mesh_cols);
    const c = i % p2.mesh_cols;
    if (r === 0 || r === 4 || r === 9) {
        console.log(`r=${r}, c=${c}: [${pt[0].toFixed(3)}, ${pt[1].toFixed(3)}]`);
    }
});

