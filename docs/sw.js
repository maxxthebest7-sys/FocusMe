// Discipline service worker.
// Bump VERSION whenever docs/ changes so installed apps pick up the update.
const VERSION = '1.1.0';
const CACHE = `discipline-${VERSION}`;
const SHELL = [
  './',
  './index.html',
  './manifest.json',
  './icon-192.png',
  './icon-512.png',
  './apple-touch-icon.png',
];

self.addEventListener('install', (e) => {
  e.waitUntil(
    caches.open(CACHE).then((c) =>
      // Tolerate a missing asset so one 404 can't block install.
      Promise.all(SHELL.map((u) => c.add(u).catch(() => null)))
    )
  );
});

self.addEventListener('activate', (e) => {
  e.waitUntil(
    caches.keys()
      .then((ks) => Promise.all(ks.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

// The page posts this after the user taps "Reload" on the update toast.
self.addEventListener('message', (e) => {
  if (e.data && e.data.type === 'SKIP_WAITING') self.skipWaiting();
});

// Network-first for navigations (so fixes reach users), cache-first for assets.
self.addEventListener('fetch', (e) => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const isNav = req.mode === 'navigate' || req.destination === 'document';

  if (isNav) {
    e.respondWith(
      fetch(req)
        .then((res) => {
          const copy = res.clone();
          caches.open(CACHE).then((c) => c.put('./index.html', copy)).catch(() => {});
          return res;
        })
        .catch(() => caches.match('./index.html').then((r) => r || caches.match('./')))
    );
    return;
  }

  e.respondWith(
    caches.match(req).then((hit) => {
      if (hit) return hit;
      return fetch(req).then((res) => {
        if (res.ok && new URL(req.url).origin === self.location.origin) {
          const copy = res.clone();
          caches.open(CACHE).then((c) => c.put(req, copy)).catch(() => {});
        }
        return res;
      });
    })
  );
});

// Web Push (used if a push backend is added later). Payload: {title, body, tag}
self.addEventListener('push', (e) => {
  let d = { title: 'Discipline', body: 'Time to check in.' };
  try { if (e.data) d = { ...d, ...e.data.json() }; } catch (_) { /* keep defaults */ }
  e.waitUntil(
    self.registration.showNotification(d.title, {
      body: d.body,
      icon: './icon-192.png',
      badge: './icon-192.png',
      tag: d.tag || 'discipline',
      renotify: true,
      data: { url: './' },
    })
  );
});

self.addEventListener('notificationclick', (e) => {
  e.notification.close();
  e.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((ws) => {
      const same = ws.find((w) => new URL(w.url).origin === self.location.origin);
      return same ? same.focus() : clients.openWindow('./');
    })
  );
});
