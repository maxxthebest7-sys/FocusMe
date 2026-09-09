// Generates PNG app icons (black rounded square, white "D") with no deps.
const zlib = require('zlib');
const fs = require('fs');

function crc32(buf) {
  let c, crc = 0xffffffff;
  for (let n = 0; n < buf.length; n++) {
    c = (crc ^ buf[n]) & 0xff;
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    crc = (crc >>> 8) ^ c;
  }
  return (crc ^ 0xffffffff) >>> 0;
}
function chunk(type, data) {
  const len = Buffer.alloc(4); len.writeUInt32BE(data.length);
  const td = Buffer.concat([Buffer.from(type), data]);
  const crc = Buffer.alloc(4); crc.writeUInt32BE(crc32(td));
  return Buffer.concat([len, td, crc]);
}

// Signed-distance style coverage for the glyph, evaluated with supersampling.
function inRoundedRect(x, y, s, r) {
  const dx = Math.max(Math.abs(x - s / 2) - (s / 2 - r), 0);
  const dy = Math.max(Math.abs(y - s / 2) - (s / 2 - r), 0);
  return dx * dx + dy * dy <= r * r;
}
// "D": stem + half-disc, minus inner half-disc/rect cutout. Coordinates in unit space.
function inD(u, v) {
  // outer shape: x in [0.30,0.72], y in [0.28,0.72]; right side rounded
  const left = 0.31, top = 0.29, bottom = 0.71, midY = 0.5;
  const stroke = 0.11;
  const rOuter = (bottom - top) / 2;               // 0.21
  const cx = left + 0.20;                          // arc center x
  if (v < top || v > bottom) return false;
  // outer D
  let outer;
  if (u < cx) outer = u >= left;
  else outer = (u - cx) ** 2 + (v - midY) ** 2 <= rOuter ** 2;
  if (!outer) return false;
  // inner cutout
  const rInner = rOuter - stroke;
  const il = left + stroke;
  let inner;
  if (v < top + stroke || v > bottom - stroke) inner = false;
  else if (u < cx) inner = u >= il;
  else inner = (u - cx) ** 2 + (v - midY) ** 2 <= rInner ** 2;
  return !inner;
}

function render(size, { maskable = false } = {}) {
  const raw = Buffer.alloc((size * 4 + 1) * size);
  const ss = 4; // supersample
  const radius = maskable ? 0 : size * 0.22;
  for (let y = 0; y < size; y++) {
    raw[y * (size * 4 + 1)] = 0; // filter none
    for (let x = 0; x < size; x++) {
      let bg = 0, fg = 0;
      for (let sy = 0; sy < ss; sy++) for (let sx = 0; sx < ss; sx++) {
        const px = x + (sx + 0.5) / ss, py = y + (sy + 0.5) / ss;
        const inBg = maskable ? true : inRoundedRect(px, py, size, radius);
        if (inBg) { bg++; if (inD(px / size, py / size)) fg++; }
      }
      const a = bg / (ss * ss);
      const white = fg / (ss * ss);
      // premultiplied compositing: bg is #111, glyph is #fff
      const base = 0x11;
      const val = Math.round(base * (1 - white / Math.max(a, 1e-9)) + 255 * (white / Math.max(a, 1e-9)));
      const o = y * (size * 4 + 1) + 1 + x * 4;
      raw[o] = raw[o + 1] = raw[o + 2] = a > 0 ? val : 0;
      raw[o + 3] = Math.round(a * 255);
    }
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(size, 0); ihdr.writeUInt32BE(size, 4);
  ihdr[8] = 8; ihdr[9] = 6; ihdr[10] = 0; ihdr[11] = 0; ihdr[12] = 0;
  return Buffer.concat([
    Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
    chunk('IHDR', ihdr),
    chunk('IDAT', zlib.deflateSync(raw, { level: 9 })),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

const out = process.argv[2];
fs.mkdirSync(out, { recursive: true });
// apple-touch-icon must be opaque & square (iOS adds its own corner mask)
fs.writeFileSync(`${out}/apple-touch-icon.png`, render(180, { maskable: true }));
fs.writeFileSync(`${out}/icon-192.png`, render(192, { maskable: true }));
fs.writeFileSync(`${out}/icon-512.png`, render(512, { maskable: true }));
for (const f of fs.readdirSync(out)) if (f.endsWith('.png')) console.log(f, fs.statSync(`${out}/${f}`).size, 'bytes');
