import fs from 'fs';
import path from 'path';
import puppeteer from 'puppeteer';

const root = path.resolve(process.cwd(), '../../..');
const diagramsDir = path.join(root, 'docs', 'diagrams');
const exportsDir = path.join(diagramsDir, 'exports');

async function ensureDir(dir) {
  await fs.promises.mkdir(dir, { recursive: true });
}

async function svgToPng(svgPath, outPath, scale = 2) {
  const svg = await fs.promises.readFile(svgPath, 'utf8');
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  try {
    const page = await browser.newPage();
    // Extract width/height from viewBox or attributes
    const matchViewBox = svg.match(/viewBox="\s*0\s+0\s+(\d+)\s+(\d+)\s*"/i);
    let width = 1920;
    let height = 1080;
    if (matchViewBox) {
      width = parseInt(matchViewBox[1], 10);
      height = parseInt(matchViewBox[2], 10);
    } else {
      const matchWidth = svg.match(/width="(\d+)"/i);
      const matchHeight = svg.match(/height="(\d+)"/i);
      if (matchWidth) width = parseInt(matchWidth[1], 10);
      if (matchHeight) height = parseInt(matchHeight[1], 10);
    }
    await page.setViewport({ width: width * scale, height: height * scale, deviceScaleFactor: 1 });
    const html = `<!doctype html>
    <html>
      <head>
        <meta charset="utf-8"/>
        <style>
          html, body { margin: 0; padding: 0; }
          .container {
            width: ${width}px;
            height: ${height}px;
            transform: scale(${scale});
            transform-origin: top left;
          }
        </style>
      </head>
      <body>
        <div class="container">${svg}</div>
      </body>
    </html>`;
    await page.setContent(html, { waitUntil: 'networkidle0' });
    const clip = { x: 0, y: 0, width: width * scale, height: height * scale };
    await page.screenshot({ path: outPath, clip });
  } finally {
    await browser.close();
  }
}

async function main() {
  await ensureDir(exportsDir);
  const files = [
    'system-architecture-detailed.svg',
    'system-architecture-summary.svg'
  ];
  for (const f of files) {
    const svgPath = path.join(diagramsDir, f);
    const pngPath = path.join(exportsDir, f.replace(/\.svg$/, '.png'));
    console.log(`Exporting ${f} -> ${path.basename(pngPath)}`);
    await svgToPng(svgPath, pngPath, 2); // 2x scale for high-res
  }
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
