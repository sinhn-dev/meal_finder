# Phase 6 Learning Wave — Plan chi tiết & Tracking

> File làm việc: đánh dấu checkbox / trạng thái khi xong từng PR.
> Roadmap dài hạn: [`product-roadmap.md`](./product-roadmap.md)
> Checklist 8 lớp mỗi feature: [`implementation-plan.md`](./implementation-plan.md)

**Mục tiêu đợt này:** học platform Flutter (icon, local DB, offline, permission, maps) + siết MVVM — **không** làm backend.

---

## Quyết định đã chốt

| Hạng mục | Chọn | Lý do |
|---|---|---|
| Maps | `flutter_map` + OpenStreetMap | Không cần Google API key |
| Location | Permission + demo GPS → TheMealDB `strArea` | Học native; gắn app hiện tại |
| Local DB | **Drift** (SQLite type-safe) | Học DB trên device, không BE |
| State UI | **MVVM** (Riverpod Notifier = ViewModel) | Không rewrite sang MVP |
| App icon | PR riêng, làm đầu | Evidence nhanh, độc lập |
| Workflow | 1 feature = 1 branch = 1 PR → merge `main` | Dễ tracking / portfolio |

---

## Tracking tổng quan

| ID | Branch | Trạng thái | PR | Merge vào main |
|---|---|---|---|---|
| **P1** | `feature/app-icon` | Đã merge | — | Đã merge |
| **P2** | `feature/mvvm-home-notifier` | Đã merge | — | Đã merge |
| **P3** | `feature/local-db-cache` | Xong (chờ PR) | — | — |
| **P4** | `feature/offline-middleware` | Xong (chờ PR; based on P3) | — | — |
| **P5** | `feature/location-maps-cuisine` | Chưa làm | — | — |

**Phụ thuộc**

```text
P1 (độc lập)
P2 → P3 → P4 → P5
```

- P3 cần P2 (Home ViewModel dễ gắn cache).
- P4 cần P3 (offline đọc Drift).
- P5 làm sau P4 (có thể song song sau P4 nếu cần, nhưng plan tuần tự).

---

## Git workflow (mỗi PR)

```bash
git checkout main
git pull origin main
git checkout -b feature/<tên-branch>

# ... implement + test ...

git add .
git commit -m "feat(pN): <mô tả ngắn>"
git push -u origin HEAD
# mở PR → merge main → cập nhật bảng Tracking ở trên
```

Sau merge: đánh dấu checkbox trong file này + cập nhật [`implementation-plan.md`](./implementation-plan.md).

---

## P1 — App icon

| | |
|---|---|
| **Branch** | `feature/app-icon` |
| **Packages** | `flutter_launcher_icons` (dev) |
| **Trạng thái** | Đã xong (chờ merge) |

### Mục đích

Đổi icon Flutter mặc định → brand Meal Finder (Android + iOS).

### Việc làm

- [x] Tạo `assets/icon/app_icon.png` (1024×1024)
- [x] Thêm `flutter_launcher_icons` + cấu hình trong `pubspec.yaml`
- [x] Chạy generator (`dart run flutter_launcher_icons`)
- [ ] Verify: gỡ app → cài lại → thấy icon mới (manual trên device)

### File dự kiến

| File | Thay đổi |
|---|---|
| `assets/icon/app_icon.png` | Asset nguồn |
| `pubspec.yaml` | assets + flutter_launcher_icons config |
| `android/.../mipmap-*` | Generated |
| `ios/Runner/Assets.xcassets/AppIcon.appiconset/` | Generated |

### 8 lớp

| Lớp | Việc | Xong |
|---|---|---|
| UI | Icon native launcher | [x] |
| Data | PNG asset | [x] |
| Arch | Không đổi runtime | [x] |
| Lint | `flutter analyze` | [x] |
| Test | Không bắt buộc unit | [x] |
| Debug | Cài lại app (không hot reload) | [ ] |
| Perf | N/A | [x] |
| Security | N/A | [x] |

### Done khi

- [x] Icon Meal Finder generated cho Android + iOS
- [ ] Manual: gỡ app cũ → cài lại → thấy icon trên home screen

### Commit gợi ý

`feat(p1): add Meal Finder launcher icon`

---

## P2 — MVVM: Home ViewModel

| | |
|---|---|
| **Branch** | `feature/mvvm-home-notifier` |
| **Packages** | (đã có Riverpod) |
| **Trạng thái** | Đã xong (chờ merge) |

### Mục đích

Tách **View** (`HomeScreen`) khỏi **ViewModel** (fetch state). Map FE: component vs Zustand/hook store.

### Vấn đề hiện tại

`lib/screens/home_screen.dart` vừa UI vừa giữ `_meals`, `_isLoading`, `_bootstrap`, `_search`…

### Kiến trúc đích

```text
HomeScreen (View)
    ↓ ref.watch / ref.read
HomeMealsNotifier + HomeMealsState (ViewModel)
    ↓
MealRepository (Model / data access)
```

### Việc làm

- [x] `HomeMealsState`: categories, selectedCategory, meals, isLoading, error, query
- [x] `HomeMealsNotifier` (+ `homeMealsProvider`): bootstrap, loadCategory, search, openRandom
- [x] Notifier gọi `mealRepositoryProvider` + `searchHistoryStoreProvider.add` sau search OK
- [x] `HomeScreen`: chỉ TextField, Debouncer, chips UI, `ref.watch(homeMealsProvider)`
- [x] Unit test fake repository (loading → data / error)

### Không làm trong P2

- Đổi folder `presentation/domain/data` toàn app
- Drift / offline / location

### File dự kiến

| File | Thay đổi |
|---|---|
| `lib/providers/home_meals_notifier.dart` (hoặc tương tự) | State + Notifier |
| `lib/providers/app_providers.dart` | Export / wire nếu cần |
| `lib/screens/home_screen.dart` | Chỉ View |
| `test/home_meals_notifier_test.dart` | Unit |

### 8 lớp

| Lớp | Việc | Xong |
|---|---|---|
| UI | Home UX giữ nguyên | [x] |
| Data | Vẫn qua MealRepository | [x] |
| Arch | View / ViewModel tách rõ | [x] |
| Lint | analyze sạch | [x] |
| Test | Notifier unit tests | [x] |
| Debug | Breakpoint trong notifier | [x] |
| Perf | Ít rebuild không cần thiết | [x] |
| Security | N/A | [x] |

### Done khi

- [x] Home không gọi API/repo trực tiếp trong State (chỉ qua notifier)
- [x] `flutter test` pass

### Commit gợi ý

`feat(p2): extract HomeMealsNotifier ViewModel (MVVM)`

---

## P3 — Local DB cache (Drift)

| | |
|---|---|
| **Branch** | `feature/local-db-cache` |
| **Packages** | `drift`, `drift_flutter`, `sqlite3_flutter_libs`, `path_provider`, `path`, `drift_dev`, `build_runner` |
| **Trạng thái** | Xong (chờ PR / merge) |

### Mục đích

Lưu cache món + categories **trên máy** (SQLite). Nền cho P4 offline. **Không** làm server/BE.

### Schema v1

| Bảng | Cột chính |
|---|---|
| `cached_meals` | id, name, thumbnail, category?, area?, **sourceKey**, updatedAt |
| `cached_categories` | name, updatedAt |

`sourceKey` ví dụ: `category:Beef`, `search:pasta`, `area:Vietnamese`.

**Không làm v1:** cache full meal detail (Detail offline) — để sau nếu cần. Offline UI = P4.

### Arch

```text
MealRepositoryImpl
  ├── MealApi (remote)
  └── MealLocalDataSource (Drift)
        online success → write cache
        getCached*(sourceKey) → đọc local
```

### Việc làm

- [x] Định nghĩa Drift tables + generate code
- [x] `MealLocalDataSource` (DAO)
- [x] `MealRepositoryImpl` write-through sau search / byCategory / categories
- [x] Mở DB trong `main()` + `mealLocalDataSourceProvider`; test dùng in-memory
- [x] Test DAO insert/read + repo ghi cache

### File dự kiến

| File | Thay đổi |
|---|---|
| `lib/data/local/app_database.dart` | Drift DB |
| `lib/data/local/meal_cache_keys.dart` | `category:` / `search:` / `area:` |
| `lib/data/local/meal_local_data_source.dart` | DAO |
| `lib/repositories/meal_repository.dart` | Inject local + write cache |
| `lib/main.dart` / providers | Wire DB |
| `test/meal_local_data_source_test.dart` | Unit |

### 8 lớp

| Lớp | Việc | Xong |
|---|---|---|
| UI | Không đổi (cache silent) | [x] |
| Data | Drift schema + DAO | [x] |
| Arch | Remote + Local trong repository | [x] |
| Lint | analyze + generated files | [x] |
| Test | DAO + repo cache write | [x] |
| Debug | Log sourceKey khi ghi/đọc | [x] |
| Perf | PK `(id, sourceKey)` đủ cho v1 | [x] |
| Security | Chỉ cache public meal data | [x] |

### Done khi

- [x] Load category/search online → DB có rows (write-through)
- [x] Đọc được cache qua `getCached*` (P4 sẽ dùng khi offline)

### Commit gợi ý

`feat(p3): add Drift local cache for meals and categories`

---

## P4 — Offline middleware

| | |
|---|---|
| **Branch** | `feature/offline-middleware` |
| **Packages** | `connectivity_plus` |
| **Trạng thái** | Xong (chờ PR; branch dựa trên P3) |

### Mục đích

Detect mất mạng → banner + đọc cache Drift; không crash.

### Hành vi

| Tình huống | Kết quả |
|---|---|
| Offline + có cache | Hiện list cache + banner “You’re offline — showing cached meals” |
| Offline + không cache | Error rõ / empty có message |
| Online fail + có cache | Fallback cache + `isFromCache` |
| Online OK | Như hiện tại + ghi cache (đã có từ P3) |

### Việc làm

- [x] `ConnectivityService` / `isOnlineProvider` (stream)
- [x] Banner trên `AppShell`
- [x] `MealRepository`: offline → đọc cache; online fail → fallback cache (`FetchResult`)
- [x] `HomeMealsState`: `isOffline`, `isFromCache` (chip trên Home)
- [x] Ưu tiên logic trong **repository** (dễ test); giữ `AuthInterceptor` như F4
- [x] Test offline → cache; offline empty → error; online fail → fallback

### File dự kiến

| File | Thay đổi |
|---|---|
| `lib/services/connectivity_service.dart` | Online/offline |
| `lib/models/fetch_result.dart` | `data` + `isFromCache` |
| `lib/screens/app_shell.dart` | Banner |
| `lib/repositories/meal_repository.dart` | Offline path |
| `lib/providers/home_meals_notifier.dart` | isOffline / isFromCache |
| `test/...` | Offline scenarios |

### 8 lớp

| Lớp | Việc | Xong |
|---|---|---|
| UI | Banner + cache indicator | [x] |
| Data | Đọc Drift khi offline | [x] |
| Arch | Connectivity + repo fallback | [x] |
| Lint | analyze | [x] |
| Test | Offline / fallback cases | [x] |
| Debug | Log online/offline + cache hit | [x] |
| Perf | Stream connectivity (không poll) | [x] |
| Security | Offline path không đụng token | [x] |

### Done khi

- [x] Airplane mode sau khi đã load data → list + banner, không crash (manual)
- [x] Unit tests cover offline / fallback

### Commit gợi ý

`feat(p4): offline banner and Drift cache fallback`

---

## P5 — Location + Maps (OSM) + cuisine demo

| | |
|---|---|
| **Branch** | `feature/location-maps-cuisine` |
| **Packages** | `geolocator`, `flutter_map`, `latlong2` |
| **Trạng thái** | Chưa làm |

### Mục đích

Học **permission** + **map UI**; demo GPS → Area TheMealDB → list món. **Không** claim nhà hàng thật.

### Native config

- [ ] iOS `Info.plist`: `NSLocationWhenInUseUsageDescription`
- [ ] Android manifest: `ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION`

### UX flow

1. Nút **“Near me (demo)”** (Home AppBar hoặc Profile)
2. Xin quyền — Deny → dialog + mở Settings
3. Lấy lat/lng → `flutter_map` (OSM) + marker
4. Lat/lng → Area bằng bảng hardcode (vd. VN → `Vietnamese`, default `Italian`)
5. Label UI: **“Demo mapping, not real restaurants”**
6. API `filter.php?a=` (`byArea` trên repository) → hiện list món

### Việc làm

- [ ] `LocationService` (permission + position)
- [ ] `latLngToCuisineArea(lat, lng)` + unit test
- [ ] Screen/sheet: map + disclaimer + list (hoặc đẩy vào Home notifier)
- [ ] `MealApi.byArea` / `MealRepository.byArea` nếu chưa có
- [ ] Handle deny / service disabled

### Không làm

- Google Maps API key
- Claim “restaurants near you”

### File dự kiến

| File | Thay đổi |
|---|---|
| `lib/services/location_service.dart` | Permission + GPS |
| `lib/utils/cuisine_area_mapper.dart` | Lat/lng → Area |
| `lib/screens/near_me_screen.dart` (hoặc sheet) | Map + list |
| `lib/services/meal_api.dart` + repository | `byArea` |
| `ios/Runner/Info.plist` | Usage description |
| `android/.../AndroidManifest.xml` | Permissions |
| `test/cuisine_area_mapper_test.dart` | Unit |

### 8 lớp

| Lớp | Việc | Xong |
|---|---|---|
| UI | Map + disclaimer + list / deny dialog | [ ] |
| Data | GPS + byArea API | [ ] |
| Arch | LocationService tách khỏi UI | [ ] |
| Lint | analyze | [ ] |
| Test | Mapper unit; permission mock nếu được | [ ] |
| Debug | Log area sau map | [ ] |
| Perf | Map tiles lazy | [ ] |
| Security | Chỉ WhenInUse; không log PII thừa | [ ] |

### Done khi

- [ ] Allow → map + list theo Area
- [ ] Deny → không crash, có message

### Commit gợi ý

`feat(p5): near-me demo with location permission and OSM map`

---

## Checklist trước mỗi lần merge

- [ ] `dart format .`
- [ ] `flutter analyze` (không error)
- [ ] `flutter test`
- [ ] Manual smoke trên iOS hoặc Android
- [ ] Cập nhật bảng **Tracking tổng quan** trong file này
- [ ] Cập nhật [`implementation-plan.md`](./implementation-plan.md) (đánh dấu xong)
- [ ] Hot restart / reinstall nếu đổi native (icon, permission, pods)

---

## Map sang FE (nhanh)

| Mobile | FE tương đương |
|---|---|
| MVVM Notifier | Zustand / React Query hook |
| Drift local DB | IndexedDB / localForage |
| Offline banner + cache | Service worker / React Query offline |
| Geolocator permission | Browser Geolocation API |
| flutter_map OSM | Leaflet / Mapbox |

---

## Thứ tự bắt đầu

1. Đọc file này → hiểu P1–P5  
2. `git checkout -b feature/app-icon` từ `main` mới nhất  
3. Implement **P1** trước — không gộp P2 vào cùng branch  
4. Merge → tick checkbox → làm P2  

Khi sẵn sàng code, nói: **implement P1** (hoặc “implement Phase 6 từ P1”).
