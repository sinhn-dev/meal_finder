# Plan: Login (Mock) — Meal Finder

> Mục tiêu report: mô tả **làm gì → vì sao → map FE → kết quả**.
> Nguyên tắc: **UI trước → integrate mock → user info**. Chưa verify password thật.

---

## 1. Goal / Scope

**In scope (v1)**
- Màn Login: 2 field `user_name`, `password`
- Chỉ cần 2 field **có data** → login thành công (mock)
- Sau login: có object **User** (id, userName, displayName)
- App gate: chưa login → Login; đã login → Home (Discover/Favorites)
- Logout
- Persist session (mở lại app vẫn login nếu đã lưu)

**Out of scope (v1 — note “làm sau”)**
- Gọi API thật / JWT / refresh token
- Register, forgot password, OTP
- Biometric, remember-me checkbox (optional v1.1)
- Role / permission
- Encrypt password (không lưu password)

---

## 2. Map FE → Flutter (dùng trong report)

| FE (React/Next) | Flutter (cách mình làm) |
|---|---|
| `/login` page + form | `LoginScreen` + `TextFormField` |
| React Hook Form + Zod (min 1 char) | validate thủ công: `trim().isNotEmpty` |
| `authService.login(dto)` (Axios) | `AuthService.login` mock `Future` delay 300–500ms |
| Zustand `useAuthStore` | `AuthStore extends ChangeNotifier` (giống `FavoritesStore`) |
| `localStorage.setItem('user')` | `SharedPreferences` key `auth_user` |
| `ProtectedRoute` / layout check token | `AuthGate`: `isLoggedIn ? RootShell : LoginScreen` |
| `useQuery(['me'])` sau login | `authStore.currentUser` |
| Logout → clear storage + redirect `/login` | `authStore.logout()` + Gate tự về Login |

Pattern tái sử dụng sẵn trong app: **Store + SharedPreferences + ListenableBuilder** (`FavoritesStore`).

---

## 3. Data model (v1)

```dart
class User {
  final String id;
  final String userName;
  final String displayName;
}
```

Mock login thành công → ví dụ:
- `id`: `'mock-${userName}'`
- `userName`: giá trị user nhập
- `displayName`: userName (hoặc `'Hi, $userName'`)

**Không lưu password.** Chỉ persist `User` JSON.

Login request (sau này đổi thành API):
```dart
class LoginRequest {
  final String userName;
  final String password;
}
```

---

## 4. File sẽ thêm / sửa

| File | Việc |
|---|---|
| `lib/models/user.dart` | User + fromJson/toJson |
| `lib/services/auth_service.dart` | mock login (delay + check non-empty) |
| `lib/services/auth_store.dart` | session: currentUser, login, logout, persist |
| `lib/screens/login_screen.dart` | UI + submit |
| `lib/screens/profile_screen.dart` | (v1 nhỏ) hiện user info + logout |
| `lib/main.dart` | boot `AuthStore`, `AuthGate` |
| `lib/screens/favorites_screen.dart` / `RootShell` | thêm tab Profile hoặc menu logout |

---

## 5. Các step thực hiện (làm tuần tự + note report)

### Phase A — UI only (chưa login thật)

**A1. Vẽ `LoginScreen` (stateless flow, fake button)**
- AppBar / logo / title “Meal Finder”
- Field `user_name` (hint, icon person)
- Field `password` (obscure + icon hiện/ẩn)
- Button “Login” full width
- Optional: text “Demo: nhập bất kỳ user + password”

**Report A1:** Screenshot UI. Nêu widget: `TextFormField`, `FilledButton`, `StatefulWidget` cho hide password. Map FE: JSX form.

**A2. Gắn validation UI (chưa gọi service)**
- Submit: nếu empty → `errorText` dưới field (“Required”)
- Disable button khi đang “giả loading” (optional)

**Report A2:** Giống RHF `formState.errors`. Chỉ client-side.

**A3. Gắn tạm `LoginScreen` làm `home` trong `main.dart`**
- Mục đích: xem UI trên iOS/Android trước khi đụng auth flow
- Sau Phase B mới thay bằng `AuthGate`

**Report A3:** “UI-first: tách visual khỏi business logic.”

---

### Phase B — Integrate mock login

**B1. `AuthService.login(userName, password)`**
- `await Future.delayed(300ms)` giả network
- Nếu `userName.trim().isEmpty || password.trim().isEmpty` → throw `AuthException('Required')`
- Else return `User(...)`
- **Chưa check user/pass đúng sai**

**Report B1:** Giống `async login()` mock / MSW. Sau này chỉ sửa body service → gọi Dio, UI không đổi.

**B2. `AuthStore` (giống FavoritesStore)**
- `create()`: đọc `SharedPreferences` → restore `User?`
- `login()`: gọi service → save user → `notifyListeners()`
- `logout()`: xóa prefs → `currentUser = null` → notify
- `bool get isLoggedIn => currentUser != null`

**Report B2:** Zustand persist. Không lưu password.

**B3. `AuthGate` trong `main.dart`**
```text
AuthStore.isLoggedIn ? RootShell : LoginScreen
```
- `ListenableBuilder` listen `AuthStore`
- Login success → tự nhảy Home (không `Navigator.push` chồng stack)

**Report B3:** Protected layout. Khác FE: không dùng URL `/login`, dùng widget tree swap.

**B4. Loading / error trên LoginScreen**
- `_isSubmitting`: spinner trên button, lock 2 field
- catch `AuthException` → SnackBar hoặc text lỗi dưới form
- `if (!mounted) return` sau await

**Report B4:** `isPending` + toast/inline error. Tránh setState sau dispose.

---

### Phase C — User info sau login

**C1. Profile (tab mới hoặc icon AppBar)**
- Hiện: displayName, userName, id (mock)
- Button Logout → `authStore.logout()` → Gate về Login

**C2. Dùng user ở chỗ khác (nhẹ)**
- AppBar Home: `Hi, {displayName}`
- Sau này: gắn `user.id` vào favorite key (multi-user) — **chưa làm v1**, chỉ note

**Report C1–C2:** Sau login có “session user” giống `useAuth().user`. Logout clear session.

---

## 6. Thinking thêm (nên biết, chọn làm / để sau)

Ghi vào report mục **Considered / Deferred**:

| Chức năng | Nên làm v1? | Lý do |
|---|---|---|
| Persist session | **Có** | UX: mở lại app không login lại; 1 dòng prefs |
| Logout | **Có** | Không có logout = không test được gate |
| Hide/show password | **Có** (UI A1) | Rẻ, UX chuẩn mobile |
| Không lưu password | **Bắt buộc** | Bảo mật + report “security note” |
| Fake delay 300ms | **Có** | Để UI loading có ý nghĩa; giống network |
| Remember me checkbox | Không cần | Persist mặc định cả session là đủ |
| Register | Sau | Scope khác |
| Token + Authorization header | Sau | Khi nối API thật: `AuthInterceptor` Dio |
| 401 → logout | Sau | Khi MealApi có auth |
| Favorite theo user | Sau | Hiện favorite global; multi-account sẽ lẫn |
| Deep link “login xong về detail” | Sau | Mini app chưa cần |
| Splash 1s | Optional | Chỉ nếu restore prefs chậm |
| Keyboard: `textInputAction`, submit bằng Done | **Nên** | Mobile UX |
| `autofillHints` username/password | Optional | iOS/Android autofill |
| Biometric | Không | Overkill |

**Quyết định kiến trúc quan trọng (note report):**
1. Auth là **app-level store** (như Favorites), không nhét state login vào `HomeScreen`.
2. Mock nằm ở **Service**, không nằm trong UI → sau này đổi API không đụng form.
3. Gate bằng **widget swap**, không `push` Login lên Home (tránh Back về login).
4. v1 = **happy path + empty validation**. Sai user/pass “thật” làm Phase D.

---

## 7. Phase D (tương lai — 1 đoạn trong report “Next”)

- `AuthService.login` → `POST /login` Dio
- Response: `{ token, user }`
- Lưu `token` (secure storage nếu cần) + `User`
- `MealApi` interceptor: `Authorization: Bearer`
- 401 → logout
- Validate password policy nếu BE yêu cầu

---

## 8. Checklist test (dùng khi demo / report)

- [ ] Mở app chưa login → thấy Login, không vào Discover
- [ ] Submit trống → lỗi Required, không vào Home
- [ ] Chỉ 1 field có data → vẫn lỗi
- [ ] 2 field có data → loading → vào Home, thấy user (AppBar hoặc Profile)
- [ ] Kill app, mở lại → vẫn login (persist)
- [ ] Logout → về Login, user = null
- [ ] Login lại user khác → user info đổi
- [ ] Android + iOS (hoặc Chrome)

---

## 9. Template note từng step (copy vào report)

```
### Step X — [tên]
- Làm gì:
- File:
- Map FE:
- Kết quả (screenshot / behavior):
- Vấn đề gặp & cách xử lý:
```

Ví dụ:
```
### Step A1 — Login UI
- Làm gì: vẽ 2 TextFormField + button, chưa gọi API
- File: lib/screens/login_screen.dart
- Map FE: trang /login, controlled inputs
- Kết quả: UI chạy iOS simulator
- Vấn đề: keyboard che button → bọc SingleChildScrollView
```

---

## 10. Thứ tự implement đề xuất (1–2 buổi)

1. `User` model  
2. `LoginScreen` UI + validation empty  
3. `AuthService` mock  
4. `AuthStore` + persist  
5. `AuthGate` trong `main.dart`  
6. Profile / greeting + Logout  
7. Test checklist + viết report theo template §9  
