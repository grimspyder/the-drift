const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 3456;
const TILESETS_DIR = path.resolve(__dirname, '../../assets/tilesets');
const MAPS_DIR = path.resolve(__dirname, '../../assets/maps');

// Ensure maps directory exists
if (!fs.existsSync(MAPS_DIR)) {
    fs.mkdirSync(MAPS_DIR, { recursive: true });
    console.log('Created maps directory:', MAPS_DIR);
}

const MIME_TYPES = {
    '.html': 'text/html',
    '.js': 'application/javascript',
    '.css': 'text/css',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.json': 'application/json',
};

function readBody(req) {
    return new Promise((resolve, reject) => {
        let body = '';
        req.on('data', chunk => { body += chunk; });
        req.on('end', () => resolve(body));
        req.on('error', reject);
    });
}

const server = http.createServer(async (req, res) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        res.writeHead(200);
        res.end();
        return;
    }

    // --- API: Save Atlas PNG ---
    if (req.method === 'POST' && req.url === '/save-atlas') {
        try {
            const body = await readBody(req);
            const { filename, data } = JSON.parse(body);
            if (!/^world_\d+_atlas\.png$/.test(filename)) {
                res.writeHead(400, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ error: 'Invalid filename' }));
                return;
            }
            const filePath = path.join(TILESETS_DIR, filename);
            const buffer = Buffer.from(data, 'base64');
            fs.writeFileSync(filePath, buffer);
            console.log(`✅ Saved atlas: ${filename} (${buffer.length} bytes)`);
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ success: true, path: filePath, size: buffer.length }));
        } catch (err) {
            console.error('Save atlas error:', err);
            res.writeHead(500, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ error: err.message }));
        }
        return;
    }

    // --- API: Save Map JSON ---
    if (req.method === 'POST' && req.url === '/save-map') {
        try {
            const body = await readBody(req);
            const mapData = JSON.parse(body);
            const filename = mapData.filename || `world_${mapData.world_id}_level_1.json`;
            if (!/^[\w\-]+\.json$/.test(filename)) {
                res.writeHead(400, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ error: 'Invalid filename' }));
                return;
            }
            const filePath = path.join(MAPS_DIR, filename);
            fs.writeFileSync(filePath, JSON.stringify(mapData, null, 2));
            console.log(`✅ Saved map: ${filename}`);
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ success: true, path: filePath }));
        } catch (err) {
            console.error('Save map error:', err);
            res.writeHead(500, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ error: err.message }));
        }
        return;
    }

    // --- API: List Maps ---
    if (req.method === 'GET' && req.url === '/list-maps') {
        try {
            const files = fs.readdirSync(MAPS_DIR).filter(f => f.endsWith('.json'));
            const maps = files.map(f => {
                const data = JSON.parse(fs.readFileSync(path.join(MAPS_DIR, f), 'utf8'));
                return { filename: f, name: data.name || f, world_id: data.world_id, width: data.width, height: data.height };
            });
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify(maps));
        } catch (err) {
            res.writeHead(500, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ error: err.message }));
        }
        return;
    }

    // --- API: Load Map ---
    if (req.method === 'GET' && req.url.startsWith('/load-map?')) {
        try {
            const url = new URL(req.url, `http://localhost:${PORT}`);
            const file = url.searchParams.get('file');
            if (!file || !/^[\w\-]+\.json$/.test(file)) {
                res.writeHead(400, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ error: 'Invalid filename' }));
                return;
            }
            const filePath = path.join(MAPS_DIR, file);
            if (!fs.existsSync(filePath)) {
                res.writeHead(404, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ error: 'Map not found' }));
                return;
            }
            const data = fs.readFileSync(filePath, 'utf8');
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(data);
        } catch (err) {
            res.writeHead(500, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ error: err.message }));
        }
        return;
    }

    // --- Static file serving ---
    const parsedUrl = new URL(req.url, `http://localhost:${PORT}`);
    const urlPath = decodeURIComponent(parsedUrl.pathname);

    let filePath;
    if (urlPath === '/' || urlPath === '/index.html') {
        filePath = path.join(__dirname, 'index.html');
    } else if (urlPath.startsWith('/assets/tilesets/')) {
        filePath = path.join(TILESETS_DIR, urlPath.replace('/assets/tilesets/', ''));
    } else {
        filePath = path.join(__dirname, urlPath);
    }

    const ext = path.extname(filePath).toLowerCase();
    const contentType = MIME_TYPES[ext] || 'application/octet-stream';

    fs.readFile(filePath, (err, data) => {
        if (err) {
            res.writeHead(404);
            res.end('Not found: ' + req.url);
            return;
        }
        res.writeHead(200, { 'Content-Type': contentType });
        res.end(data);
    });
});

server.listen(PORT, () => {
    console.log(`\n🎮 The Drift Map Editor running at http://localhost:${PORT}`);
    console.log(`📁 Tilesets: ${TILESETS_DIR}`);
    console.log(`🗺️  Maps: ${MAPS_DIR}\n`);
});
