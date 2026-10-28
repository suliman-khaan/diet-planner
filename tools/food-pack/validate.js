#!/usr/bin/env node
'use strict';
// Usage: node tools/food-pack/validate.js <pack.json>   — exits 1 on any error.
const fs = require('fs');
const { validatePack } = require('./lib/validate');

const file = process.argv[2];
if (!file) {
  console.error('Usage: validate.js <pack.json>');
  process.exit(2);
}
let pack;
try {
  pack = JSON.parse(fs.readFileSync(file, 'utf8'));
} catch (e) {
  console.error(`✗ cannot read pack: ${e.message}`);
  process.exit(1);
}
const errors = validatePack(pack);
if (errors.length) {
  errors.forEach((e) => console.error(`✗ ${e}`));
  console.error(`${errors.length} error(s)`);
  process.exit(1);
}
const reviewed = pack.foods.filter((f) => f.status !== 'draft').length;
console.log(`✓ ${file} valid: ${pack.foods.length} foods (${reviewed} reviewed), ${pack.combos.length} combos`);
