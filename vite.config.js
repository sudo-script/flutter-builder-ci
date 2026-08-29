import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// base: './' — the Capacitor WebView loads the bundle from a local file origin,
// so absolute asset URLs would 404 on device.
export default defineConfig({
  base: './',
  plugins: [react()],
  build: {
    outDir: 'dist',
    sourcemap: false,
    chunkSizeWarningLimit: 1500,
  },
});
