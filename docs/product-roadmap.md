# Meal Finder — Product Roadmap (Full Stack Learning)

> **Mục tiêu:** Mỗi tính năng đi qua đủ 8 lớp: **UI → Data → Architecture & State → Lint → Test → Debug → Performance → Security**.
> Dùng làm checklist report. FE dev map sang React/Vue trong cột **Map FE**.

---

## Hiện trạng (v1.0 — đã có)

| Tính năng | Trạng thái |
|---|---|
| Login mock (`user_name`, `password`, có data = pass) | ✅ |
| AuthGate + persist session | ✅ |
| Discover (search, category, grid) | ✅ |
| Meal Detail (lookup API) | ✅ |
| Favorites (SharedPreferences) | ✅ |
| Profile + Logout | ✅ |
| Pattern hiện tại | `ChangeNotifier` + Riverpod + `go_router` + Dio |

**Nợ kỹ thuật cần trả dần:** không có router thật, state rải rác, favorites global (không theo user), chưa repository layer, test coverage mỏng, lint cơ bản.

---

## Cách đọc roadmap

Mỗi **Phase** = 1–2 tuần học (tuỳ tốc độ). Trong mỗi phase, mỗi **Feature** có bảng 8 cột:

| Cột | Ý nghĩa |
|---|---|
| **UI** | Widget, UX, responsive, empty/error states |
| **Data** | Model, API, local storage, mapping |
| **Arch & State** | Layer, DI, state management |
| **Lint** | Rule bật thêm, format |
| **Test** | Unit / widget / integration |
| **Debug** | DevTools, logging, breakpoints |
| **Perf** | Rebuild, cache, list, network |
| **Security** | Input, storage, secrets, transport |

**Thứ tự làm trong 1 feature:** UI (shell) → Data (mock/API) → Wire state → Test → Lint → Debug verify → Perf check → Security review.

---

## Phase 1 — Polish MVP (tuần 1)

> Hoàn thiện app hiện tại trước khi thêm feature lớn. Học **end-to-end một feature nhỏ**.

### F1.1 — Settings & Dark Mode toggle

| Lớp | Việc làm | Map FE |
|---|---|---|
| UI | Tab Settings hoặc section trong Profile: Switch dark/light/system | Theme toggle trong Settings page |
| Data | `ThemeMode` lưu `SharedPreferences` key `theme_mode` | `localStorage.theme` |
| Arch | `ThemeStore extends ChangeNotifier` hoặc gộp `SettingsStore` | Zustand settings slice |
| Lint | `prefer_const_constructors`, no magic strings → constants file | ESLint const |
| Test | Widget: toggle → `ThemeMode.dark`; unit: persist read/write | RTL + mock localStorage |
| Debug | DevTools → inspect `ThemeMode`; log theme change | React DevTools theme |
| Perf | `MaterialApp` rebuild chỉ khi theme đổi (ListenableBuilder ở root) | Context split |
| Security | Không sensitive data | N/A |

**Done khi:** toggle dark mode, kill app, mở lại vẫn đúng theme.

---

### F1.2 — Favorites: pull-to-refresh + swipe delete

| Lớp | Việc làm | Map FE |
|---|---|---|
| UI | `RefreshIndicator` trên Favorites; `Dismissible` swipe xóa + confirm snackbar Undo | Swipe-to-delete list |
| Data | `FavoritesStore.remove(id)` + `toggle` giữ nguyên | Store action `removeFavorite` |
| Arch | Logic xóa trong Store, UI chỉ gọi method | Không mutate array trong component |
| Lint | `use_build_context_synchronously` sau async undo | — |
| Test | Unit: remove; Widget: swipe → item biến mất | RTL fireEvent swipe |
| Debug | Breakpoint trong `toggle` / `remove` | — |
| Perf | `GridView` `itemCount` ổn định; tránh rebuild cả grid khi 1 item đổi | `key` trên card |
| Security | Favorite chỉ local, không leak PII | — |

**Done khi:** swipe xóa, undo trong 3s, refresh không crash.

---

### F1.3 — Home greeting + empty search UX

| Lớp | Việc làm | Map FE |
|---|---|---|
| UI | AppBar subtitle `Hi, {displayName}`; debounce search 300ms; skeleton thay spinner | Debounced search input |
| Data | Đọc `auth.currentUser` từ props/store | `useAuth().user` |
| Arch | Truyền `AuthStore` vào `HomeScreen` hoặc Riverpod (Phase 2) | Prop drilling → context |
| Lint | Extract magic `300` → `kSearchDebounceMs` | constants |
| Test | Widget: debounce không gọi API quá nhiều lần (fake timer) | fake timers |
| Debug | Network tab Dio log (Phase 3) | Axios interceptors log |
| Perf | Debounce giảm API calls | lodash.debounce |
| Security | Sanitize search string trước khi gửi query param | encodeURIComponent |

---

## Phase 2 — Navigation & State (tuần 2)

> Học **architecture** — tách routing và state khỏi widget.

### F2.1 — `go_router` + deep routes

| Route | Màn |
|---|---|
| `/login` | LoginScreen |
| `/` | Discover (shell) |
| `/favorites` | Favorites |
| `/profile` | Profile |
| `/meals/:id` | Detail |

| Lớp | Việc làm | Map FE |
|---|---|---|
| UI | `ShellRoute` bottom nav; Detail push có back | React Router nested routes |
| Data | Pass `mealId` qua path param; name/thumb optional `extra` | `useParams()` |
| Arch | `GoRouter` listen `AuthStore` → redirect login | Protected routes |
| Lint | Router file riêng `lib/router/app_router.dart` | `routes.tsx` |
| Test | Widget: `/meals/52772` mở detail; logged out → `/login` | MemoryRouter tests |
| Debug | Log `GoRouter` redirect reason | — |
| Perf | Detail lazy load vẫn 1 API lookup | code splitting route |
| Security | Không put password trong URL/extra | — |

**Done khi:** Back từ Detail về list; logout redirect `/login`; AuthGate thay bằng router redirect.

---

### F2.2 — Riverpod migration (Auth + Favorites trước) — **đã xong**

| Lớp | Việc làm | Map FE |
|---|---|---|
| UI | `ConsumerWidget` / `ref.watch(authStoreProvider)` | `useAuthStore()` |
| Data | Providers wrap existing services; override trong `main()` | DI container |
| Arch | `authStoreProvider`, `favoritesStoreProvider`, `mealApiProvider` | Zustand / TanStack Query |
| Lint | Analyze sạch (`riverpod_lint` optional) | — |
| Test | `ProviderContainer` + `ProviderScope` overrides | mock provider |
| Debug | `debugPrint` khi tạo GoRouter | Redux DevTools |
| Perf | `ref.read` auth trong `goRouterProvider` | selector |
| Security | Provider không expose password | — |

**Migration order:** AuthStore → FavoritesStore → HomeScreen `mealApiProvider` → Detail.

**Done khi:** Xóa `ListenableBuilder` ở root; không còn truyền store qua 3 tầng widget.

---

## Phase 3 — Data layer & Repository (tuần 3)

### F3.1 — Repository pattern cho Meals

```
UI → MealController/Provider → MealRepository → MealApi (Dio)
                              → MealLocalCache (optional)
```

| Lớp | Việc làm | Map FE |
|---|---|---|
| UI | Không đổi (provider gọi repo) | Hook gọi service |
| Data | `MealRepository`: search, byCategory, lookup, random | API service layer |
| Arch | Interface `IMealRepository` + impl; inject vào provider | Repository interface |
| Lint | `one_member_abstracts` — dùng typedef hoặc class | — |
| Test | Mock repository trong widget test | MSW + mock service |
| Debug | Log request/response ở Dio interceptor | Axios interceptors |
| Perf | Optional in-memory cache 5 phút cho categories | SWR staleTime |
| Security | HTTPS only (TheMealDB đã HTTPS); validate JSON shape | Zod parse response |

---

### F3.2 — Favorites theo user (multi-account)

| Lớp | Việc làm | Map FE |
|---|---|---|
| UI | Không đổi UX | — |
| Data | Key `favorite_meals_{userId}` thay vì global | Namespace localStorage |
| Arch | `FavoritesRepository` nhận `userId` từ auth | User-scoped store |
| Lint | — | — |
| Test | User A favorites ≠ User B after switch login | — |
| Debug | Log key đang dùng | — |
| Perf | — | — |
| Security | Clear favorites key on logout (optional) | — |

---

### F3.3 — Search history (local)

| Lớp | Việc làm | Map FE |
|---|---|---|
| UI | Chips “Recent searches” dưới SearchBar; tap → search lại | Recent searches dropdown |
| Data | `List<String>` max 10, prefs `search_history` | localStorage array |
| Arch | `SearchHistoryStore` hoặc method trong Home provider | — |
| Test | Add dedupe, max length | — |
| Debug | — | — |
| Perf | Limit 10 items | — |
| Security | Không lưu password trong history | — |

---

## Phase 4 — Auth v2 & API-ready (tuần 4)

### F4.1 — Auth Repository + fake REST (JSONPlaceholder / mock server)

| Lớp | Việc làm | Map FE |
|---|---|---|
| UI | Login giữ nguyên; thêm inline “invalid credentials” (mock rule: user ≠ `demo`) | Error message from API |
| Data | `POST /login` mock → `{ user, token }`; lưu token riêng key `auth_token` | JWT in memory + secure storage |
| Arch | `AuthRepository` thay `AuthService` trực tiếp | authService abstraction |
| Lint | — | — |
| Test | Mock Dio adapter 401 / 200 | — |
| Debug | Dio LogInterceptor debug-only | — |
| Perf | — | — |
| Security | **flutter_secure_storage** cho token; never log token; clear on logout | httpOnly cookie analog |

---

### F4.2 — Dio interceptor (401 → logout)

| Lớp | Việc làm | Map FE |
|---|---|---|
| UI | SnackBar “Session expired” | Global error handler |
| Data | Interceptor read token header | Axios request interceptor |
| Arch | Central `ApiClient` factory | apiClient singleton |
| Test | 401 triggers logout mock | — |
| Security | Token refresh deferred Phase 5 | — |

---

## Phase 5 — Quality gate (song song / sau mỗi phase)

### Lint & Format (baseline → strict)

| Bước | Việc |
|---|---|
| L1 | `dart format .` + CI script `flutter analyze` |
| L2 | Bật `analysis_options.yaml`: `prefer_single_quotes`, `always_declare_return_types`, `avoid_print` |
| L3 | `very_good_analysis` hoặc custom strict rules (Phase 2+) |
| L4 | Pre-commit: `dart format --set-exit-if-changed` |

**Map FE:** ESLint + Prettier + husky lint-staged.

---

### Test pyramid

| Loại | Target | Ví dụ |
|---|---|---|
| Unit | Models, stores, repositories, auth service | `Meal.fromJson`, `AuthStore.logout` |
| Widget | Login, Home empty, Favorites swipe | `pumpWidget` + `pumpAndSettle` |
| Integration | Login → Discover → Detail → Favorite (1 flow) | `integration_test/` |
| Golden (optional) | Login screen, MealCard | screenshot diff |

**Coverage goal v1:** ≥60% lib/services + lib/models; critical paths widget tested.

---

### Debug playbook

| Tool | Dùng khi |
|---|---|
| Flutter DevTools → Inspector | Widget tree, overflow |
| DevTools → Network | Dio calls (Phase 3+) |
| DevTools → CPU / Memory | Phase perf |
| `debugPrint` / `Logger` class | Auth redirect, API errors |
| Breakpoints | Store notify, router redirect |
| `flutter run --verbose` | Build iOS/Android issues |

---

### Performance checklist (mỗi release)

| Hạng mục | Action |
|---|---|
| List | `ListView.builder` / `GridView.builder` (đã có) |
| Images | `cached_network_image` package |
| Rebuild | Riverpod `select`; tránh `setState` ở root |
| API | Debounce search; cache categories |
| Startup | Lazy init providers; không fetch ở `main()` ngoài restore session |
| Measure | DevTools timeline; target first frame Discover < 2s emulator |

---

### Security checklist

| Hạng mục | v1 mock | v2 API |
|---|---|---|
| Password | Không persist | Không persist; obscure field |
| Token | N/A | `flutter_secure_storage` |
| User JSON | SharedPreferences OK | OK (no secrets) |
| HTTPS | TheMealDB HTTPS | Enforce Dio baseUrl https |
| Input | Trim + length limit search | Same |
| Logout | Clear token + user + optional favorites | Required |
| Secrets | No API keys in repo | `.env` + `--dart-define` nếu cần |
| Android backup | Review `allowBackup` manifest | — |
| iOS | Keychain via secure_storage | — |

---

## Phase 6 — Feature mở rộng (tuần 5+, chọn 1–2)

| Feature | Mô tả | Độ khó |
|---|---|---|
| **Browse by Area** | Filter cuisine (API `filter.php?a=`) | ⭐ |
| **Random meal drawer** | Bottom sheet random + save | ⭐ |
| **Meal share** | `share_plus` share link TheMealDB | ⭐ |
| **Offline banner** | `connectivity_plus` + cached last results | ⭐⭐ |
| **Register flow** | UI + mock register | ⭐⭐ |
| **Onboarding** | 3 slide first launch | ⭐ |

Mỗi feature lặp lại template 8 lớp như Phase 1.

---

## Thứ tự đề xuất (learning path)

```
Tuần 1: F1.1 Dark mode → F1.2 Favorites polish → F1.3 Home UX
Tuần 2: F2.1 go_router → F2.2 Riverpod (Auth + Favorites)
Tuần 3: F3.1 Repository → F3.2 Favorites/user → F3.3 Search history
Tuần 4: F4.1 Auth API-ready → F4.2 401 interceptor
Song song: Lint L1-L2, Test pyramid, Debug/Perf/Security checklist mỗi PR
Tuần 5+: Chọn 1 feature Phase 6
```

---

## Template report mỗi feature (copy)

```markdown
## Feature: [Tên]

### UI
- [ ] Design / wireframe
- [ ] Empty & error states
- [ ] iOS + Android tested

### Data
- [ ] Model
- [ ] API / local storage
- [ ] Mapping verified

### Architecture & State
- [ ] Layer (screen → provider → repo → api)
- [ ] No business logic in build()

### Lint
- [ ] `flutter analyze` clean
- [ ] `dart format` applied

### Test
- [ ] Unit: ...
- [ ] Widget: ...

### Debug
- [ ] DevTools verified
- [ ] Logs added for errors

### Performance
- [ ] No unnecessary rebuilds
- [ ] List/image optimized

### Security
- [ ] No secrets in code
- [ ] No password/token in logs
```

---

## Dependencies dự kiến (theo phase)

| Phase | Package |
|---|---|
| 1 | (không thêm) |
| 2 | `go_router`, `flutter_riverpod` |
| 3 | (optional) `cached_network_image` |
| 4 | `flutter_secure_storage` |
| 6 | `share_plus`, `connectivity_plus` |

---

## Không làm sớm (tránh over-engineering)

- Clean Architecture 4 layer full (domain/usecase) — quá nặng cho mini app
- Firebase — chưa cần
- BLoC + Riverpod cùng lúc — chọn Riverpod
- Microservices / BE riêng — TheMealDB + mock auth đủ học

---

*Cập nhật sau Login v1 + Discover/Favorites/Profile. File login chi tiết: `docs/login-plan.md`.*
