# macos-haptic

Native Node.js addon for macOS trackpad haptic feedback (Taptic Engine). Also exposes trackpad pressure and finger presence data via the MultitouchSupport private framework.

## Requirements

- macOS 10.11+
- Node.js >= 18
- Xcode Command Line Tools (`xcode-select --install`)

## Install

```sh
npm install macos-haptic
```

The native addon compiles on `npm install` via `node-gyp`.

## API

### `perform(pattern?)`

Triggers a single haptic feedback tap.

```js
const { perform } = require('macos-haptic');
perform('generic');
```

**`pattern`** `<string>` — One of: `'generic'` (default), `'alignment'`, `'levelChange'`.

### `burst(count?, pattern?)`

Triggers `count` rapid haptic taps of the same pattern.

```js
const { burst } = require('macos-haptic');
burst(3, 'alignment');
```

**`count`** `<number>` — Number of taps. Default: `5`.

### `allBurst(count?)`

Cycles through all patterns `count` times.

```js
const { allBurst } = require('macos-haptic');
allBurst(2);
```

### `getPressure()`

Returns the current trackpad pressure as a float (0.0 – ~1.0). Requires a compatible Force Touch trackpad.

```js
const { getPressure } = require('macos-haptic');
console.log(getPressure());
```

### `isFingerPresent()`

Returns `true` if a finger is currently detected on the trackpad.

```js
const { isFingerPresent } = require('macos-haptic');
console.log(isFingerPresent());
```

### `patterns`

Array of valid pattern names: `['generic', 'alignment', 'levelChange']`.

## Credit

Massive shoutout to Kyome22's [OpenMultitouchSupport](https://github.com/Kyome22/OpenMultitouchSupport), whose code was instrumental in the detection of finger presence. 

## License

MIT
