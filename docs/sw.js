const CACHE = 'discipline-v1';
const SHELL = ['./', './manifest.json', './icon.svg'];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(SHELL)));
  self.skipWaiting();
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(ks =>
      Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', e => {
  e.respondWith(
    caches.match(e.request).then(r => r || fetch(e.request))
  );
});

self.addEventListener('push', e => {
  const d = e.data ? e.data.json() : { title: 'Discipline', body: 'Time to check in.' };
  e.waitUntil(
    self.registration.showNotification(d.title || 'Discipline', {
      body: d.body || '',
      icon: './icon.svg',
      badge: './icon.svg',
      tag: d.tag || 'discipline',
      renotify: true,
      requireInteraction: false,
      data: { url: './' }
    })
  );
});

self.addEventListener('notificationclick', e => {
  e.notification.close();
  e.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(ws => {
      const open = ws.find(w => w.url.includes('index') || w.url.endsWith('/'));
      return open ? open.focus() : clients.openWindow('./');
    })
  );
});
