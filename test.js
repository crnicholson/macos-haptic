const { perform, patterns } = require('./index.js');

console.log('macOS Haptic Feedback Test');
console.log('Patterns available:', patterns.join(', '));
console.log('');

let i = 0;
function next() {
  if (i >= patterns.length) {
    console.log('\nDone.');
    return;
  }
  const pattern = patterns[i];
  console.log(`Triggering "${pattern}"...`);
  perform(pattern);
  i++;
  setTimeout(next, 500);
}

next();
