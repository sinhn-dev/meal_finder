# Meal Finder — Kế hoạch triển khai

> File làm việc: xong feature nào thì đánh dấu feature đó.
> Roadmap kiến trúc dài hạn: [`product-roadmap.md`](./product-roadmap.md)
> Login đã xong: [`login-plan.md`](./login-plan.md)
> Phase 6 (icon, MVVM, DB, offline, maps): [`phase-6-learning-wave.md`](./phase-6-learning-wave.md)

**Nguyên tắc mỗi tính năng:** giao diện → dữ liệu → kiến trúc & state → lint → test → debug → hiệu năng → bảo mật

---

## Hiện trạng

| Tính năng | Trạng thái |
|---|---|
| Login giả lập + cổng xác thực + lưu phiên đăng nhập | Đã xong |
| Khám phá / Chi tiết món / Yêu thích / Hồ sơ | Đã xong |
| Dark mode | Đã xong (F1.1) |
| Vuốt xóa yêu thích + kéo để làm mới | Đã xong (F1.2) |
| Lời chào trên Home + tìm kiếm có debounce | Đã xong (F1.3) |
| Điều hướng `go_router` | Đã xong (F2.1) |
| Riverpod | Đã xong (F2.2) |
| Tầng repository cho món ăn | Đã xong (F3.1) |
| Favorites theo userId | Đã xong (F3.2) |
| Lịch sử tìm kiếm | Đã xong (F3.3) |
| Auth API-ready (token + 401) | Đã xong (F4.1 + F4.2) |
| App icon (P1) | Đã merge |
| MVVM Home ViewModel (P2) | Đã xong (chờ merge) |

---

## Quy trình 8 lớp (bắt buộc)

Mỗi tính năng phải đi đủ 8 bước, giống cách làm FE:

| # | Lớp | Làm gì | Xong khi |
|---|---|---|---|
| 1 | **Giao diện (UI)** | Widget, trạng thái trống/lỗi, chạy iOS + Android | Nhìn được, dùng được |
| 2 | **Dữ liệu (Data)** | Model, API, bộ nhớ local, ánh xạ JSON | Nguồn data rõ ràng |
| 3 | **Kiến trúc & State** | Store/provider, không nhét logic vào `build()` | UI chỉ gọi method |
| 4 | **Lint** | `flutter analyze` + `dart format` | Không còn cảnh báo |
| 5 | **Test** | Unit + widget (thành công + rỗng) | `flutter test` pass |
| 6 | **Debug** | DevTools / log chỗ lỗi | Biết đặt breakpoint ở đâu |
| 7 | **Hiệu năng** | Rebuild, list, debounce, cache | List/theme không giật |
| 8 | **Bảo mật** | Không in secret ra log, không lưu password | Review nhanh 1 phút |

**So với FE:** UI = JSX → Data = API/`localStorage` → State = Zustand → Lint = ESLint → Test = React Testing Library → Debug = DevTools → Hiệu năng = memo/debounce → Bảo mật = không lộ token.

---

## Giai đoạn 1 — Làm mượt bản MVP

### F1.1 Cài đặt & chế độ tối — **đã xong**

| Lớp | Việc đã làm | Trạng thái |
|---|---|---|
| UI | Nút chọn System / Light / Dark trên màn Hồ sơ | Xong |
| Data | Lưu vào `SharedPreferences` với key `theme_mode` | Xong |
| Kiến trúc | `ThemeStore` (ChangeNotifier) | Xong |
| Lint | `AppConstants`, analyze sạch | Xong |
| Test | `test/theme_store_test.dart` | Xong |
| Debug | `debugPrint` khi đổi theme | Xong |
| Hiệu năng | Chỉ `MaterialApp` vẽ lại khi đổi theme | Xong |
| Bảo mật | Không lưu thông tin nhạy cảm | Xong |

**Xong khi:** đổi theme → tắt app → mở lại vẫn đúng theme đã chọn.

**File liên quan**

- `lib/config/app_constants.dart`
- `lib/services/theme_store.dart`
- `lib/screens/profile_screen.dart` (thêm nút chọn theme)
- `lib/main.dart` (`themeMode` + `ListenableBuilder`)
- `test/theme_store_test.dart`

---

### F1.2 Làm mượt màn Yêu thích — **đã xong**

| Lớp | Việc | Trạng thái |
|---|---|---|
| UI | `RefreshIndicator` + vuốt trái xóa + SnackBar Undo | Xong |
| Data | `removeById` / `insertAt` / `reload` ghi `SharedPreferences` | Xong |
| Kiến trúc | Logic xóa trong `FavoritesStore`, UI chỉ gọi | Xong |
| Lint | `context.mounted` trước SnackBar | Xong |
| Test | `test/favorites_store_test.dart` | Xong |
| Debug | `debugPrint` khi xóa / restore / reload | Xong |
| Hiệu năng | `ValueKey(meal.id)` trên `Dismissible` | Xong |
| Bảo mật | Chỉ log id, không PII | Xong |

**Xong khi:** vuốt xóa, Undo trong SnackBar, kéo xuống không crash (kể cả list trống).

**File liên quan**

- `lib/services/favorites_store.dart`
- `lib/screens/favorites_screen.dart`
- `test/favorites_store_test.dart`

### F1.3 Trải nghiệm màn Home — **đã xong**

| Lớp | Việc | Trạng thái |
|---|---|---|
| UI | AppBar `Hi, {tên}`; gõ search tự tìm sau 300ms | Xong |
| Data | `SearchQuery.sanitize` trim + cắt 40 ký tự trước khi gọi API | Xong |
| Kiến trúc | `Debouncer` + `SearchQuery` tách khỏi widget | Xong |
| Lint | Hằng số `searchDebounce` / `searchMaxLength` | Xong |
| Test | `test/search_query_test.dart` | Xong |
| Debug | `debugPrint` từ khóa đã sanitize | Xong |
| Hiệu năng | Debounce 300ms, hủy timer khi đổi category / clear / submit | Xong |
| Bảo mật | Cắt độ dài query, Dio encode sẵn | Xong |

**Xong khi:** thấy lời chào theo user đăng nhập; gõ nhanh chỉ gọi API 1 lần sau khi dừng 300ms.

**File liên quan**

- `lib/config/app_constants.dart`
- `lib/utils/search_query.dart`
- `lib/utils/debouncer.dart`
- `lib/screens/home_screen.dart`
- `lib/main.dart` (truyền `auth` vào Home)
- `test/search_query_test.dart`

---

## Giai đoạn 2 — Điều hướng & quản lý state

### F2.1 go_router — **đã xong**

| Lớp | Việc | Trạng thái |
|---|---|---|
| UI | Bottom nav `StatefulShellRoute`; Detail full-screen Back | Xong |
| Data | `mealId` trên path; `MealSummary` qua `extra` | Xong |
| Kiến trúc | `createAppRouter` + `authRedirect`; bỏ AuthGate | Xong |
| Lint | Route constants `AppRoutes` | Xong |
| Test | `test/auth_redirect_test.dart` | Xong |
| Debug | `debugPrint` khi redirect | Xong |
| Hiệu năng | IndexedStack giữ state tab (search không mất) | Xong |
| Bảo mật | Không đưa password vào URL/`extra` | Xong |

**Xong khi:** Back từ Detail về list; logout về `/login`; login xong vào Discover.

**File liên quan**

- `lib/router/app_routes.dart`
- `lib/router/auth_redirect.dart`
- `lib/router/app_router.dart`
- `lib/screens/app_shell.dart`
- `lib/main.dart` (`MaterialApp.router`)
- `test/auth_redirect_test.dart`

### F2.2 Riverpod — **đã xong**

| Lớp | Việc đã làm | Trạng thái |
|---|---|---|
| UI | `ConsumerWidget` / `ConsumerStatefulWidget`; `ref.watch` thay ListenableBuilder | Xong |
| Data | Providers bọc store/API sẵn có; override async store trong `main()` | Xong |
| Kiến trúc | `authStoreProvider`, `favoritesStoreProvider`, `themeStoreProvider`, `mealApiProvider`, `goRouterProvider` | Xong |
| Lint | Analyze sạch; không prop-drill store | Xong |
| Test | `test/app_providers_test.dart` + widget test bọc `ProviderScope` | Xong |
| Debug | `debugPrint` khi tạo GoRouter; breakpoint tại provider/store | Xong |
| Hiệu năng | `ref.read` auth trong router — không recreate GoRouter mỗi login | Xong |
| Bảo mật | Provider không expose password | Xong |

**Xong khi:** không truyền store qua constructor / GoRoute builder; root không còn `ListenableBuilder`.

**File liên quan**

- `lib/providers/app_providers.dart`
- `lib/main.dart` (`ProviderScope` + overrides)
- `lib/router/app_router.dart` (chỉ nhận `AuthStore` cho redirect)
- `lib/screens/*.dart` (Consumer*)
- `test/app_providers_test.dart`
- `test/helpers/pump_app.dart`

Home vẫn giữ local fetch state (`_bootstrap` / `_search`); gọi data qua `ref.read(mealRepositoryProvider)`.

---

## Giai đoạn 3 — Tầng dữ liệu

### F3.1 MealRepository — **đã xong**

| Lớp | Việc đã làm | Trạng thái |
|---|---|---|
| UI | Home / Detail gọi `mealRepositoryProvider` (không đổi UX) | Xong |
| Data | `MealRepository` + `MealRepositoryImpl` → `MealApi` | Xong |
| Kiến trúc | UI → provider → repository → Dio; `mealApiProvider` chỉ cho DI thấp | Xong |
| Lint | Analyze sạch | Xong |
| Test | `test/meal_repository_test.dart` (fake API + cache) | Xong |
| Debug | `debugPrint` theo method ở repository | Xong |
| Hiệu năng | Cache categories TTL 5 phút | Xong |
| Bảo mật | Vẫn HTTPS TheMealDB; UI không đụng Dio | Xong |

**Xong khi:** màn hình không import/`read` `MealApi` trực tiếp.

**File liên quan**

- `lib/repositories/meal_repository.dart`
- `lib/providers/app_providers.dart` (`mealRepositoryProvider`)
- `lib/screens/home_screen.dart`, `lib/screens/meal_detail_screen.dart`
- `test/meal_repository_test.dart`

- **F3.2** Favorites theo `userId` — **đã xong**
- **F3.3** Lịch sử tìm kiếm (tối đa 10 từ khóa, lưu local) — **đã xong**

---

### F3.3 Search history — **đã xong**

| Lớp | Việc đã làm | Trạng thái |
|---|---|---|
| UI | Chips "Recent searches" dưới SearchBar; tap → search lại | Xong |
| Data | `search_history_{userId}`; tối đa 10 keyword | Xong |
| Kiến trúc | `SearchHistoryStore` + `searchHistoryStoreProvider` | Xong |
| Lint | Analyze sạch | Xong |
| Test | `test/search_history_store_test.dart` (dedupe, max, multi-user) | Xong |
| Debug | `debugPrint` khi add / switchUser / clearSession | Xong |
| Hiệu năng | Giới hạn 10 items | Xong |
| Bảo mật | Chỉ lưu keyword đã sanitize | Xong |

**Xong khi:** search thành công → chip xuất hiện; tap chip → gọi lại search.

**File liên quan**

- `lib/services/search_history_store.dart`
- `lib/providers/app_providers.dart`
- `lib/screens/home_screen.dart`
- `lib/main.dart`, `lib/screens/login_screen.dart`, `lib/screens/profile_screen.dart`
- `test/search_history_store_test.dart`

---

### F3.2 Favorites theo userId — **đã xong**

| Lớp | Việc đã làm | Trạng thái |
|---|---|---|
| UI | Không đổi UX Favorites / heart icon | Xong |
| Data | Key `favorite_meals_{userId}`; migrate key global cũ một lần | Xong |
| Kiến trúc | `FavoritesStore.switchUser` / `clearSession`; login + logout wired | Xong |
| Lint | Analyze sạch | Xong |
| Test | Multi-user + migration + clearSession trong `favorites_store_test.dart` | Xong |
| Debug | `debugPrint` khi switchUser / migrate / clearSession | Xong |
| Hiệu năng | Chỉ reload khi đổi user | Xong |
| Bảo mật | Data tách theo user; logout xóa in-memory | Xong |

**Xong khi:** user A và B có favorites riêng; login lại A vẫn thấy list cũ.

**File liên quan**

- `lib/config/app_constants.dart` (`favoriteMealsKeyFor`)
- `lib/services/favorites_store.dart`
- `lib/main.dart`, `lib/screens/login_screen.dart`, `lib/screens/profile_screen.dart`
- `test/favorites_store_test.dart`

---

## Giai đoạn 4 — Đăng nhập bản 2 (sẵn sàng API thật) — **đã xong**

### F4.1 + F4.2 Auth API-ready — **đã xong**

| Lớp | Việc đã làm | Trạng thái |
|---|---|---|
| UI | Login giữ nguyên; invalid credentials khi user ≠ `demo`; SnackBar session expired | Xong |
| Data | `AuthSession` `{ user, token }`; token trong `flutter_secure_storage` | Xong |
| Kiến trúc | `AuthRepository` + `TokenStorage` + `ApiClient`/`AuthInterceptor` + `SessionHandler` | Xong |
| Lint | Analyze sạch | Xong |
| Test | `auth_test.dart`, `api_client_test.dart`, login widget tests | Xong |
| Debug | Dio `LogInterceptor` (debug); redact Authorization header | Xong |
| Hiệu năng | Interceptor async read token per request | Xong |
| Bảo mật | Không lưu/log password; token xóa khi logout/401 | Xong |

**Xong khi:** login `demo` + password → có token; logout xóa token; 401 → logout + SnackBar.

**File liên quan**

- `lib/repositories/auth_repository.dart`
- `lib/services/token_storage.dart`
- `lib/services/api_client.dart`
- `lib/services/session_handler.dart`
- `lib/services/auth_store.dart`
- `lib/main.dart` (`ApiClient`, `scaffoldMessengerKey`)
- `test/auth_test.dart`, `test/api_client_test.dart`

---

## Giai đoạn 5 — Chất lượng (làm mỗi lần đẩy code)

- Lint: `flutter analyze`, `dart format`
- Test: unit cho service/model + widget cho màn chính
- Debug: Inspector + breakpoint trong store
- Hiệu năng: `GridView.builder`, sau này cache ảnh
- Bảo mật: không lưu password; không in token ra log

---

## Mẫu báo cáo (copy cho mỗi tính năng)

```markdown
## Tính năng: [tên]

### Giao diện (UI)
- Làm gì:
- Ảnh chụp / hành vi:

### Dữ liệu (Data)
- Model / chỗ lưu / API:

### Kiến trúc & State
- Store / luồng xử lý:

### Lint
- `flutter analyze`:

### Test
- Unit:
- Widget:

### Debug
- Breakpoint / log:

### Hiệu năng
- Rebuild / list / network:

### Bảo mật
- Secret / dữ liệu lưu local:

### So với FE
-
```

---

## Thứ tự làm

1. F1.1 Chế độ tối — đã xong
2. F1.2 Vuốt xóa yêu thích + kéo làm mới — đã xong
3. F1.3 Lời chào + debounce tìm kiếm — đã xong
4. F2.1 go_router — đã xong
5. F2.2 Riverpod — đã xong
6. F3.1 MealRepository — đã xong
7. F3.2 Favorites theo userId — đã xong
8. F3.3 Search history — đã xong
9. F4.1 + F4.2 Auth API-ready — đã xong
10. Phase 6 Learning Wave — **làm tiếp** (xem [`phase-6-learning-wave.md`](./phase-6-learning-wave.md))
    - P1 App icon — **đã merge**
    - P2 MVVM Home — **đã xong** (branch `feature/mvvm-home-notifier`)
    - P3 Drift cache → P4 Offline → P5 Location + Maps
