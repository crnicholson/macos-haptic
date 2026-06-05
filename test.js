const { perform, patterns, allBurst, getPressure, isFingerPresent } = require('./index.js');

console.log('macOS Haptic Feedback Test\nPatterns available:', patterns.join(', '), '\n');

(async () => {
  for (const pattern of patterns) {
    console.log(`Triggering "${pattern}"...`);
    perform(pattern);
    await new Promise(r => setTimeout(r, 500));
  }

  console.log('\nPolling pressure for 5 seconds while triggering a burst of all patterns. Touch the trackpad with a finger if you want to test it.\n');

  const startedAt = Date.now();

  while (Date.now() - startedAt < 5000) {
    allBurst();
    console.log("Finger Present: " + isFingerPresent() + ", Pressure: " + getPressure());
    await new Promise(r => setTimeout(r, 100));
  }

  console.log('\nTesting burst of all patterns with a gradual decrease in time between bursts.\n');

  function down(i) {
    return new Promise(resolve => {
      function step(val) {
        if (val < 0) { resolve(); return; }
        allBurst();
        console.log(`Bursting all patterns with ${val}ms delay...`);
        setTimeout(() => step(val - 100), val);
      }
      step(i);
    });
  }

  await down(1000);

  console.log('\nDone.');
})();
