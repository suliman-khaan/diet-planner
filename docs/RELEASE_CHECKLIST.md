# Release Checklist

Complete every item for each release. Record the result in `IMPLEMENTATION_STATUS.md`.

## Quality
- [ ] CI green: format, analyze, tests, food-pack validator, secret/dependency scan
- [ ] Integration tests pass, including upgrade from previous release
- [ ] Performance budgets measured on baseline low-end device (APK, cold start, search, plan, memory)
- [ ] No known data-loss, wrong-total or exclusion bugs
- [ ] Core flows verified with network blocked

## Content and safety
- [ ] Food pack validated; reviewed share meets threshold for this release
- [ ] Nutritionist sign-off current for data and TargetPolicy version
- [ ] No medical claims in app or store listing

## Security and privacy
- [ ] No secrets in repo or build
- [ ] Permissions and SDKs reviewed; Data Safety form matches behaviour
- [ ] Consent gating for analytics/crash verified
- [ ] Export and delete-all verified

## Store (Google Play)
- [ ] Target API level requirement met
- [ ] Health apps declaration complete
- [ ] Privacy policy URL and support email live
- [ ] Signed App Bundle built with owner-controlled key
- [ ] Staged rollout plan: 10% → 50% → 100%, crash-free ≥ 99.5% at each step
