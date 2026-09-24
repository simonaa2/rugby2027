## 2023-11-20 - Adding Accessibility Labels
**Learning:** Found a pattern where filter/search inputs and select menus in the data dashboards (`rugby.html` and `salary.html`) lacked proper semantically linked labels (`for` attributes on `<label>` pointing to `id`s) and interactive controls like close buttons lacked screen-reader-friendly text (`aria-label`).
**Action:** Consistently ensure that all `<label>` tags explicitly link to their target inputs via `for="..."` and icon-only buttons or visually-implied search/filter dropdowns use `aria-label="..."`.
