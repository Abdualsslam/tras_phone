# RTL and Responsive QA Checklist

Use this checklist before merging frontend changes.

## 1) Direction and Language

- [ ] App works correctly in Arabic (`ar`, `dir=rtl`) and English (`en`, `dir=ltr`).
- [ ] No hardcoded `dir="rtl"` in components.
- [ ] `dir="ltr"` is used only for data fields that must stay LTR (SKU, codes, email, phone, tracking IDs, numeric references).
- [ ] No physical direction utility classes in UI (`ml-*`, `mr-*`, `pl-*`, `pr-*`, `text-left`, `text-right`, `float-left`, `float-right`).

## 2) Mobile and Desktop Layout

- [ ] All create/edit dialogs are usable on mobile width (`360x800`) without horizontal clipping.
- [ ] Multi-column forms collapse to one column on small screens.
- [ ] Tables remain readable on mobile (scroll container visible and usable).
- [ ] Action buttons and dropdowns remain reachable on small screens.

## 3) Pages to Smoke Test

- [ ] Dashboard
- [ ] Customers
- [ ] Products
- [ ] Orders + Order Details
- [ ] Content
- [ ] Settings

## 4) Visual Regression Matrix

Run quick visual checks at these combinations:

- [ ] Arabic + Mobile (360x800)
- [ ] Arabic + Desktop (1440x900)
- [ ] English + Mobile (360x800)
- [ ] English + Desktop (1440x900)

## 5) Automation Commands

Run these before creating a PR:

```bash
npm run check:ui
npm run build
```
