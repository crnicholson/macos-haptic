const addon = require('./build/Release/macos_haptic.node');

const PATTERNS = ['generic', 'alignment', 'levelChange'];

function perform(pattern = 'generic') {
  if (!PATTERNS.includes(pattern)) {
    throw new Error(
      `Unknown pattern "${pattern}". Valid patterns: ${PATTERNS.join(', ')}`
    );
  }
  addon.perform(pattern);
}

module.exports = { perform, patterns: [...PATTERNS] };
