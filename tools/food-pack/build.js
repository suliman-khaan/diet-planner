#!/usr/bin/env node
'use strict';
// Usage: node tools/food-pack/build.js <content dir> <output pack.json>
const fs = require('fs');
const path = require('path');
const { buildPack } = require('./lib/build');
const { validatePack, validateSourceFoods } = require('./lib/validate');

const [dir, out] = process.argv.slice(2);
if (!dir || !out) {
  console.error('Usage: build.js <content dir> <output pack.json>');
  process.exit(2);
}

const sourceErrors = validateSourceFoods(JSON.parse(fs.readFileSync(path.join(dir, 'foods.json'), 'utf8')).foods);
if (sourceErrors.length) {
  sourceErrors.forEach((e) => console.error(`✗ ${e}`));
  process.exit(1);
}

const pack = buildPack(dir);
const errors = validatePack(pack);
if (errors.length) {
  errors.forEach((e) => console.error(`✗ ${e}`));
  process.exit(1);
}
fs.mkdirSync(path.dirname(out), { recursive: true });
fs.writeFileSync(out, JSON.stringify(pack, null, 1) + '\n');
console.log(`Built ${pack.packId} ${pack.packVersion}: ${pack.foods.length} foods, ${pack.combos.length} combos → ${out}`);
