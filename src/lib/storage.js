const listeners = new Map();

function notify(key) {
  const set = listeners.get(key);
  if (!set) return;
  for (const fn of set) {
    try { fn(); } catch (err) { console.error('[storage]', err); }
  }
}

// A write in another tab (or a native bridge restore) still has to reach
// mounted components.
if (typeof window !== 'undefined') {
  window.addEventListener('storage', (e) => {
    if (e.key) notify(e.key);
  });
}

export function readRaw(key) {
  try { return window.localStorage.getItem(key); } catch { return null; }
}

export function writeRaw(key, value) {
  try {
    if (value === null || value === undefined) window.localStorage.removeItem(key);
    else window.localStorage.setItem(key, value);
  } catch (err) {
    console.warn('[storage] write failed', err);
  }
  notify(key);
}

export function readJson(key, fallback = null) {
  const raw = readRaw(key);
  if (raw === null) return fallback;
  try { return JSON.parse(raw); } catch { return fallback; }
}

export function writeJson(key, value) {
  writeRaw(key, JSON.stringify(value));
  return value;
}

export function readNumber(key, fallback = 0) {
  const n = Number(readRaw(key));
  return Number.isFinite(n) ? n : fallback;
}

export function writeNumber(key, value) {
  writeRaw(key, String(value));
  return value;
}

export function readBool(key, fallback = false) {
  const raw = readRaw(key);
  if (raw === null) return fallback;
  return raw === 'true' || raw === '1';
}

export function writeBool(key, value) {
  writeRaw(key, value ? 'true' : 'false');
  return value;
}

export function removeKey(key) {
  writeRaw(key, null);
}

/** @returns {() => void} unsubscribe */
export function subscribeKey(key, listener) {
  if (!listeners.has(key)) listeners.set(key, new Set());
  listeners.get(key).add(listener);
  return () => listeners.get(key)?.delete(listener);
}
