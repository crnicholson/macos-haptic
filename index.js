const addon = require('./build/Release/macos_haptic.node');
const patterns = ['generic', 'alignment', 'levelChange'];

function perform(pattern = 'generic') {
  if (!patterns.includes(pattern)) throw new Error(`Unknown pattern "${pattern}". Valid patterns: ${patterns.join(', ')}`);
  addon.perform(pattern);
}

function burst(count = 5, pattern = 'generic') {
  if (!patterns.includes(pattern)) throw new Error(`Unknown pattern "${pattern}". Valid patterns: ${patterns.join(', ')}`);
  for (let i = 0; i < count; i++) {
    addon.perform(pattern);
  }
}

function allBurst(count = 5) {
  for (let i = 0; i < count; i++) {
    for (let x = 0; x < patterns.length; x++) {
      addon.perform(patterns[x]);
    }
  }
}

function getPressure() {
  return addon.getPressure();
}

function isFingerPresent() {
  return addon.isFingerPresent();
}

module.exports = { perform, getPressure, burst, allBurst, isFingerPresent, patterns: [...patterns] };
