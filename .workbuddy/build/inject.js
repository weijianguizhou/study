const fs = require('fs');
const { execFileSync } = require('child_process');

const BUILD = 'D:/studynotes/.workbuddy/build';
const DB_ID = process.argv[2];
if (!DB_ID) { console.error('用法: node inject.js <databaseId>'); process.exit(1); }

const tpl = fs.readFileSync(BUILD + '/template.html', 'utf8');
const plan = fs.readFileSync(BUILD + '/plan.json', 'utf8');

// 压缩 plan：去掉多余空白，保持可读性够用即可
const planMin = JSON.stringify(JSON.parse(plan));

let out = tpl
  .split('/*__PLAN_JSON__*/').join(planMin)
  .split('/*__DB_ID__*/').join(DB_ID);

if (out.indexOf('__PLAN_JSON__') !== -1 || out.indexOf('__DB_ID__') !== -1) {
  console.error('占位符未完全替换！'); process.exit(1);
}
if (out.indexOf('databaseId: DATABASE_ID') === -1) {
  console.error('未找到 SDK 调用'); process.exit(1);
}

fs.writeFileSync(BUILD + '/output.html', out, 'utf8');

// ---- 语法自检：抽出 <script> 内容跑 node --check ----
const m = out.match(/<script>([\s\S]*?)<\/script>/);
if (!m) { console.error('未找到 script 块'); process.exit(1); }
const jsPath = BUILD + '/_check.js';
fs.writeFileSync(jsPath, m[1], 'utf8');
try {
  execFileSync('C:/Users/john/.workbuddy/binaries/node/versions/22.22.2-2/node.exe', ['--check', jsPath], { stdio: 'pipe' });
  console.log('[OK] JS 语法检查通过');
} catch (e) {
  console.error('[FAIL] JS 语法错误:\n' + e.stderr.toString());
  process.exit(1);
}

// ---- 静态自检清单 ----
const checks = [];
function chk(name, cond) { checks.push([name, !!cond]); }

chk('无外部 http(s) 资源引用', !/<(script|link)[^>]+(src|href)=["']https?:/i.test(out));
chk('无外部图片', !/<img[^>]+src=["']https?:/i.test(out));
chk('无 CDN / 字体外链', !/cdn\.|googleapis|unpkg|jsdelivr|cdnjs/i.test(out));
chk('databaseId 硬编码自 DATABASE_ID 变量', /var DATABASE_ID = '/.test(out) && /databaseId: DATABASE_ID/.test(out));
chk('loadAll 分页用 startCursor', /startCursor/.test(out) && /hasMore/.test(out));
chk('onUpdated 带能力探测', /typeof db\.onUpdated === 'function'/.test(out));
chk('统一刷新入口 refreshAll 存在', /function refreshAll\(\)/.test(out));
chk('localStorage 键带前缀', /wb_cetplan_v1/.test(out));
chk('有导出 JSON', /function exportJSON/.test(out));
chk('有导入 JSON', /function importJSON/.test(out));
chk('清空需输入「清空」', /v\.trim\(\) !== '清空'/.test(out));
chk('输入框字号 >= 16px', /input\[type=date\],input\[type=text\]\{[^}]*font-size:16px/.test(out));
chk('按钮最小高度 44px', /min-height:44px/.test(out));
chk('安全区适配', /safe-area-inset-bottom/.test(out));
chk('内联 SVG 图标（无 emoji）', !/[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]/u.test(out));

// 渲染函数之间不得互调（铁律 9）
const renderFns = ['renderTopbar', 'renderToday', 'renderPlan', 'renderMine'];
let cyc = false;
renderFns.forEach(fn => {
  const body = out.slice(out.indexOf('function ' + fn + '('));
  const end = body.indexOf('\nfunction ');
  const seg = end > 0 ? body.slice(0, end) : body.slice(0, 3000);
  renderFns.filter(o => o !== fn).forEach(o => {
    if (new RegExp('\\b' + o + '\\s*\\(').test(seg)) { cyc = true; console.error('  ! ' + fn + ' 内调用了 ' + o); }
  });
});
chk('渲染函数之间无互调', !cyc);

// ---- DOM 引用存在性：所有 $('id') 必须在 HTML 中存在（动态生成的除外） ----
const DYNAMIC = new Set(['clearInput', 'mActions']);
const ids = new Set();
let mm;
const re = /\$\('([A-Za-z0-9_]+)'\)/g;
while ((mm = re.exec(out)) !== null) ids.add(mm[1]);
const missing = [...ids].filter(id => {
  if (DYNAMIC.has(id)) return false;
  return !new RegExp('id="' + id + '"').test(out);
});
chk('DOM 引用全部存在（' + ids.size + ' 个）', missing.length === 0);
if (missing.length) console.error('  ! 缺失 id: ' + missing.join(', '));

let bad = 0;
console.log('\n--- 冒烟自检 ---');
checks.forEach(([n, ok]) => { console.log((ok ? '  [OK]   ' : '  [FAIL] ') + n); if (!ok) bad++; });
console.log('\n输出: ' + BUILD + '/output.html  (' + (out.length / 1024).toFixed(1) + ' KB)');
process.exit(bad ? 1 : 0);
