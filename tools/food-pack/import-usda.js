// Regenerates content/pakistan/ingredients.json from the USDA SR Legacy JSON download
// (https://fdc.nal.usda.gov/download-datasets, "SR Legacy" JSON). Values are copied, never edited by hand.
// Usage: node tools/food-pack/import-usda.js <sr_legacy.json> <out.json>
const fs = require('fs');
const [file, out] = process.argv.slice(2);
const foods = JSON.parse(fs.readFileSync(file, 'utf8')).SRLegacyFoods;
const byId = new Map(foods.map((f) => [f.fdcId, f]));
const NUT = { kcal: '208', protein: '203', fat: '204', carbs: '205', fibre: '291' };

// id, English name, fdcId, category, allergens, diet flags (meat|fish|egg|dairy|plant)
const map = [
  ['atta', 'Whole-wheat flour (atta)', 168893, 'grain', ['gluten'], 'plant'],
  ['maida', 'White flour (maida)', 168894, 'grain', ['gluten'], 'plant'],
  ['rice', 'White rice, long-grain, raw', 168877, 'grain', [], 'plant'],
  ['semolina', 'Semolina (suji)', 169715, 'grain', ['gluten'], 'plant'],
  ['corn-flour', 'Corn flour, whole-grain (makki atta)', 170290, 'grain', [], 'plant'],
  ['besan', 'Chickpea flour (besan)', 174288, 'grain', [], 'plant'],
  ['bread-white', 'White bread', 174924, 'bakery', ['gluten'], 'plant'],
  ['rusk', 'Rusk (zwieback)', 171372, 'bakery', ['gluten'], 'plant'],
  ['masoor', 'Red lentils (masoor), raw', 174284, 'legume', [], 'plant'],
  ['moong', 'Mung beans (moong), raw', 174256, 'legume', [], 'plant'],
  ['mash', 'Black gram (mash), raw', 174259, 'legume', [], 'plant'],
  ['chana', 'Chickpeas (chana), raw', 173756, 'legume', [], 'plant'],
  ['rajma', 'Red kidney beans (rajma), raw', 173744, 'legume', [], 'plant'],
  ['chicken', 'Chicken, meat only, raw', 171052, 'meat', [], 'meat'],
  ['goat', 'Goat meat (mutton), raw', 175303, 'meat', [], 'meat'],
  ['beef-mince', 'Beef mince, 90% lean, raw', 174030, 'meat', [], 'meat'],
  ['fish', 'Fish (carp), raw', 171952, 'fish', ['fish'], 'fish'],
  ['egg', 'Egg, whole, raw', 171287, 'egg', ['egg'], 'egg'],
  ['milk', 'Milk, whole', 172217, 'dairy', ['dairy'], 'dairy'],
  ['yogurt', 'Yogurt (dahi), plain, whole milk', 171284, 'dairy', ['dairy'], 'dairy'],
  ['ghee', 'Ghee (clarified butter)', 171314, 'fat', ['dairy'], 'dairy'],
  ['oil', 'Cooking oil (soybean)', 171411, 'fat', [], 'plant'],
  ['onion', 'Onion, raw', 170000, 'vegetable', [], 'plant'],
  ['tomato', 'Tomato, raw', 170457, 'vegetable', [], 'plant'],
  ['potato', 'Potato, raw', 170028, 'vegetable', [], 'plant'],
  ['spinach', 'Spinach (palak), raw', 168462, 'vegetable', [], 'plant'],
  ['mustard-greens', 'Mustard greens (sarson), raw', 169256, 'vegetable', [], 'plant'],
  ['cauliflower', 'Cauliflower (gobi), raw', 169986, 'vegetable', [], 'plant'],
  ['okra', 'Okra (bhindi), raw', 169260, 'vegetable', [], 'plant'],
  ['eggplant', 'Eggplant (baingan), raw', 169228, 'vegetable', [], 'plant'],
  ['peas', 'Green peas (matar), raw', 170419, 'vegetable', [], 'plant'],
  ['carrot', 'Carrot, raw', 170393, 'vegetable', [], 'plant'],
  ['cucumber', 'Cucumber (kheera), raw', 168409, 'vegetable', [], 'plant'],
  ['cabbage', 'Cabbage, raw', 169975, 'vegetable', [], 'plant'],
  ['lauki', 'Bottle gourd (lauki), raw', 169232, 'vegetable', [], 'plant'],
  ['green-chili', 'Green chili, raw', 170497, 'vegetable', [], 'plant'],
  ['garlic', 'Garlic, raw', 169230, 'vegetable', [], 'plant'],
  ['ginger', 'Ginger, raw', 169231, 'vegetable', [], 'plant'],
  ['coriander', 'Coriander leaves (dhania), raw', 169997, 'vegetable', [], 'plant'],
  ['lemon-juice', 'Lemon juice', 167747, 'fruit', [], 'plant'],
  ['banana', 'Banana, raw', 173944, 'fruit', [], 'plant'],
  ['apple', 'Apple, raw, with skin', 171688, 'fruit', [], 'plant'],
  ['mango', 'Mango, raw', 169910, 'fruit', [], 'plant'],
  ['orange', 'Orange, raw', 169097, 'fruit', [], 'plant'],
  ['guava', 'Guava, raw', 173044, 'fruit', [], 'plant'],
  ['dates', 'Dates (khajoor), deglet noor', 171726, 'fruit', [], 'plant'],
  ['almonds', 'Almonds', 170567, 'nut', ['nuts'], 'plant'],
  ['sugar', 'Sugar, granulated', 169655, 'sweetener', [], 'plant'],
  ['tea-brewed', 'Black tea, brewed', 173227, 'beverage', [], 'plant'],
];

const ingredients = map.map(([id, name, fdcId, category, allergens, origin]) => {
  const f = byId.get(fdcId);
  if (!f) throw new Error(`fdcId ${fdcId} not found for ${id}`);
  const per100g = {};
  for (const [k, num] of Object.entries(NUT)) {
    const n = f.foodNutrients.find((x) => x.nutrient && x.nutrient.number === num);
    if (!n || typeof n.amount !== 'number') throw new Error(`${id}: missing nutrient ${k}`);
    per100g[k] = n.amount;
  }
  return {
    id,
    name,
    category,
    origin,
    allergens,
    per100g,
    source: { dataset: 'USDA FoodData Central SR Legacy (2018-04)', fdcId, description: f.description },
  };
});
ingredients.push({
  id: 'water',
  name: 'Water',
  category: 'beverage',
  origin: 'plant',
  allergens: [],
  per100g: { kcal: 0, protein: 0, fat: 0, carbs: 0, fibre: 0 },
  source: { dataset: 'none (water has no energy)', fdcId: null, description: 'Water' },
});

fs.writeFileSync(out, JSON.stringify({
  note: 'Generated from USDA FoodData Central SR Legacy (public domain, CC0). Allergen and origin tags are drafts pending review.',
  ingredients,
}, null, 2) + '\n');
console.log(`wrote ${ingredients.length} ingredients`);
