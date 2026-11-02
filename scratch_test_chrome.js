const { spawn } = require('child_process');
const chrome = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';

const args = [
  '--headless=new',
  '--use-gl=swiftshader',
  '--disable-gpu-sandbox',
  '--no-sandbox',
  '--screenshot=crops/test_chrome_screen.png',
  'http://localhost:3000'
];

console.log('Launching chrome with swiftshader...');
const child = spawn(chrome, args);

child.stdout.on('data', d => console.log('stdout:', d.toString()));
child.stderr.on('data', d => console.log('stderr:', d.toString()));

setTimeout(() => {
  child.kill();
  console.log('Done.');
}, 9000);
