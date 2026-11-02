const http = require('http');
const fs = require('fs');
const path = require('path');

let PORT = parseInt(process.env.PORT, 10) || 3000;
const MIME_TYPES = {
  '.html': 'text/html',
  '.css': 'text/css',
  '.js': 'text/javascript',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon'
};

const server = http.createServer((req, res) => {
  // Handle file upload and automatic cropping
  if (req.method === 'POST' && req.url.startsWith('/api/upload')) {
    let body = [];
    req.on('data', chunk => body.push(chunk));
    req.on('end', () => {
      try {
        const buffer = Buffer.concat(body);
        const cropsDir = path.join(__dirname, 'crops');
        if (!fs.existsSync(cropsDir)) {
          fs.mkdirSync(cropsDir, { recursive: true });
        }

        const rawPath = path.join(cropsDir, 'raw_uploaded_saree.jpg');
        fs.writeFileSync(rawPath, buffer);
        console.log(`[Upload] Saved raw uploaded saree to ${rawPath} (${(buffer.length / 1024).toFixed(1)} KB)`);

        // Automatically execute generate_crops.ps1 to produce meaningful cropped sections
        const psScript = path.join(cropsDir, 'generate_crops.ps1');
        if (fs.existsSync(psScript)) {
          const { spawn } = require('child_process');
          const child = spawn('powershell.exe', ['-ExecutionPolicy', 'Bypass', '-File', psScript], {
            cwd: __dirname
          });
          child.on('close', code => {
            console.log(`[Crops] generate_crops.ps1 completed with code ${code}`);
          });
        }

        res.writeHead(200, {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        });
        res.end(JSON.stringify({ success: true, path: 'crops/raw_uploaded_saree.jpg', bytes: buffer.length }));
      } catch (err) {
        console.error('[Upload Error]', err);
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: err.message }));
      }
    });
    return;
  }

  // Handle saving rendered drape snapshot for visual comparison
  if (req.method === 'POST' && req.url.startsWith('/api/save-render')) {
    let body = [];
    req.on('data', chunk => body.push(chunk));
    req.on('end', () => {
      try {
        const payload = JSON.parse(Buffer.concat(body).toString('utf8'));
        const base64Data = payload.image.replace(/^data:image\/\w+;base64,/, '');
        const filename = payload.filename || 'hybrid_draped_result.png';
        const cropsDir = path.join(__dirname, 'crops');
        if (!fs.existsSync(cropsDir)) fs.mkdirSync(cropsDir, { recursive: true });
        const outPath = path.join(cropsDir, filename);
        fs.writeFileSync(outPath, Buffer.from(base64Data, 'base64'));
        console.log(`[Render Export] Saved rendered output to ${outPath}`);
        res.writeHead(200, { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' });
        res.end(JSON.stringify({ success: true, path: `crops/${filename}` }));
      } catch (err) {
        console.error('[Render Export Error]', err);
        res.writeHead(500, { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' });
        res.end(JSON.stringify({ error: err.message }));
      }
    });
    return;
  }

  // Handle mapping calibration save with automated backup
  if (req.method === 'POST' && req.url.startsWith('/api/save-mapping')) {
    let body = [];
    req.on('data', chunk => body.push(chunk));
    req.on('end', () => {
      try {
        const payload = JSON.parse(Buffer.concat(body).toString('utf8'));
        const mappingPath = path.join(__dirname, 'drape-lab', 'mapping.json');
        
        // 1. Create timestamped backup of existing mapping before saving
        if (fs.existsSync(mappingPath)) {
          const backupDir = path.join(__dirname, 'drape-lab', 'backups');
          if (!fs.existsSync(backupDir)) fs.mkdirSync(backupDir, { recursive: true });
          const backupPath = path.join(backupDir, `mapping_backup_${Date.now()}.json`);
          fs.copyFileSync(mappingPath, backupPath);
          console.log(`[Calibration] Backup preserved at ${backupPath}`);
        }

        // 2. Save new mapping
        fs.writeFileSync(mappingPath, JSON.stringify(payload, null, 2), 'utf8');
        console.log(`[Calibration] Successfully saved updated mapping.json (${Object.keys(payload).length} layers)`);

        res.writeHead(200, {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        });
        res.end(JSON.stringify({ success: true, message: 'Mapping calibration saved with backup.' }));
      } catch (err) {
        console.error('[Save Mapping Error]', err);
        res.writeHead(500, { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' });
        res.end(JSON.stringify({ error: err.message }));
      }
    });
    return;
  }

  // Template management endpoints
  if (req.method === 'GET' && req.url.startsWith('/api/templates')) {
    try {
      const tDir = path.join(__dirname, 'drape-lab', 'templates');
      if (!fs.existsSync(tDir)) fs.mkdirSync(tDir, { recursive: true });
      const files = fs.readdirSync(tDir).filter(f => f.endsWith('.json'));
      const list = files.map(f => {
        try {
          const content = JSON.parse(fs.readFileSync(path.join(tDir, f), 'utf8'));
          return { id: content.id || f.replace('.json',''), name: content.name || f, file: f, version: content.version || '1.0' };
        } catch(e) {
          return { id: f.replace('.json',''), name: f, file: f, version: '1.0' };
        }
      });
      res.writeHead(200, { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' });
      res.end(JSON.stringify({ success: true, templates: list }));
    } catch (e) {
      res.writeHead(500, { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' });
      res.end(JSON.stringify({ error: e.message }));
    }
    return;
  }

  if (req.method === 'POST' && req.url.startsWith('/api/templates/save')) {
    let body = [];
    req.on('data', chunk => body.push(chunk));
    req.on('end', () => {
      try {
        const payload = JSON.parse(Buffer.concat(body).toString('utf8'));
        const tDir = path.join(__dirname, 'drape-lab', 'templates');
        if (!fs.existsSync(tDir)) fs.mkdirSync(tDir, { recursive: true });
        const safeName = (payload.id || 'template_' + Date.now()).replace(/[^a-zA-Z0-9_-]/g, '_');
        const tPath = path.join(tDir, `${safeName}.json`);
        fs.writeFileSync(tPath, JSON.stringify(payload, null, 2), 'utf8');
        console.log(`[Template] Saved drape template: ${safeName}.json`);
        res.writeHead(200, { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' });
        res.end(JSON.stringify({ success: true, file: `${safeName}.json`, id: safeName }));
      } catch(err) {
        res.writeHead(500, { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' });
        res.end(JSON.stringify({ error: err.message }));
      }
    });
    return;
  }

  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type'
    });
    res.end();
    return;
  }

  let reqUrl = decodeURI(req.url.split('?')[0]);
  if (reqUrl === '/') reqUrl = '/index.html';
  
  const filePath = path.join(__dirname, reqUrl);
  
  if (!filePath.startsWith(__dirname)) {
    res.writeHead(403);
    res.end('Access Denied');
    return;
  }

  fs.stat(filePath, (err, stats) => {
    if (err || !stats.isFile()) {
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('File Not Found');
      return;
    }

    const ext = path.extname(filePath).toLowerCase();
    const contentType = MIME_TYPES[ext] || 'application/octet-stream';
    res.writeHead(200, {
      'Content-Type': contentType,
      'Access-Control-Allow-Origin': '*',
      'Cache-Control': 'no-store, no-cache, must-revalidate, proxy-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0'
    });
    fs.createReadStream(filePath).pipe(res);
  });
});

function startServer(port) {
  server.listen(port, () => {
    console.log(`\n======================================================`);
    console.log(`Saree Visualizer Dev Server running at:`);
    console.log(`👉 http://localhost:${port}`);
    console.log(`======================================================\n`);
  });
}

server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.log(`Port ${PORT} is busy, trying port ${PORT + 1}...`);
    PORT++;
    startServer(PORT);
  } else {
    console.error('Server error:', err);
  }
});

startServer(PORT);
