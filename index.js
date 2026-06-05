const addon = require('./build/Release/macos_haptic.node');
const patterns = ['generic', 'alignment', 'levelChange'];

function perform(pattern = 'generic') {
  if (!patterns.includes(pattern)) throw new Error(`Unknown pattern "${pattern}". Valid patterns: ${patterns.join(', ')}`);
  addon.perform(pattern);
}

module.exports = { perform, patterns: [...patterns] };
