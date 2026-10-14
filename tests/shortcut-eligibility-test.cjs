const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const source = fs.readFileSync(path.join(__dirname, '../panel/plugin/ContextMenu.qml'), 'utf8');
const match = source.match(/&& (\/[^\n]+\/)\.test\(String\(menu\.plugin\.kinds\)\)/);
assert.ok(match, 'shortcut type check must be present');
const eligible = Function('return ' + match[1])();

for (const kinds of ['bar-widget', 'panel', 'overlay', 'menu',
  'service, bar-widget', 'service, bar-widget, panel', 'service, overlay',
  'service,panel', 'bar-widget, service']) {
  assert.equal(eligible.test(kinds), true, kinds + ' supports a launch shortcut');
}
for (const kinds of ['service', 'bar', '', 'service, bar', 'not-panel']) {
  assert.equal(eligible.test(kinds), false, kinds + ' has no launchable UI kind');
}
console.log('shortcut-eligibility-test: ok');
