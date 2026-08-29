import { HashRouter, Routes, Route, Navigate } from 'react-router-dom';
import HomeScreen from './screens/HomeScreen.jsx';

/**
 * HashRouter, not BrowserRouter: the Capacitor WebView serves the bundle from
 * a local origin with no server-side rewrite, so a deep path reload would 404.
 */
export default function AppRouter() {
  return (
    <HashRouter>
      <Routes>
        <Route path="/home" element={<HomeScreen />} />
        <Route path="/" element={<Navigate to="/home" replace />} />
        <Route path="*" element={<Navigate to="/home" replace />} />
      </Routes>
    </HashRouter>
  );
}
