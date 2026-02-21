const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 3456;
const TILESETS_DIR = path.resolve(__dirname, '../../assets/tilesets');

const MIME_TYPES = {
    '.html': 'text/html',
    '.js': 'application/javascript',
    '.css': 'text/css',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.json': 'application/json',
};

const server = http.createServer((req, res) => {
    // CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        res.writeHead(200);
        res.end();
        return;
    }

    // POST /save-atlas — save a PNG atlas to the tilesets directory
    if (req.method === 'POST' && req.url === '/save-atlas') {
        let body = '';
        req.on('data', chunk => { body += chunk; });
        req.on('end', () => {
            try {
                const { filename, data } = JSON.parse(body);

                // Validate filename (only allow world_X_atlas.png pattern)
                if (!/^world_\d+_atlas\.png$/.test(filename)) {
                    res.writeHead(400, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ error: 'Invalid filename' }));
                    return;
                }

                const filePath = path.join(TILESETS_DIR, filename);
                const buffer = Buffer.from(data, 'base64');

                fs.writeFileSync(filePath, buffer);
                console.log(`✅ Saved ${filename} (${buffer.length} bytes) to ${filePath}`);

                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ success: true, path: filePath, size: buffer.length }));
            } catch (err) {
                console.error('Save error:', err);
                res.writeHead(500, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ error: err.message }));
            }
        });
        return;
    }

    // Serve static files
    let filePath;
    if (req.url === '/' || req.url === '/index.html') {
        filePath = path.join(__dirname, 'index.html');
    } else if (req.url.startsWith('/assets/tilesets/')) {
        // Serve tileset images from the project assets folder
        filePath = path.join(TILESETS_DIR, req.url.replace('/assets/tilesets/', ''));
    } else {
        filePath = path.join(__dirname, req.url);
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
    console.log(`\n🎮 Tile Selector running at http://localhost:${PORT}`);
    console.log(`📁 Saving atlases to: ${TILESETS_DIR}\n`);
});
