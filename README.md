# Meal Finder

Mini Flutter app: search recipes, xem chi tiết, lưu favorites. Data từ [TheMealDB](https://www.themealdb.com/api.php) (public API, không cần BE).

## Chạy Android

```bash
~/.android/fix-and-start-emulator.sh Pixel_9_Flutter

cd /Users/macbook_221/Projects/Flutter/project-mini/meal_finder
flutter pub get
flutter run -d emulator-5554
```

## Chạy iOS (sau khi cài Xcode xong)

1. Cài Xcode từ App Store (đã mở sẵn trang download).
2. Chạy:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
sudo xcodebuild -license accept
xcodebuild -downloadPlatform iOS

cd ios && pod install && cd ..
flutter run -d ios
```

## Tính năng

- Discover: search + category chips + grid món ăn
- Detail: nguyên liệu + instructions + favorite
- Favorites: lưu local bằng `shared_preferences`
- Random meal (icon xúc xắc trên AppBar)
