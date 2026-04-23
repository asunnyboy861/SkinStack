# SkinStack - iOS App Development Guide

## Executive Summary

**SkinStack** is a smart skincare layering app that transforms how users build, optimize, and follow their daily skincare routines. Unlike existing apps that only check ingredient safety OR list checklists, SkinStack is the first app to combine conflict detection, AM/PM smart allocation, scientific step ordering, wait-time timers, and skin journaling into a single, privacy-first experience.

**Core Value Proposition**: Input your products → Get a scientifically-ordered AM/PM routine with conflict warnings and wait-time timers.

**Key Differentiators**:
1. Only app that outputs a complete scientific AM/PM step table from product input
2. Only app with built-in wait-time timer + push reminders (Retinol 20min, AHA 3-5min)
3. Only app with one-time $4.99 purchase (no subscription fatigue)
4. Only app with 100% local storage + zero data collection
5. Only app linking skin journal entries to product effectiveness tracking
6. Daily active design: AM/PM 2x/day usage pattern

**Target Market**: US women aged 25-40 spending $50-200/month on skincare products

**Technical Stack**: Swift + SwiftUI + SwiftData + Vision + UserNotifications + Swift Charts

## Competitive Analysis

| Feature | Skincare Routine (Mento) | Skin Bliss | INCI Beauty | FeelinMySkin | **SkinStack** |
|---------|--------------------------|------------|-------------|--------------|---------------|
| Conflict Detection | Basic | Advanced | Advanced | Advanced | **Deep + Multi-ingredient** |
| AM/PM Auto-Assign | Yes | Partial | No | Manual | **Smart Auto-Assign** |
| Step Ordering | Category-based | AI-based | No | Manual | **Science + Texture Sort** |
| Wait-Time Timer | Yes (basic) | No | No | No | **Timer + Push Reminders** |
| OCR Ingredient Scan | No | Yes | Yes | Limited | **Vision OCR** |
| Skin Journal | Basic | Yes | No | Yes | **Product-Linked Tracking** |
| Pricing | $3.99 one-time | $4.99/mo subscription | Free + subscription | $9.99/yr subscription | **$4.99 one-time** |
| Data Privacy | Cloud | Cloud | Cloud | Cloud | **100% Local** |
| Daily Engagement | Checklist | Diary | Tool | Diary | **AM/PM + Timer = 2x/day** |

**Market Gap Verified**: No existing app combines conflict detection + AM/PM auto-assign + wait-time timer + skin journal in one package.

## Technical Architecture

### Architecture Pattern: MVVM + Repository
- **View** → SwiftUI views with @Observable ViewModels
- **ViewModel** → Business logic, state management
- **Repository** → Data access abstraction over SwiftData
- **Service/Engine** → Pure logic (ConflictDetectionEngine, RoutineGenerator, IngredientScanner)

### Data Flow
```
User Action → View → ViewModel.method() → Repository → SwiftData Model
Model Change → @Query → View Auto-Refresh
```

### Technology Stack
| Technology | Purpose |
|-----------|---------|
| Swift 5.9+ | Primary language |
| SwiftUI | UI framework (iOS 17+) |
| SwiftData | Local persistence (@Model, @Query) |
| Vision | OCR ingredient scanning |
| UserNotifications | Wait-time push reminders |
| Swift Charts | Skin trend visualization |
| StoreKit 2 | In-App Purchase (Non-consumable) |

### Module Structure & File Organization
```
SkinStack/
├── App/
│   └── SkinStackApp.swift
├── Models/
│   ├── Product.swift
│   ├── SkinJournalEntry.swift
│   ├── ProductUsageLog.swift
│   └── DailyRoutine.swift
├── Enums/
│   ├── ProductCategory.swift
│   ├── ProductTexture.swift
│   ├── SkinCondition.swift
│   └── SkinConcern.swift
├── Services/
│   ├── ConflictDetectionEngine.swift
│   ├── RoutineGenerator.swift
│   ├── IngredientScanner.swift
│   ├── IngredientDatabase.swift
│   └── NotificationManager.swift
├── ViewModels/
│   ├── RoutineViewModel.swift
│   ├── ProductViewModel.swift
│   ├── JournalViewModel.swift
│   └── PurchaseManager.swift
├── Views/
│   ├── Today/
│   │   ├── TodayView.swift
│   │   ├── AMRoutineView.swift
│   │   ├── PMRoutineView.swift
│   │   └── RoutineStepView.swift
│   ├── Products/
│   │   ├── ProductsView.swift
│   │   ├── AddProductView.swift
│   │   └── ScanIngredientView.swift
│   ├── Journal/
│   │   ├── JournalView.swift
│   │   └── AddJournalEntryView.swift
│   ├── Timer/
│   │   └── WaitTimeTimerView.swift
│   ├── Conflicts/
│   │   ├── ConflictDetailView.swift
│   │   └── ConflictListView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── PaywallView.swift
│   │   └── ContactSupportView.swift
│   └── Onboarding/
│       └── OnboardingView.swift
├── Theme/
│   └── SkinStackColors.swift
└── Utilities/
    └── Extensions.swift
```

## Implementation Flow

### Week 1: Data Foundation + Core Algorithm
1. Define SwiftData models (Product, SkinJournalEntry, ProductUsageLog, DailyRoutine)
2. Build ConflictDetectionEngine with 30+ conflict rules
3. Build IngredientDatabase with 500+ ingredient mappings
4. Build RoutineGenerator with AM/PM allocation + scientific sorting

### Week 2: Routine Generator + Product Management
1. Implement AM/PM smart allocator
2. Implement scientific sorting engine (pH low→high, thin→thick texture)
3. Build product add flow (manual input)
4. Build product search with preset database

### Week 3: Main UI + Timer
1. Build Today view with AM/PM routine cards
2. Build routine step views with check-off functionality
3. Build wait-time timer with circular progress + push notifications
4. Build conflict warning display

### Week 4: Enhanced Features + OCR
1. Implement Vision OCR ingredient scanner
2. Build skin journal with photo capture
3. Build effect tracking with Swift Charts
4. Build onboarding flow

### Week 5: Polish + Launch
1. Dark mode support
2. IAP integration (PurchaseManager + Paywall)
3. Bug fixes and edge cases
4. App Store assets preparation

## UI/UX Design Specifications

### Design Philosophy
**Clean Science × Soft Feminine × Apple Native**

- "Science-Backed" — Clean, organized, trustworthy (not flashy beauty app)
- "Softly Feminine" — Warm tones, rounded corners, light textures (not cold medical app)
- "Apple Native" — Follow HIG, native components first (zero learning curve)
- "Glanceable" — See today's routine in 5 seconds (clear information hierarchy)

### Color System
| Role | Color | Hex | Usage |
|------|-------|-----|-------|
| Primary | Warm Rose | #E8838A | Buttons, accents, active states |
| Primary Light | Light Rose | #F5B5BA | Backgrounds, hover states |
| Secondary | Lavender | #9B8EC4 | Secondary actions, tags |
| Secondary Light | Light Lavender | #D4CCE8 | Backgrounds |
| Conflict | Red | #E85D5D | Avoid-level conflicts |
| Caution | Amber | #F0A840 | Caution-level conflicts |
| Safe | Green | #5DC47E | Synergistic combos, success |
| Background | Warm White | #FFF8F6 | Main background |
| Card | White | #FFFFFF | Card backgrounds |

### Navigation Structure
- **TabView** with 4 tabs: Today | Products | Journal | Settings
- Today tab: AM/PM routine cards side by side
- Products tab: Product list + Add button
- Journal tab: Calendar + entries
- Settings tab: Preferences, Pro upgrade, About

### Key UI Patterns
1. **Routine Cards**: Glassmorphism cards with step-by-step checklist
2. **Conflict Badges**: Color-coded severity badges (Red=Avoid, Yellow=Caution, Green=Safe)
3. **Timer Ring**: Circular progress ring with countdown
4. **Skin Rating**: Emoji-based 5-point scale
5. **iPad Layout**: Max width 720pt for content, centered

### Apple HIG Compliance
- Use native SF Symbols for all icons
- Dynamic Type support throughout
- Dark mode with semantic colors
- Haptic feedback on key interactions
- Standard navigation patterns (TabView, NavigationStack)
- Privacy-first: no data collection, no account required

## Code Generation Rules

1. **Architecture**: MVVM + Repository pattern
2. **State Management**: @Observable (iOS 17+), NOT ObservableObject on @Observable classes
3. **Data Persistence**: SwiftData with @Model, @Query
4. **All SwiftData attributes**: Must be optional OR have default values
5. **All SwiftData relationships**: Must have inverse relationships
6. **No hardcoded version numbers**: Read from Bundle.main
7. **iPad layout**: Always add `.frame(maxWidth: 720).frame(maxWidth: .infinity)` to main ScrollView content
8. **Never use `.tabViewStyle(.sidebarAdaptable)`**
9. **Use `Color.accentColor`** instead of `ShapeStyle.accent`
10. **No iOS 18+ APIs** when targeting iOS 17+
11. **No comments in code** unless explicitly asked
12. **100% local storage**: No cloud, no accounts, no analytics
13. **Color extensions**: Use Color.skinStackPrimary pattern
14. **StoreKit 2**: For IAP with Product.products(for:), product.purchase(), Transaction.updates

## Testing & Validation Standards

### Build Verification
- Must compile with zero errors on both iPhone and iPad simulators
- Must support Dynamic Type
- Must support Dark Mode

### Feature Testing
1. Product CRUD: Add, edit, archive products
2. Conflict Detection: Verify all 30+ rules trigger correctly
3. AM/PM Allocation: Photosensitizing → PM only, Vitamin C → AM preferred
4. Routine Sorting: Cleanser first, Sunscreen last (AM), pH low→high, thin→thick
5. Timer: Start, pause, complete, push notification
6. OCR: Scan ingredient label → parse INCI names
7. Journal: Create entry, rate skin, link products
8. IAP: Purchase Pro, restore, verify entitlement

### Simulator Requirements
- iPhone XS Max (6.5" display)
- iPad Pro 13-inch (M4) (12.9" display)

## Build & Deployment Checklist

1. [ ] Bundle ID: com.zzoutuo.SkinStack
2. [ ] iOS Deployment Target: 17.0
3. [ ] Version: 1.0.0 (from Xcode settings)
4. [ ] Capabilities: Camera (OCR), Notifications (timer)
5. [ ] App Icon generated and configured
6. [ ] StoreKit configuration file for IAP testing
7. [ ] Privacy permissions: Camera, Notifications
8. [ ] Policy pages deployed (Support, Privacy, Terms)
9. [ ] App Store metadata validated (keytext.md)
10. [ ] Screenshots captured for iPhone and iPad
11. [ ] Build succeeds on both simulators
12. [ ] Push to GitHub repository
