'use strict';
// Validates a built food pack. Returns a list of error strings; empty means valid.
// Rules: blueprint §8 Phase 1 + .agent/rules/data-and-safety.md.

const NUTRIENTS = ['kcal', 'protein', 'carbs', 'fat', 'fibre'];
const SLOTS = new Set(['breakfast', 'lunch', 'chai', 'dinner', 'sehri', 'iftar']);
const STATUSES = new Set(['draft', 'reviewed', 'published']);
const ALLERGEN_REVIEW = new Set(['derived', 'reviewed']);
const KINDS = new Set(['recipe', 'ingredient']);
const OIL_LEVELS = ['light', 'normal', 'rich'];

const isNum = (n) => typeof n === 'number' && Number.isFinite(n);

function checkNutrition(where, obj, errors) {
  if (!obj || typeof obj !== 'object') {
    errors.push(`${where}: missing nutrition`);
    return;
  }
  for (const n of NUTRIENTS) {
    if (!isNum(obj[n])) errors.push(`${where}: nutrient ${n} is not a finite number`);
    else if (obj[n] < 0) errors.push(`${where}: nutrient ${n} is negative`);
  }
}

function dupes(list, where, errors) {
  const seen = new Set();
  for (const item of list) {
    if (seen.has(item.id)) errors.push(`${where}: duplicate id ${item.id}`);
    seen.add(item.id);
  }
  return seen;
}

function validatePack(pack) {
  const errors = [];
  if (pack.schemaVersion !== 1) errors.push('pack: unsupported schemaVersion');
  for (const key of ['packId', 'packVersion', 'country', 'license']) {
    if (!pack[key]) errors.push(`pack: missing ${key}`);
  }
  if (!STATUSES.has(pack.status)) errors.push('pack: invalid status');

  const ingredients = pack.ingredients || [];
  const foods = pack.foods || [];
  const combos = pack.combos || [];
  const ingredientIds = dupes(ingredients, 'ingredients', errors);
  const foodIds = dupes(foods, 'foods', errors);
  dupes(combos, 'combos', errors);

  for (const ing of ingredients) {
    const where = `ingredient ${ing.id}`;
    checkNutrition(where, ing.per100g, errors);
    if (!ing.source || !ing.source.dataset) errors.push(`${where}: missing source metadata`);
    if (!Array.isArray(ing.allergens)) errors.push(`${where}: missing allergens list`);
  }

  for (const food of foods) {
    const where = `food ${food.id}`;
    if (!food.names || !food.names.en) errors.push(`${where}: missing English name`);
    if (!food.names || !Array.isArray(food.names.romanUrdu) || food.names.romanUrdu.length === 0) {
      errors.push(`${where}: missing Roman Urdu aliases`);
    }
    if (!KINDS.has(food.kind)) errors.push(`${where}: invalid kind`);
    if (!isNum(food.revision) || food.revision < 1) errors.push(`${where}: invalid revision`);
    checkNutrition(where, food.nutritionPer100g, errors);

    // Source metadata
    if (!food.source) errors.push(`${where}: missing source metadata (source)`);
    if (!food.license) errors.push(`${where}: missing source metadata (license)`);
    if (!STATUSES.has(food.status)) errors.push(`${where}: invalid status`);
    if (food.status !== 'draft' && (!food.reviewedBy || !food.reviewedAt)) {
      errors.push(`${where}: status ${food.status} requires reviewedBy and reviewedAt`);
    }

    // Allergens
    if (!ALLERGEN_REVIEW.has(food.allergenReview)) errors.push(`${where}: missing allergen-review status`);
    if (!Array.isArray(food.allergens)) errors.push(`${where}: missing allergens list`);

    // Recipe references and yields
    if (!Array.isArray(food.ingredientsPer100g) || food.ingredientsPer100g.length === 0) {
      errors.push(`${where}: recipe without ingredients`);
    } else {
      for (const part of food.ingredientsPer100g) {
        if (!ingredientIds.has(part.id)) errors.push(`${where}: invalid reference to ingredient ${part.id}`);
        if (!isNum(part.grams) || part.grams <= 0) errors.push(`${where}: ingredient ${part.id} has non-positive grams`);
      }
    }

    // Servings
    const servings = food.servings || [];
    if (servings.length === 0) errors.push(`${where}: no servings`);
    const servingIds = dupes(servings, `${where} servings`, errors);
    for (const s of servings) {
      if (!isNum(s.grams) || s.grams <= 0) errors.push(`${where}: serving ${s.id} has zero or negative weight`);
      if (!s.label) errors.push(`${where}: serving ${s.id} has no label`);
    }
    if (!servingIds.has(food.defaultServing)) errors.push(`${where}: invalid reference to default serving ${food.defaultServing}`);

    // Portion rule
    const p = food.portion || {};
    if (!isNum(p.min) || !isNum(p.max) || !isNum(p.step) || p.min <= 0 || p.step <= 0 || p.max < p.min) {
      errors.push(`${where}: invalid portion rule`);
    }

    // Oil
    if (food.oilPer100g) {
      for (const level of OIL_LEVELS) {
        const v = food.oilPer100g[level];
        if (!isNum(v) || v < 0) errors.push(`${where}: oil level ${level} is not a non-negative number`);
      }
      if (!(food.oilPer100g.light <= food.oilPer100g.normal && food.oilPer100g.normal <= food.oilPer100g.rich)) {
        errors.push(`${where}: oil levels must increase light ≤ normal ≤ rich`);
      }
      if (!ingredientIds.has(food.oilIngredient)) errors.push(`${where}: invalid reference to oil ingredient ${food.oilIngredient}`);
    }

    // Slots
    if (!Array.isArray(food.mealSlotFit) || food.mealSlotFit.length === 0) errors.push(`${where}: no meal slots`);
    else for (const s of food.mealSlotFit) if (!SLOTS.has(s)) errors.push(`${where}: invalid meal slot ${s}`);
  }

  for (const combo of combos) {
    const where = `combo ${combo.id}`;
    if (!Array.isArray(combo.slots) || combo.slots.length === 0) errors.push(`${where}: no slots`);
    else for (const s of combo.slots) if (!SLOTS.has(s)) errors.push(`${where}: invalid meal slot ${s}`);
    if (!Array.isArray(combo.items) || combo.items.length === 0) errors.push(`${where}: no items`);
    else for (const item of combo.items) {
      if (!foodIds.has(item.foodId)) errors.push(`${where}: invalid reference to food ${item.foodId}`);
      if (!isNum(item.servings) || item.servings <= 0) errors.push(`${where}: item ${item.foodId} has non-positive servings`);
    }
  }
  return errors;
}

// Source-level check run before building: recipes must declare a positive cooked yield.
function validateSourceFoods(foods) {
  const errors = [];
  for (const food of foods) {
    if (food.kind === 'recipe') {
      const y = food.recipe && food.recipe.cookedYieldGrams;
      if (!isNum(y) || y <= 0) errors.push(`food ${food.id}: recipe without yield`);
      if (!food.recipe || !Array.isArray(food.recipe.ingredients) || food.recipe.ingredients.length === 0) {
        errors.push(`food ${food.id}: recipe without ingredients`);
      }
    }
  }
  return errors;
}

module.exports = { validatePack, validateSourceFoods };
