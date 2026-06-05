const { perform, patterns } = require('./index.js');
console.log('macOS Haptic Feedback Test\nPatterns available:', patterns.join(', '), '\n');

(async () => {
  for (const pattern of patterns) {
    console.log(`Triggering "${pattern}"...`);
    perform(pattern);
    await new Promise(r => setTimeout(r, 500));
  }
  console.log('\nDone.');
})();
