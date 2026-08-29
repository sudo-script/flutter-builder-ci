#!/usr/bin/env node
/**
 * Applies Glassbox project settings to the Capacitor-generated android/ tree.
 * Safe to run more than once.
 */
import fs from 'node:fs';
import path from 'node:path';

const ROOT = process.cwd();
const ANDROID = path.join(ROOT, 'android');
const RES = path.join(ANDROID, 'app', 'src', 'main', 'res');
const STAGED = path.join(ROOT, 'android-resources');

if (!fs.existsSync(ANDROID)) {
  console.error('android/ not found — run "npx cap add android" first.');
  process.exit(1);
}

function copyDir(from, to) {
  if (!fs.existsSync(from)) return 0;
  fs.mkdirSync(to, { recursive: true });
  let count = 0;
  for (const entry of fs.readdirSync(from, { withFileTypes: true })) {
    const src = path.join(from, entry.name);
    const dest = path.join(to, entry.name);
    if (entry.isDirectory()) count += copyDir(src, dest);
    else if (entry.name !== '.gitkeep') { fs.copyFileSync(src, dest); count++; }
  }
  return count;
}

// Launcher icons + adaptive icon background colour.
let copied = 0;
if (fs.existsSync(STAGED)) {
  for (const entry of fs.readdirSync(STAGED, { withFileTypes: true })) {
    if (!entry.isDirectory()) continue;
    copied += copyDir(path.join(STAGED, entry.name), path.join(RES, entry.name));
  }
}
console.log(`[apply-android-resources] copied ${copied} resource file(s)`);

// App label — cap add writes capacitor.config's appName, but a rename between
// builds would otherwise stick to the first value.
const stringsPath = path.join(RES, 'values', 'strings.xml');
if (fs.existsSync(stringsPath)) {
  const appName = "calc";
  const escaped = appName.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/'/g, "\\'");
  let xml = fs.readFileSync(stringsPath, 'utf8');
  xml = xml
    .replace(/(<string name="app_name">)[\s\S]*?(<\/string>)/, `$1${escaped}$2`)
    .replace(/(<string name="title_activity_main">)[\s\S]*?(<\/string>)/, `$1${escaped}$2`);
  fs.writeFileSync(stringsPath, xml);
  console.log('[apply-android-resources] app_name =', appName);
}

// versionCode / versionName.
const gradlePath = path.join(ANDROID, 'app', 'build.gradle');
if (fs.existsSync(gradlePath)) {
  let gradle = fs.readFileSync(gradlePath, 'utf8');
  gradle = gradle
    .replace(/versionCode\s+\d+/, 'versionCode 10000')
    .replace(/versionName\s+"[^"]*"/, 'versionName "1.0.0"');
  fs.writeFileSync(gradlePath, gradle);
  console.log('[apply-android-resources] version = 1.0.0 (10000)');
}
