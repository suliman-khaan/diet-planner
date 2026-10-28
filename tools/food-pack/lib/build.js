'use strict';
// Builds a versioned food pack from the source files in content/<country>/.
// Recipe nutrition = sum of raw ingredient nutrition / cooked yield. Added oil is NOT part of the
// recipe; it is carried separately as oilPer100g so the app adds it once, at the chosen oil level.

const fs = require('fs');
const path = require('path');

const NUTRIENTS = ['kcal', 'protein', 'carbs', 'fat', 'fibre'];
const MEAT_ORIGINS = new Set(['meat']);

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, 'utf8'));
}

function round(n, places) {
  const f = 10 ** places;
  return Math.round(n * f) / f;
}

function loadSource(dir) {
  return {
    meta: readJson(path.join(dir, 'pack.json')),
    ingredients: readJson(path.join(dir, 'ingredients.json')).ingredients,
    measures: readJson(path.join(dir, 'measures.json')),
    foods: readJson(path.join(dir, 'foods.json')).foods,
    combos: readJson(path.join(dir, 'combos.json')).combos,
  };
}

function buildFood(food, ingredientsById, meta) {
  const parts = food.kind === 'ingredient'
    ? [{ id: food.ingredientId, grams: 100 }]
    : food.recipe.ingredients;
  const yieldGrams = food.kind === 'ingredient' ? 100 : food.recipe.cookedYieldGrams;

  const totals = Object.fromEntries(NUTRIENTS.map((n) => [n, 0]));
  const allergens = new Set();
  const origins = new Set();
  const ingredientsPer100g = [];
  for (const part of parts) {
    const ing = ingredientsById.get(part.id);
    if (!ing) throw new Error(`food ${food.id}: unknown ingredient ${part.id}`);
    for (const n of NUTRIENTS) totals[n] += (ing.per100g[n] * part.grams) / 100;
    ing.allergens.forEach((a) => allergens.add(a));
    origins.add(ing.origin);
    ingredientsPer100g.push({ id: part.id, grams: round((part.grams / yieldGrams) * 100, 2) });
  }
  if (food.oilIngredient) {
    const oil = ingredientsById.get(food.oilIngredient);
    if (!oil) throw new Error(`food ${food.id}: unknown oil ingredient ${food.oilIngredient}`);
    oil.allergens.forEach((a) => allergens.add(a));
    origins.add(oil.origin);
  }

  const nutritionPer100g = Object.fromEntries(
    NUTRIENTS.map((n) => [n, round((totals[n] / yieldGrams) * 100, 2)]),
  );

  const source = food.kind === 'ingredient'
    ? `USDA FoodData Central SR Legacy fdcId ${ingredientsById.get(food.ingredientId).source.fdcId}`
    : 'Recipe calculation from USDA FoodData Central SR Legacy ingredients; recipe proportions and yield are drafts';

  return {
    id: food.id,
    revision: food.revision || 1,
    names: food.names,
    category: food.category,
    role: food.role,
    kind: food.kind,
    nutritionPer100g,
    ingredientsPer100g,
    servings: food.servings,
    defaultServing: food.defaultServing,
    portion: food.portion,
    oilPer100g: food.oilPer100g || null,
    oilIngredient: food.oilIngredient || null,
    isSharedDish: Boolean(food.isSharedDish),
    mealSlotFit: food.mealSlotFit,
    dietary: {
      containsMeat: [...origins].some((o) => MEAT_ORIGINS.has(o)),
      containsFish: origins.has('fish'),
      containsEgg: origins.has('egg'),
      containsDairy: origins.has('dairy'),
    },
    allergens: [...allergens].sort(),
    allergenReview: food.allergenReview || 'derived',
    source,
    license: meta.license,
    reviewedBy: food.reviewedBy || null,
    reviewedAt: food.reviewedAt || null,
    status: food.status || 'draft',
  };
}

function buildPack(dir) {
  const src = loadSource(dir);
  const ingredientsById = new Map(src.ingredients.map((i) => [i.id, i]));
  return {
    schemaVersion: 1,
    packId: src.meta.packId,
    packVersion: src.meta.packVersion,
    country: src.meta.country,
    status: src.meta.status,
    license: src.meta.license,
    notice: src.meta.notice,
    measures: src.measures.measures,
    ingredients: src.ingredients.map((i) => ({
      id: i.id,
      name: i.name,
      category: i.category,
      origin: i.origin,
      allergens: i.allergens,
      per100g: i.per100g,
      source: i.source,
    })),
    foods: src.foods.map((f) => buildFood(f, ingredientsById, src.meta)),
    combos: src.combos,
  };
}

module.exports = { buildPack, NUTRIENTS };
