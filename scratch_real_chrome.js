const { spawn } = require('child_process');
const chrome = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';

const args = [
  '--headless=new',
  '--disable-gpu',
  '--enable-webgl',
  '--enable-logging=stderr',
  'http://localhost:3000'
];

console.log('Starting Chrome logging all console output...');
const child = spawn(chrome, args);

child.stderr.on('data', d => {
  const str = d.toString();
  str.split('\n').forEach(line => {
    if (line.includes('CONSOLE') || line.includes('Error') || line.includes('error') || line.includes('Saved') || line.includes('Drape')) {
      console.log('CONSOLE:', line.trim());
    }
  });
});

setTimeout(() => {
  child.kill();
  console.log('Done.');
}, 10000);
