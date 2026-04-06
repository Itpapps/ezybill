/**
 * EzyBill CORS Proxy - Supports both Flutter Web and HTML Test Console
 *
 * Mode 1 (Path-based): Flutter Web uses http://localhost:3199 as base URL.
 *   All requests to /v2_release/... are forwarded to the API server.
 *   Example: POST http://localhost:3199/v2_release/index.php/LcoRestServices/validateLogin
 *
 * Mode 2 (Query-param): HTML test page uses ?url=<target>.
 *   Example: POST http://localhost:3199/proxy?url=http://183.83.216.66:8882/...
 *
 * Usage: node cors_proxy.js
 */

const http = require('http');
const https = require('https');
const url = require('url');

const PORT = 3199;
const API_HOST = '192.168.1.143';
const API_PORT = 80;

function addCorsHeaders(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, SOAPAction');
}

function proxyRequest(req, res, targetHostname, targetPort, targetPath, isHttps) {
  const lib = isHttps ? https : http;

  let body = '';
  req.on('data', chunk => { body += chunk; });
  req.on('end', () => {
    const headers = { ...req.headers, host: `${targetHostname}:${targetPort}` };
    delete headers['origin'];
    delete headers['referer'];
    // Remove accept-encoding so target server sends uncompressed data.
    // The proxy reads response as string, so compressed data would corrupt it
    // and cause ERR_CONTENT_DECODING_FAILED in the browser.
    delete headers['accept-encoding'];

    const options = {
      hostname: targetHostname,
      port: targetPort,
      path: targetPath,
      method: req.method,
      headers,
    };

    const proxyReq = lib.request(options, (proxyRes) => {
      let responseData = '';
      proxyRes.on('data', chunk => { responseData += chunk; });
      proxyRes.on('end', () => {
        const responseHeaders = {
          ...proxyRes.headers,
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        };
        // Remove encoding/length headers — proxy reads as string which
        // decompresses the data; keeping these causes ERR_CONTENT_DECODING_FAILED
        delete responseHeaders['content-encoding'];
        delete responseHeaders['content-length'];
        delete responseHeaders['transfer-encoding'];
        res.writeHead(proxyRes.statusCode, responseHeaders);
        res.end(responseData);

        console.log(`[${new Date().toLocaleTimeString()}] ${req.method} ${targetPath} -> ${proxyRes.statusCode}`);
      });
    });

    let responded = false;

    proxyReq.on('error', (err) => {
      console.error(`[ERROR] ${targetPath}: ${err.message}`);
      if (!responded) {
        responded = true;
        res.writeHead(502, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: `Proxy error: ${err.message}` }));
      }
    });

    proxyReq.setTimeout(60000, () => {
      proxyReq.destroy();
      if (!responded) {
        responded = true;
        res.writeHead(504, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Request timeout (60s)' }));
      }
    });

    if (body) proxyReq.write(body);
    proxyReq.end();
  });
}

const server = http.createServer((req, res) => {
  addCorsHeaders(res);

  // Handle preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  const parsed = url.parse(req.url, true);

  // Mode 2: Query-param proxy (?url=...) - for HTML test console
  if (parsed.pathname === '/proxy' && parsed.query.url) {
    const target = url.parse(parsed.query.url);
    const isHttps = target.protocol === 'https:';
    proxyRequest(req, res, target.hostname, target.port || (isHttps ? 443 : 80), target.path, isHttps);
    return;
  }

  // Mode 1: Path-based proxy - for Flutter Web
  // Forward any path starting with /v2_release to the API server (supports v2_release and v2_release_aakshya)
  if (parsed.pathname.startsWith('/v2_release')) {
    proxyRequest(req, res, API_HOST, API_PORT, parsed.path, false);
    return;
  }

  // Health check
  if (parsed.pathname === '/' || parsed.pathname === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      status: 'running',
      api_target: `${API_HOST}:${API_PORT}`,
      modes: {
        flutter_web: `POST http://localhost:${PORT}/v2_release/index.php/LcoRestServices/...`,
        html_test: `POST http://localhost:${PORT}/proxy?url=http://${API_HOST}:${API_PORT}/...`,
      }
    }));
    return;
  }

  res.writeHead(404, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ error: 'Unknown path. Use /v2_release/... or /proxy?url=...' }));
});

server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(`\n  Port ${PORT} is already in use.`);
    console.log(`  The proxy may already be running. Try:`);
    console.log(`    Windows: netstat -ano | findstr ${PORT}  then  taskkill /PID <pid> /F`);
    console.log(`    Linux:   lsof -i :${PORT}  then  kill <pid>\n`);
    process.exit(1);
  }
  throw err;
});

server.listen(PORT, () => {
  console.log(`\n  EzyBill CORS Proxy running on http://localhost:${PORT}`);
  console.log(`  ─────────────────────────────────────────────────`);
  console.log(`  Flutter Web:  Use http://localhost:${PORT} as base URL`);
  console.log(`  HTML Test:    Use /proxy?url=<target> mode`);
  console.log(`  API Target:   http://${API_HOST}:${API_PORT}\n`);
});
