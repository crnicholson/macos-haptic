const { perform, patterns, getPressure, isFingerPresent } = require('./index.js');
console.log('macOS Haptic Feedback Test\nPatterns available:', patterns.join(', '), '\n');

(async () => {
  for (const pattern of patterns) {
    console.log(`Triggering "${pattern}"...`);
    perform(pattern);
    await new Promise(r => setTimeout(r, 500));
  }
  console.log('\nPolling pressure for 15 seconds. Touch the trackpad with a finger if you want to test it.\n');
  const startedAt = Date.now();
  while (Date.now() - startedAt < 15000) {
    console.log({ isFingerPresent: isFingerPresent(), pressure: getPressure() });
    await new Promise(r => setTimeout(r, 250));
  }
  console.log('\nDone.');
})();
