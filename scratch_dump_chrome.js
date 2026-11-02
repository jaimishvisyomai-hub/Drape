const { spawn } = require('child_process');
const fs = require('fs');
const chrome = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';

const args = [
  '--headless=new',
  '--disable-gpu',
  '--enable-webgl',
  '--enable-logging=stderr',
  'http://localhost:3000'
];

const outStream = fs.createWriteStream('scratch_chrome_full_log.txt');
const child = spawn(chrome, args);

child.stderr.pipe(outStream);
child.stdout.pipe(outStream);

setTimeout(() => {
  child.kill();
  console.log('Finished capturing with 20s timeout.');
  const st = fs.statSync('crops/hybrid_draped_result.png');
  console.log('hybrid_draped_result.png updated:', st.mtime.toLocaleTimeString(), st.size);
}, 20000);
