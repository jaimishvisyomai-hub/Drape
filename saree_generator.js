function generateSampleSaree(type = 'kanjivaram_gold_crimson') {
  const canvas = document.createElement('canvas');
  canvas.width = 1600;
  canvas.height = 3600;
  const ctx = canvas.getContext('2d');

  const W = canvas.width;
  const H = canvas.height;

  let baseColor = '#0f4c3a'; // Emerald
  let zariColor = '#ffd700'; // Gold
  let secondaryColor = '#06261c';

  if (type === 'kanjivaram_gold_crimson') {
    baseColor = '#8c0d27';
    secondaryColor = '#3b030e';
  } else if (type === 'midnight_sapphire') {
    baseColor = '#0d2557';
    secondaryColor = '#05112e';
  } else if (type === 'rani_pink') {
    baseColor = '#b81261';
    secondaryColor = '#5e032d';
  }

  // Body gradient
  const grad = ctx.createLinearGradient(0, 0, W, 0);
  grad.addColorStop(0, secondaryColor);
  grad.addColorStop(0.5, baseColor);
  grad.addColorStop(1, secondaryColor);
  ctx.fillStyle = grad;
  ctx.fillRect(0, 0, W, H);

  // Weave texture lines
  ctx.fillStyle = 'rgba(255,255,255,0.03)';
  for (let y = 0; y < H; y += 4) {
    ctx.fillRect(0, y, W, 1.5);
  }

  // Pallu at the BOTTOM (Y = H * 0.62 to H) like real commercial raw sarees
  const palluStartY = H * 0.62;
  const palluHeight = H - palluStartY;

  const palluGrad = ctx.createLinearGradient(0, palluStartY, 0, H);
  palluGrad.addColorStop(0, '#04241b');
  palluGrad.addColorStop(0.5, '#0b4a3a');
  palluGrad.addColorStop(1, '#04241b');
  ctx.fillStyle = palluGrad;
  ctx.fillRect(0, palluStartY, W, palluHeight);

  // Pallu Zari stripes
  for (let i = 0; i < 12; i++) {
    const y = palluStartY + 40 + i * ((palluHeight - 80) / 12);
    const thick = (i % 3 === 0) ? 20 : 8;
    ctx.fillStyle = zariColor;
    ctx.fillRect(W * 0.08, y, W * 0.84, thick);
  }

  // Peacock/motif in Pallu
  const centerX = W / 2;
  const centerY = palluStartY + palluHeight * 0.65;
  ctx.save();
  ctx.fillStyle = zariColor;
  ctx.beginPath();
  ctx.arc(centerX, centerY, 80, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = '#ff3b30';
  ctx.beginPath();
  ctx.arc(centerX, centerY, 50, 0, Math.PI * 2);
  ctx.fill();
  ctx.restore();

  // Side borders
  function drawBorder(startX, width) {
    ctx.fillStyle = zariColor;
    ctx.fillRect(startX, 0, width, H);
    ctx.fillStyle = 'rgba(0,0,0,0.2)';
    for (let y = 0; y < H; y += 30) {
      ctx.fillRect(startX + width * 0.25, y, width * 0.5, 12);
    }
  }
  drawBorder(0, W * 0.10);
  drawBorder(W * 0.90, W * 0.10);

  // Body Buttas in the top 0..60%
  for (let r = 0; r < 18; r++) {
    const y = 80 + r * (palluStartY - 120) / 18;
    const offset = (r % 2 === 0) ? 0 : 40;
    for (let c = 0; c < 8; c++) {
      const x = W * 0.15 + c * (W * 0.70 / 8) + offset;
      if (x > W * 0.85) continue;
      ctx.fillStyle = zariColor;
      ctx.beginPath();
      ctx.arc(x, y, 7, 0, Math.PI * 2);
      ctx.fill();
    }
  }

  return canvas;
}

window.generateSampleSaree = generateSampleSaree;
