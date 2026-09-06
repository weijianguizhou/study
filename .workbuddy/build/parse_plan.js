// 解析《六级550备考计划》三份每日任务表 md → plan.json
const fs = require('fs');
const path = require('path');

const SRC = 'D:/studynotes/英语/六级550备考计划';
const FILES = [
  { f: '02-每日任务表·基础期.md', stage: '基础期' },
  { f: '03-每日任务表·强化期.md', stage: '强化期' },
  { f: '04-每日任务表·冲刺期.md', stage: '冲刺期' },
];

function pad(n) { return n < 10 ? '0' + n : '' + n; }

// "9月1日" / "10月12日" → "2026-09-01"
function parseDate(s) {
  const m = s.match(/(\d{1,2})月(\d{1,2})日/);
  if (!m) return null;
  return '2026-' + pad(+m[1]) + '-' + pad(+m[2]);
}

const weeks = [];
for (const { f, stage } of FILES) {
  const raw = fs.readFileSync(path.join(SRC, f), 'utf8');
  const lines = raw.split(/\r?\n/);

  let curWeek = null;
  let curDay = null;
  let template = [];      // 阶段固定模板
  let inTemplate = false;

  for (const line of lines) {
    // 周标题：## 第 1 周（9.1–9.6）· 摸底与方法入门
    const wm = line.match(/^##\s+第\s*(\d+)\s*周[（(]([^）)]+)[）)]\s*·\s*(.+)$/);
    if (wm) {
      inTemplate = false;
      curWeek = {
        stage,
        weekNo: +wm[1],
        range: wm[2].trim(),
        title: wm[3].trim(),
        goal: '',
        days: [],
      };
      weeks.push(curWeek);
      curDay = null;
      continue;
    }

    // 其它二级标题：可能是模板节
    const h2 = line.match(/^##\s+(.+)$/);
    if (h2) {
      const name = h2[1].trim();
      if (/模板|四件套/.test(name)) {
        inTemplate = true;
        template.push(name);
      } else {
        inTemplate = false;
      }
      curDay = null;
      continue;
    }

    // 天标题：### 9月1日 周二 · 第1天[（国庆）/（模考日）]
    const dm = line.match(/^###\s*(.+?)\s*·\s*第\s*(\d+)\s*天\s*(?:（([^）]*)）)?\s*$/);
    if (dm) {
      inTemplate = false;
      const date = parseDate(dm[1]);
      if (!date) { console.error('日期解析失败:', line); continue; }
      curDay = { date, label: dm[1].trim(), dayNo: +dm[2], tag: dm[3] || '', tasks: [] };
      if (curWeek) curWeek.days.push(curDay);
      else console.error('天标题出现在周之外:', line);
      continue;
    }

    // 本周目标
    const gm = line.match(/^本周目标[:：]\s*(.+)$/);
    if (gm && curWeek) { curWeek.goal = gm[1].trim(); continue; }

    // 任务项（只在天的上下文里收集；模板区的任务纳入 template）
    const tm = line.match(/^-\s*\[([ xX])\]\s*(.+)$/);
    if (tm) {
      const text = tm[2].trim();
      if (inTemplate) { template.push('- ' + text); continue; }
      if (curDay) curDay.tasks.push({ t: text, done: tm[1].toLowerCase() === 'x' });
      continue;
    }

    // 模板区的普通说明行
    if (inTemplate && line.trim() && !/^---+$/.test(line.trim())) {
      template.push(line.trim());
    }
  }

  // 把模板挂到该阶段第一周上（每个阶段只挂一次）
  const firstOfStage = weeks.find(w => w.stage === stage);
  if (firstOfStage) firstOfStage.template = template;
}

// ---- 校验 ----
const days = weeks.reduce((a, w) => a.concat(w.days), []);
const tasks = days.reduce((a, d) => a + d.tasks.length, 0);
const done = days.reduce((a, d) => a + d.tasks.filter(t => t.done).length, 0);

console.log('周数:', weeks.length);
console.log('天数:', days.length);
console.log('任务总数:', tasks);
console.log('已完成(预置):', done);
console.log('日期范围:', days[0] && days[0].date, '→', days[days.length - 1] && days[days.length - 1].date);
for (const w of weeks) {
  console.log(`  W${w.weekNo} [${w.stage}] ${w.range} · ${w.title} — ${w.days.length}天 / ${w.days.reduce((a, d) => a + d.tasks.length, 0)}项`);
}
// 唯一性检查
const seen = new Set();
for (const d of days) {
  if (seen.has(d.date)) console.error('!! 日期重复:', d.date);
  seen.add(d.date);
  if (!d.tasks.length) console.error('!! 无任务的天:', d.date, d.label);
}

fs.writeFileSync('D:/studynotes/.workbuddy/build/plan.json', JSON.stringify({ weeks }, null, 1), 'utf8');
console.log('\n已写出 plan.json');
