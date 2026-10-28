'use strict';
const test = require('node:test');
const assert = require('node:assert');
const path = require('path');
const { buildPack } = require('../lib/build');
const { validatePack, validateSourceFoods } = require('../lib/validate');

const CONTENT = path.join(__dirname, '..', '..', '..', 'content', 'pakistan');

function minimalPack() {
  return {
    schemaVersion: 1,
    packId: 'test',
    packVersion: '1',
    country: 'XX',
    status: 'draft',
    license: 'test',
    ingredients: [
      { id: 'flour', per100g: { kcal: 340, protein: 13, carbs: 72, fat: 2.5, fibre: 10 }, allergens: ['gluten'], source: { dataset: 'test' } },
      { id: 'oil', per100g: { kcal: 884, protein: 0, carbs: 0, fat: 100, fibre: 0 }, allergens: [], source: { dataset: 'test' } },
    ],
    foods: [
      {
        id: 'roti', revision: 1, kind: 'recipe',
        names: { en: 'Roti', romanUrdu: ['roti'] },
        nutritionPer100g: { kcal: 247, protein: 9.6, carbs: 52, fat: 1.8, fibre: 7.8 },
        ingredientsPer100g: [{ id: 'flour', grams: 72.7 }],
        servings: [{ id: 'medium', label: '1 roti', grams: 55 }], defaultServing: 'medium',
        portion: { min: 1, max: 4, step: 1 },
        oilPer100g: { light: 1, normal: 2, rich: 3 }, oilIngredient: 'oil',
        mealSlotFit: ['lunch'], allergens: ['gluten'], allergenReview: 'derived',
        source: 'test', license: 'test', status: 'draft', reviewedBy: null, reviewedAt: null,
      },
    ],
    combos: [{ id: 'c1', slots: ['lunch'], items: [{ foodId: 'roti', servings: 2 }] }],
  };
}

function expectError(mutate, pattern) {
  const pack = minimalPack();
  mutate(pack);
  const errors = validatePack(pack);
  assert.ok(errors.some((e) => pattern.test(e)), `expected ${pattern}, got: ${JSON.stringify(errors)}`);
}

test('minimal pack is valid', () => {
  assert.deepStrictEqual(validatePack(minimalPack()), []);
});

test('the committed Pakistan source builds into a valid pack', () => {
  const pack = buildPack(CONTENT);
  assert.deepStrictEqual(validatePack(pack), []);
  assert.ok(pack.foods.length >= 50);
});

test('every built food is draft until a named reviewer signs it off', () => {
  const pack = buildPack(CONTENT);
  for (const f of pack.foods) {
    if (f.status !== 'draft') assert.ok(f.reviewedBy && f.reviewedAt, `${f.id} marked ${f.status} without reviewer`);
  }
});

test('rejects duplicate IDs', () => expectError((p) => p.foods.push({ ...p.foods[0] }), /duplicate id roti/));
test('rejects duplicate ingredient IDs', () => expectError((p) => p.ingredients.push({ ...p.ingredients[0] }), /duplicate id flour/));
test('rejects missing source metadata', () => expectError((p) => { delete p.foods[0].source; }, /missing source metadata/));
test('rejects missing licence', () => expectError((p) => { delete p.foods[0].license; }, /missing source metadata \(license\)/));
test('rejects invalid ingredient references', () => expectError((p) => { p.foods[0].ingredientsPer100g[0].id = 'nope'; }, /invalid reference to ingredient nope/));
test('rejects invalid combo references', () => expectError((p) => { p.combos[0].items[0].foodId = 'ghost'; }, /invalid reference to food ghost/));
test('rejects invalid oil ingredient reference', () => expectError((p) => { p.foods[0].oilIngredient = 'butter'; }, /oil ingredient butter/));
test('rejects negative nutrition', () => expectError((p) => { p.foods[0].nutritionPer100g.fat = -1; }, /fat is negative/));
test('rejects non-finite nutrition', () => expectError((p) => { p.foods[0].nutritionPer100g.kcal = NaN; }, /kcal is not a finite number/));
test('rejects non-finite ingredient nutrition', () => expectError((p) => { p.ingredients[0].per100g.protein = Infinity; }, /protein is not a finite number/));
test('rejects zero serving weights', () => expectError((p) => { p.foods[0].servings[0].grams = 0; }, /zero or negative weight/));
test('rejects negative serving weights', () => expectError((p) => { p.foods[0].servings[0].grams = -5; }, /zero or negative weight/));
test('rejects missing allergen-review status', () => expectError((p) => { delete p.foods[0].allergenReview; }, /missing allergen-review status/));
test('rejects reviewed status without a reviewer', () => expectError((p) => { p.foods[0].status = 'reviewed'; }, /requires reviewedBy/));
test('rejects invalid meal slots', () => expectError((p) => { p.foods[0].mealSlotFit = ['brunch']; }, /invalid meal slot brunch/));
test('rejects broken portion rules', () => expectError((p) => { p.foods[0].portion = { min: 2, max: 1, step: 1 }; }, /invalid portion rule/));
test('rejects decreasing oil levels', () => expectError((p) => { p.foods[0].oilPer100g = { light: 5, normal: 2, rich: 3 }; }, /oil levels must increase/));
test('rejects unknown default serving', () => expectError((p) => { p.foods[0].defaultServing = 'huge'; }, /default serving huge/));

test('rejects recipes without yields', () => {
  const errors = validateSourceFoods([{ id: 'x', kind: 'recipe', recipe: { ingredients: [{ id: 'a', grams: 1 }] } }]);
  assert.ok(errors.some((e) => /recipe without yield/.test(e)));
  const zero = validateSourceFoods([{ id: 'y', kind: 'recipe', recipe: { ingredients: [{ id: 'a', grams: 1 }], cookedYieldGrams: 0 } }]);
  assert.ok(zero.some((e) => /recipe without yield/.test(e)));
});

test('recipe nutrition is per 100 g cooked and excludes added oil', () => {
  const pack = buildPack(CONTENT);
  const roti = pack.foods.find((f) => f.id === 'roti');
  // 40 g atta (340 kcal/100 g) in a 55 g roti → 136 kcal / 55 g → 247.27 kcal / 100 g.
  assert.strictEqual(roti.nutritionPer100g.kcal, 247.27);
  const karahi = pack.foods.find((f) => f.id === 'chicken-karahi');
  assert.ok(!karahi.ingredientsPer100g.some((i) => i.id === 'oil'), 'oil must not be a recipe ingredient');
  assert.ok(karahi.oilPer100g.normal > 0);
});

test('allergens and diet flags are derived from ingredients, oil included', () => {
  const pack = buildPack(CONTENT);
  const naan = pack.foods.find((f) => f.id === 'naan');
  assert.deepStrictEqual(naan.allergens, ['dairy', 'gluten']);
  const saag = pack.foods.find((f) => f.id === 'sarson-saag');
  assert.ok(saag.allergens.includes('dairy'), 'ghee as cooking fat adds dairy');
  assert.strictEqual(pack.foods.find((f) => f.id === 'chicken-karahi').dietary.containsMeat, true);
  assert.strictEqual(pack.foods.find((f) => f.id === 'daal-masoor').dietary.containsMeat, false);
});
