# Workflow diagram - self-contained HTML (a client-facing explanation)

Render a workflow plan as a **graphical** diagram in one self-contained HTML file
(no internet, no CDN, no JS). Opens in any browser, offline.

**Audience and purpose.** The diagram is read by a **non-technical client** - and by
the author on a tired day. So it must be **plain and obvious**, not a developer view:
everyday words, a short explanation under every block, and a small legend at the top.
Never put the skill's internal vocabulary on screen.

## When / where

- **On request only**, and **only for workflow plans** (a linear plan is a step list -
  a diagram adds nothing).
- Output: `PLAN.diagram.html` next to `PLAN.md` (or `PLAN.<task>.diagram.html`). Into the
  current project only - never the home or skill folder. Don't overwrite silently.
- It is a **view of the plan**: same structure as the branch map, nothing invented.

## Plain language - translate the internals (the core rule)

The plan is built from internal terms. On screen, translate every one to plain words:

| Internal term (plan/script) | Plain words in the diagram |
|---|---|
| Phase 0 / anchor | "Договариваемся о задаче" / "Готовим основу" - what we settle first so the rest matches |
| Phase N | a named step ("Собираем вместе") or "Шаг N: ..." - never "Фаза" |
| parallel / barrier | "Делаем одновременно - так быстрее" |
| pipeline | "По очереди: сначала ..., потом ..." |
| verify / gate | "Проверка: всё ли хорошо?" |
| loop (retry / until-dry) | "Повторяем по кругу, пока не станет хорошо / пока не закончатся проблемы" |
| collapse xN | "Несколько сразу" (don't say "N agents") |
| assembly / synthesis | "Собираем всё в одно" |
| deploy | "Запускаем" |

Every block gets a **one-line plain explanation** under its title (the `<small>`): what
happens here and why, in the client's words.

## The legend (always include)

A small legend bar at the top explains the colours and arrows in plain words:
blue = where we start / what we agree, white = a normal step, yellow = a check,
red loop = repeat until good, green = launch, ↓ = next step, "одновременно" = in parallel.
The client should be able to read the diagram without you next to them.

## Layout rules

- One column, top to bottom. Parallel steps sit in a row under the tag "делаем одновременно".
- Collapse 4+ same-type branches into one dashed "несколько сразу" block - never draw 8 boxes.
- Loops use the CSS U-connector below; the label says, in plain words, **when it stops**
  ("пока не станет чисто", "пока список не опустеет"). A loop with no visible stop means
  the plan forgot its stop condition - fix the plan.
- All text in the **language of the task**.

## Generation checklist

1. Self-contained: one `.html`, everything inline. No `http(s)://`, no external `src`/`href`,
   no web fonts (system font stack). Opens offline = it must render.
2. Plain language only - no "фаза / anchor / barrier / verify / pipeline / loop-until-dry"
   visible on screen.
3. Every block has a one-line plain explanation.
4. The legend is present.
5. Each loop's label says, in plain words, when it stops.
6. Matches the branch map; wide fan-outs collapsed; labels in the task's language.

## Template (clone this, keep the CSS, swap the content)

Renders one workflow in the client style: a start/agreement block, a parallel row
(with a collapsed "несколько сразу"), a check-and-repeat loop with a plain stop, a launch.
Valid, offline, self-contained. Adapt blocks/labels to the actual plan; the example is
Russian to illustrate - match whatever language the plan is in.

```html
<!doctype html>
<html lang="ru">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Как идёт работа</title>
<style>
  :root{
    --bg:#f6f7f9; --card:#fff; --ink:#1f2933; --muted:#6b7280; --line:#9aa5b1;
    --start:#2563eb; --check:#d97706; --loop:#c0392b; --done:#15803d;
  }
  *{box-sizing:border-box}
  body{margin:0;background:var(--bg);color:var(--ink);
    font:15px/1.5 system-ui,-apple-system,"Segoe UI",Roboto,Arial,sans-serif}
  .wf{max-width:760px;margin:32px auto;padding:0 16px}
  h1{font-size:20px;margin:0 0 4px}
  .intro{color:var(--muted);font-size:13px;margin:0 0 18px}
  .legend{display:flex;flex-wrap:wrap;gap:10px 18px;background:#fff;border:1px solid #e5e7eb;
    border-radius:12px;padding:12px 14px;margin-bottom:26px;font-size:12.5px}
  .legend .item{display:flex;align-items:center;gap:8px}
  .swatch{width:16px;height:16px;border-radius:5px;border:1.5px solid var(--line);flex:none}
  .swatch--start{border-color:var(--start);background:#dbeafe}
  .swatch--check{border-color:var(--check);background:#fffbeb;border-radius:999px}
  .swatch--loop{border-color:var(--loop);background:#fff;border-style:dashed}
  .swatch--done{border-color:var(--done);background:#dcfce7}
  .lane{display:flex;flex-wrap:wrap;gap:10px;justify-content:center;align-items:stretch}
  .tag{font-size:12px;color:var(--muted);text-align:center;margin:2px 0 8px}
  .node{background:#fff;border:1.5px solid var(--line);border-radius:10px;
    padding:9px 13px;min-width:120px;max-width:300px;text-align:center}
  .node b{display:block;font-weight:600;margin-bottom:2px}
  .node small{display:block;font-size:12px;color:var(--muted)}
  .node--start{border-color:var(--start);box-shadow:inset 0 0 0 2px #dbeafe}
  .node--done{border-color:var(--done);box-shadow:inset 0 0 0 2px #dcfce7}
  .node--many{border-style:dashed}
  .verify{background:#fffbeb;border:1.5px solid var(--check);border-radius:999px;
    padding:9px 15px;color:#92400e;text-align:center;align-self:center}
  .verify b{display:block;font-weight:600}
  .arrow-down{text-align:center;color:var(--line);font-size:22px;line-height:1;margin:6px 0}
  .arrow-r{color:var(--line);font-size:18px;align-self:center}
  .loop{position:relative}
  .loop-edge{height:26px;margin:2px 60px 0;border:2px dashed var(--loop);
    border-top:none;border-radius:0 0 12px 12px;position:relative}
  .loop-edge::before{content:"";position:absolute;left:-7px;top:-1px;
    border:5px solid transparent;border-bottom-color:var(--loop);border-top:none}
  .loop-label{text-align:center;font-size:12px;color:var(--loop);font-weight:600;margin-top:5px}
</style>
</head>
<body>
<div class="wf">
  <h1>Как идёт работа: сайт на WordPress</h1>
  <p class="intro">Путь от начала до запуска, читается сверху вниз. Что значат цвета — в подсказке ниже.</p>

  <div class="legend">
    <div class="item"><span class="swatch swatch--start"></span> синий — с чего начинаем</div>
    <div class="item"><span class="swatch"></span> белый — обычный шаг</div>
    <div class="item"><span class="swatch swatch--check"></span> жёлтый — проверка</div>
    <div class="item"><span class="swatch swatch--loop"></span> красная петля — повторяем, пока не станет хорошо</div>
    <div class="item"><span class="swatch swatch--done"></span> зелёный — запуск</div>
    <div class="item">↓ — следующий шаг · «одновременно» — параллельно</div>
  </div>

  <div class="lane"><div class="node node--start"><b>Договариваемся о задаче</b><small>цель сайта, нужные страницы, цвета и стиль — в одном месте</small></div></div>
  <div class="arrow-down">↓</div>
  <div class="lane"><div class="node"><b>Готовим площадку</b><small>ставим сайт, базу и нужные дополнения</small></div></div>
  <div class="arrow-down">↓</div>
  <div class="tag">делаем одновременно — так быстрее</div>
  <div class="lane">
    <div class="node node--many"><b>Тексты и картинки</b><small>наполняем страницы</small></div>
    <div class="node"><b>Внешний вид</b><small>дизайн в нашем стиле</small></div>
    <div class="node"><b>Настройки</b><small>формы, аналитика, поиск</small></div>
  </div>
  <div class="arrow-down">↓</div>
  <div class="lane"><div class="node"><b>Собираем вместе</b><small>соединяем тексты и дизайн в готовый сайт</small></div></div>
  <div class="arrow-down">↓</div>
  <div class="loop">
    <div class="lane">
      <div class="node"><b>Проверяем и правим</b><small>ссылки, телефон/ПК, скорость, опечатки</small></div>
      <span class="arrow-r">→</span>
      <div class="verify"><b>всё хорошо?</b></div>
    </div>
    <div class="loop-edge"></div>
    <div class="loop-label">если есть огрехи — правим и проверяем снова, пока не станет чисто</div>
  </div>
  <div class="arrow-down">↓ чисто</div>
  <div class="lane"><div class="node node--done"><b>Запускаем</b><small>выкладываем в интернет, проверяем вживую</small></div></div>
</div>
</body>
</html>
```
