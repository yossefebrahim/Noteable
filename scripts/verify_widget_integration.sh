#!/bin/bash
# Widget Integration Verification Script
# This script verifies that all widget components are properly configured

set -e

echo "========================================"
echo "Widget Integration Verification Script"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track results
PASS=0
FAIL=0
WARN=0

# Function to print and track results
check_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ PASS${NC}: $2"
        ((PASS++))
    elif [ $1 -eq 1 ]; then
        echo -e "${RED}✗ FAIL${NC}: $2"
        ((FAIL++))
    else
        echo -e "${YELLOW}⚠ WARN${NC}: $2"
        ((WARN++))
    fi
}

echo "=== Flutter Service Verification ==="

# Check WidgetChannel exists
if [ -f "lib/services/platform/channels/widget_channel.dart" ]; then
    check_result 0 "WidgetChannel exists"
else
    check_result 1 "WidgetChannel not found"
fi

# Check DataSyncService exists
if [ -f "lib/services/platform/data_sync_service.dart" ]; then
    check_result 0 "DataSyncService exists"
else
    check_result 1 "DataSyncService not found"
fi

# Check app router has deep link route
if grep -q "/note-detail/:id" lib/presentation/router/app_router.dart; then
    check_result 0 "App router has deep link route"
else
    check_result 1 "App router missing deep link route"
fi

echo ""
echo "=== iOS Widget Verification ==="

# Check iOS widget files
IOS_WIDGET_FILES=(
    "ios/NoteableWidgets/NoteableWidgetsBundle.swift"
    "ios/NoteableWidgets/NoteableWidgets.swift"
    "ios/NoteableWidgets/Shared/NoteDataModel.swift"
    "ios/NoteableWidgets/Shared/WidgetDataStore.swift"
    "ios/NoteableWidgets/Shared/WidgetColors.swift"
    "ios/NoteableWidgets/Widgets/QuickCaptureWidget.swift"
    "ios/NoteableWidgets/Widgets/RecentNotesWidget.swift"
    "ios/NoteableWidgets/Widgets/PinnedNotesWidget.swift"
)

for file in "${IOS_WIDGET_FILES[@]}"; do
    if [ -f "$file" ]; then
        check_result 0 "iOS: $(basename $file)"
    else
        check_result 1 "iOS missing: $file"
    fi
done

# Check iOS Info.plist for app groups
if grep -q "AppGroup" ios/Runner/Info.plist; then
    check_result 0 "iOS Info.plist has AppGroup configuration"
else
    check_result 1 "iOS Info.plist missing AppGroup"
fi

# Check iOS Info.plist for URL scheme
if grep -q "noteable" ios/Runner/Info.plist; then
    check_result 0 "iOS Info.plist has URL scheme"
else
    check_result 1 "iOS Info.plist missing URL scheme"
fi

# Check AppDelegate for deep link handling
if grep -q "handleDeepLink" ios/Runner/AppDelegate.swift; then
    check_result 0 "iOS AppDelegate has deep link handler"
else
    check_result 1 "iOS AppDelegate missing deep link handler"
fi

# Check AppDelegate for widget refresh
if grep -q "refreshAllWidgets\|reloadTimelines" ios/Runner/AppDelegate.swift; then
    check_result 0 "iOS AppDelegate has widget refresh"
else
    check_result 1 "iOS AppDelegate missing widget refresh"
fi

echo ""
echo "=== Android Widget Verification ==="

# Check Android widget files
ANDROID_WIDGET_FILES=(
    "android/app/src/main/kotlin/com/example/noteable_app/widget/NoteDataModel.kt"
    "android/app/src/main/kotlin/com/example/noteable_app/widget/WidgetDataStore.kt"
    "android/app/src/main/kotlin/com/example/noteable_app/widget/QuickCaptureWidget.kt"
    "android/app/src/main/kotlin/com/example/noteable_app/widget/RecentNotesWidget.kt"
    "android/app/src/main/kotlin/com/example/noteable_app/widget/PinnedNotesWidget.kt"
)

for file in "${ANDROID_WIDGET_FILES[@]}"; do
    if [ -f "$file" ]; then
        check_result 0 "Android: $(basename $file)"
    else
        check_result 1 "Android missing: $file"
    fi
done

# Check Android widget info files
ANDROID_INFO_FILES=(
    "android/app/src/main/res/xml/quick_capture_widget_info.xml"
    "android/app/src/main/res/xml/recent_notes_widget_info.xml"
    "android/app/src/main/res/xml/pinned_notes_widget_info.xml"
)

for file in "${ANDROID_INFO_FILES[@]}"; do
    if [ -f "$file" ]; then
        check_result 0 "Android: $(basename $file)"
    else
        check_result 1 "Android missing: $file"
    fi
done

# Check Android widget layouts
ANDROID_LAYOUT_FILES=(
    "android/app/src/main/res/layout/quick_capture_widget.xml"
    "android/app/src/main/res/layout/recent_notes_widget.xml"
    "android/app/src/main/res/layout/pinned_notes_widget.xml"
)

for file in "${ANDROID_LAYOUT_FILES[@]}"; do
    if [ -f "$file" ]; then
        check_result 0 "Android: $(basename $file)"
    else
        check_result 1 "Android missing: $file"
    fi
done

# Check AndroidManifest for widget receivers
if grep -q "QuickCaptureWidget" android/app/src/main/AndroidManifest.xml; then
    check_result 0 "AndroidManifest has QuickCaptureWidget receiver"
else
    check_result 1 "AndroidManifest missing QuickCaptureWidget receiver"
fi

if grep -q "RecentNotesWidget" android/app/src/main/AndroidManifest.xml; then
    check_result 0 "AndroidManifest has RecentNotesWidget receiver"
else
    check_result 1 "AndroidManifest missing RecentNotesWidget receiver"
fi

if grep -q "PinnedNotesWidget" android/app/src/main/AndroidManifest.xml; then
    check_result 0 "AndroidManifest has PinnedNotesWidget receiver"
else
    check_result 1 "AndroidManifest missing PinnedNotesWidget receiver"
fi

# Check AndroidManifest for deep link intent filter
if grep -q "noteable" android/app/src/main/AndroidManifest.xml; then
    check_result 0 "AndroidManifest has deep link configuration"
else
    check_result 1 "AndroidManifest missing deep link configuration"
fi

# Check MainActivity for deep link handling
if grep -q "handleDeepLink" android/app/src/main/kotlin/com/example/noteable_app/MainActivity.kt; then
    check_result 0 "Android MainActivity has deep link handler"
else
    check_result 1 "Android MainActivity missing deep link handler"
fi

# Check MainActivity for widget refresh
if grep -q "refreshAllWidgets" android/app/src/main/kotlin/com/example/noteable_app/MainActivity.kt; then
    check_result 0 "Android MainActivity has widget refresh"
else
    check_result 1 "Android MainActivity missing widget refresh"
fi

echo ""
echo "=== Widget Color Theme Verification ==="

# Check iOS widget colors
if grep -q "appBackground\|appSurface\|appTextPrimary\|appTextSecondary\|appAccent" ios/NoteableWidgets/Shared/WidgetColors.swift; then
    check_result 0 "iOS WidgetColors has theme colors"
else
    check_result 1 "iOS WidgetColors missing theme colors"
fi

# Check Android widget colors (light)
if [ -f "android/app/src/main/res/values/widget_colors.xml" ]; then
    check_result 0 "Android has light theme widget colors"
else
    check_result 1 "Android missing light theme widget colors"
fi

# Check Android widget colors (dark)
if [ -f "android/app/src/main/res/values-night/widget_colors.xml" ]; then
    check_result 0 "Android has dark theme widget colors"
else
    check_result 1 "Android missing dark theme widget colors"
fi

echo ""
echo "=== Test Files Verification ==="

# Check for integration test
if [ -f "test/integration/widget_workflow_e2e_test.dart" ]; then
    check_result 0 "Integration test file exists"
else
    check_result 2 "Integration test file not found (run verification with Flutter SDK)"
fi

echo ""
echo "========================================"
echo "Verification Summary"
echo "========================================"
echo -e "${GREEN}Passed: $PASS${NC}"
echo -e "${RED}Failed: $FAIL${NC}"
echo -e "${YELLOW}Warnings: $WARN${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✓ All critical checks passed!${NC}"
    echo ""
    echo "Next Steps:"
    echo "1. Run manual testing using E2E_VERIFICATION_CHECKLIST.md"
    echo "2. Test on physical devices for full verification"
    echo "3. Run 'flutter test' for unit tests (requires Flutter SDK)"
    echo "4. Run 'flutter analyze' for code analysis (requires Flutter SDK)"
    exit 0
else
    echo -e "${RED}✗ Some checks failed. Please review and fix.${NC}"
    exit 1
fi
