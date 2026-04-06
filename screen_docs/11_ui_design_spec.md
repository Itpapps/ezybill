# EzyQuick LCO v2 — Flutter UI Design Specification

> **Source:** `ezyquick-lco-v2.html` (UI POC — 765 lines)
> **Target:** 100% visual match in Flutter
> **Priority:** This spec overrides the old Android app UI. The Flutter app must look like this POC, not the old Android app.

---

## 1. Design System / Theme

### 1.1 Typography

| Usage | Font | Weight | Package |
|-------|------|--------|---------|
| Body text, labels, buttons | `Plus Jakarta Sans` | 400, 500, 600, 700, 800 | `google_fonts` |
| Numbers, money, codes, mono | `JetBrains Mono` | 500, 600, 700 | `google_fonts` |

**Flutter implementation:**
```dart
// In app_theme.dart
final textTheme = GoogleFonts.plusJakartaSansTextTheme();
// For mono values: GoogleFonts.jetBrainsMono()
```

### 1.2 Color Palette

#### Light Theme
| Token | Hex | Usage |
|-------|-----|-------|
| `--bg` | `#f6f8fb` | Page background |
| `--white` | `#ffffff` | Card background |
| `--red` | `#e53935` | Primary action, brand |
| `--red-soft` | `#fff0f0` | Red tint background |
| `--red-dark` | `#c62828` | Gradient end, pressed |
| `--green` | `#2ecc71` | Success states |
| `--green-soft` | `#eafaf1` | Green tint background |
| `--green-dot` | `#00c853` | Active status dot |
| `--red-dot` | `#ff1744` | Deactivated status dot |
| `--amber` | `#f5a623` | Warning, suspended |
| `--amber-soft` | `#fef9ee` | Amber tint background |
| `--blue` | `#4a90d9` | Info, refresh action |
| `--blue-soft` | `#eef4fb` | Blue tint background |
| `--purple` | `#7e57c2` | Pairing action |
| `--purple-soft` | `#f3eefa` | Purple tint background |
| `--ink` | `#1a1d23` | Primary text |
| `--ink-80` | `#2d3139` | Secondary text |
| `--ink-60` | `#4a5060` | Tertiary text |
| `--ink-40` | `#7a8194` | Muted text, icons |
| `--ink-20` | `#b4bac8` | Placeholder, dividers |
| `--ink-10` | `#d8dce6` | Borders |
| `--ink-05` | `#eef0f4` | Subtle backgrounds |

#### Dark Theme
| Token | Hex |
|-------|-----|
| `--bg` | `#0f1219` |
| `--white` | `#1a2030` |
| `--ink` | `#e8ecf2` |
| `--ink-80` | `#c8cdd8` |
| `--ink-60` | `#a0a8b8` |
| `--ink-40` | `#6b7590` |
| `--ink-20` | `#3d4560` |
| `--ink-10` | `#252d40` |
| `--ink-05` | `#1a2235` |

#### Avatar Color Palette (6 colors, assigned by name hash)
| Name | Background | Text |
|------|-----------|------|
| Blue | `#dbeafe` | `#3b82f6` |
| Green | `#d1fae5` | `#059669` |
| Amber | `#fef3c7` | `#d97706` |
| Pink | `#fce7f3` | `#db2777` |
| Purple | `#ede9fe` | `#7c3aed` |
| Gray | `#f1f5f9` | `#64748b` |

### 1.3 Spacing & Radii

| Token | Value | Usage |
|-------|-------|-------|
| `--radius` | `14px` | Cards, sheets |
| `--radius-sm` | `10px` | Buttons, small cards |
| `--radius-pill` | `100px` | Pill tabs, search bar, CTAs |

### 1.4 Shadows

| Token | Value |
|-------|-------|
| `--shadow-sm` | `0 1px 3px rgba(0,0,0,0.04)` |
| `--shadow-card` | `0 2px 8px rgba(0,0,0,0.04), 0 0 1px rgba(0,0,0,0.06)` |
| `--shadow-lg` | `0 8px 30px rgba(0,0,0,0.08)` |

### 1.5 Animations

| Name | Duration | Easing | Usage |
|------|----------|--------|-------|
| `fadeUp` | 350ms | ease-out | Section entrance (staggered: a1=50ms, a2=100ms, a3=150ms, a4=200ms, a5=250ms) |
| `slideUp` | 300ms | ease-out | Bottom sheets, modals |
| `fadeIn` | 200ms | ease-out | Overlays |
| `popIn` | 300ms | ease-out | Toasts |

---

## 2. Screen Components — Detailed Specs

### 2.1 Header (Sticky, z-index: 50)

```
+----------------------------------------------------------+
| [Avatar:SL] Sri Lakshmi Cable      [Theme][Lang][Bell*]  |
|             LCO-4721 · Kukatpally                        |
|                                                          |
| [Wallet] ₹12,450 balance              [+ Top Up]        |
|          Last: ₹5,000 on 22 Mar 2026                    |
+----------------------------------------------------------+
```

**Header Identity:**
- Avatar: 38x38px, border-radius 12px, gradient `red → red-dark`, white text, font-weight 800, 14px
- Name: 15px, weight 700, color `--ink`
- Business: 10px, weight 500, color `--ink-40`, format: `LCO-{code} · {location}`

**Header Action Buttons:**
- Size: 36x36px, border-radius 10px, background `--bg`
- Icons: 18px, color `--ink-40`
- Notification badge: 7px dot, red, 2px white border, positioned top-right

**Wallet Bar:**
- Background: `--bg`, border-radius 8px, padding 6px 10px
- Wallet icon: 24x24px, green-soft bg, green icon
- Amount: 15px, weight 800, JetBrains Mono
- "balance" label: 10px, `--ink-40`, Plus Jakarta Sans
- Last recharge: 8px, `--ink-20`
- Top-up button: red pill, 10px, weight 700, shadow `rgba(229,57,53,0.2)`

### 2.2 Overview Section

```
+----------------------------------------------------------+
| OVERVIEW                                                  |
| +--------+  +----------+ +----------+                     |
| | DONUT  |  | ● 1,623  | | ● 142    |                    |
| | 1,847  |  |  Active  | | Inactive |                    |
| | Total  |  +----------+ +----------+                     |
| +--------+  | ● 82     | | ● 88%    |                    |
|             |  Fresh   | |  Health  |                    |
|             +----------+ +----------+                     |
+----------------------------------------------------------+
```

**Donut Chart:**
- 70x70px SVG, 3px stroke width, rotate -90deg
- Green arc (active %), Red arc (inactive %), Amber arc (fresh %)
- Center: total count (15px, weight 800, mono) + "Total" label (8px, `--ink-40`)

**Legend Grid:**
- 2x2 grid, 5px gap
- Each card: white bg, border-radius 8px, padding 6px 8px, card shadow
- Dot: 8x8px, border-radius 2px
- Value: 13px, weight 800, mono, colored per status
- Label: 8px, `--ink-40`
- Tappable — switches to corresponding tab

### 2.3 Alert Chips (Horizontal Scroll)

```
| [✓ 48 Recharged] [⚠ 23 Expiring 7d] [💳 5 Wallet ›] [⚡ 12 Overdue] |
```

- Horizontal scroll, 6px gap, padding 4px 14px
- Each chip: white bg, border-radius 8px, padding 5px 10px, card shadow
- Icon container: 18x18px, border-radius 5px, colored bg
- Value: 12px, weight 800, mono
- Label: 7px, `--ink-40`, weight 600
- "Wallet ›" chip toggles wallet history panel

### 2.4 Wallet History Panel (Toggleable)

- Card: white bg, border-radius 14px, card shadow
- Title: 10px, weight 700, `--ink-20`, uppercase, letter-spacing 0.06em
- Rows: 12px, `--ink-60`, padding 6px 0, bottom border `--ink-05`
- Date: `--ink-20`
- Shows/hides with toggle animation

### 2.5 Search Bar

```
+----------------------------------------------------------+
| [🔍] Phone, Name, or Setup Box ID          [→]          |
+----------------------------------------------------------+
```

- White bg, 1.5px border `--ink-10`, border-radius pill
- On focus: border color changes to `--red`
- Input: 13px, weight 500
- Go button: 34px circle, red bg, white arrow icon
- Placeholder: `--ink-20`

### 2.6 Tab Pills

```
[ Active 1623 | Inactive 142 | Fresh 82 | Misc ]
```

- Background: `--ink-05`, border-radius pill, padding 3px
- Each tab: flex 1, padding 9px, 12px font, weight 600
- **Per-tab active colors:**
  - Active: bg `#e6f9ee`, text `#059669`
  - Inactive: bg `#fee2e2`, text `#dc2626`
  - Fresh: bg `#d1fae5`, text `#047857`
  - Misc: bg `#fef3c7`, text `#b45309`
- Badge: inline, min-width 18px, 9px font, weight 700, colored per tab

### 2.7 Sort & Filter Bar

```
| [↓ Name] [≡ List]                      Showing 1623 |
```

- Sort button: white bg, 1px border `--ink-05`, 11px, weight 600
- Cycles through: Name → Due Date → Area
- View toggle: same style, toggles List/Card view
- Count: 10px, `--ink-20`, weight 600

### 2.8 Subscriber Card

```
+----------------------------------------------------------+
| [AV] Raj Patel                              ●  (green)   |
|      +91 98765 43210  [STB-7842-301]       13d left     |
|------------------------------------------------------|
| [⚡ Recharge] [↻ Refresh] [📦 Upgrade] [⏻ Deactivate] |
+----------------------------------------------------------+
```

**Top Row (tappable → opens detail sheet):**
- Avatar: 40x40px circle, colored bg per hash, initials 13px weight 700
- Name: 13px, weight 700, `--ink`
- Meta: 10px, `--ink-40`, mobile + STB code in `<code>` style
- Code style: 9px mono, `--ink-60`, bg `--ink-05`, padding 1px 4px, radius 3px
- Status dot: 9px circle (green-dot / red-dot / amber / blue)
- Due text: 9px, weight 500, color dynamic (red if overdue, amber if ≤7d, `--ink-20` otherwise)
- Due format: "Xd overdue" / "Xd left" / "DD Mon YYYY" / "New box"

**Action Row (context-aware per status):**
- Flex row, top border `--ink-05`
- Each button: flex 1, column layout, 44px min-height (Apple HIG)
- Icon: 16px, colored per action type
- Label: 8px, weight 600, `--ink-20` (or colored for Recharge)
- Right border `--ink-05` between buttons (last has none)
- **Active status:** Recharge (red), Refresh (blue), Upgrade (purple), Deactivate (red-dot)
- **Deactivated status:** Recharge (red), Activate (green), Refresh (blue), Upgrade (purple)
- **Fresh status:** Activate (green), Add Pkg (amber), Refresh (blue), Pairing (ink-40)

### 2.9 Alphabetical Side Bar

- Vertical column, right side, sticky top 120px
- Each letter: 22x20px, 8px font, weight 700
- Default: `--ink-20`; has-items: `--ink-40`; active: red bg, white text
- "#" button at top = "All" (clear filter)
- Tappable to filter subscriber list by first letter

### 2.10 Subscriber Detail Bottom Sheet

```
+----------------------------------------------------------+
|                    [====]                                  |
| Subscriber Detail                              [X]       |
|                                                          |
| [AV] Raj Patel                                           |
|      ● Active · Brundavan                                |
|                                                          |
| +------------+  +------------+                            |
| | MOBILE     |  | STB SERIAL |                            |
| | +91 987... |  | STB-7842.. |                            |
| +------------+  +------------+                            |
| | VC NUMBER  |  | STB TYPE   |                            |
| | 027484255  |  | HD         |                            |
| +------------+  +------------+                            |
| | DUE DATE   |  | MONTHLY    |                            |
| | 13 Apr 2026|  | ₹247       |                            |
| +------------+  +------------+                            |
|                                                          |
| ACTIVE PACKAGES                                          |
| BOUQUET 3              Exp: 13 Apr 2026                  |
| ETV HD Family          Exp: 13 Apr 2026                  |
| FTA 1                  Exp: 13 Apr 2026                  |
|                                                          |
| (●Recharge) (●Packages) (●Refresh) (●Pairing) (●Support)|
+----------------------------------------------------------+
```

**Sheet:** white bg, radius 24px top, max-height 88vh, scrollable
**Handle:** centered 36x4px bar, `--ink-10`, radius 2px
**Header:** 17px title weight 800, close button 32px circle
**Profile:** 52px avatar, 16px name weight 700, 12px status line
**Detail Grid:** 2-column, 1px gap with `--ink-05` bg
- Cell: white bg, 12px 16px padding
- Label: 9px, weight 600, `--ink-20`, uppercase, letter-spacing 0.06em
- Value: 13px, weight 700, mono
- Value.danger: `--red` (overdue), Value.success: `--green-dot`

**Packages List:**
- Label: 10px, weight 700, `--ink-20`, uppercase
- Row: flex between, 8px padding vertical, bottom border
- Name: 12px, weight 600, `--ink-80`
- Exp: 10px, `--ink-20`, mono

**Circle Actions (5 buttons):**
- Flex, space-around, padding 18px 16px 22px
- Circle: 52px, border-radius 50%, bg `--bg`, card shadow
- Icon: 22px, colored per action
- Label: 10px, weight 600, `--ink-60`
- Actions: Recharge (red), Packages (ink-60), Refresh (blue), Pairing (purple), Support (ink-40)

### 2.11 Bottom Navigation

```
| [Home*] [Subscribers] [Reports] [Transactions] [Settings] |
```

- Sticky bottom, white bg, top border `--ink-05`
- Safe area inset padding
- Icon container: 28x28px, radius 8px
- Active: red-soft bg, red icon, red label weight 700
- Inactive: no bg, `--ink-40` icon + label
- Label: 9px, weight 600
- 5 tabs: Home, Subscribers, Reports, Transactions, Settings

### 2.12 Wallet Top-Up Modal (Bottom Sheet)

```
+----------------------------------------------------------+
|                    [====]                                  |
| Wallet Top-Up                                [X]         |
|                                                          |
| +-----------+  +-----------+                              |
| |   ₹1,000  |  |  ₹2,500  |                              |
| +-----------+  +-----------+                              |
| |   ₹5,000  |  | ₹10,000  |                              |
| +-----------+  +-----------+                              |
|                                                          |
| CUSTOM AMOUNT                                            |
| [₹ Enter amount...]                                     |
|                                                          |
| [========= Add ₹5,000 to Wallet =========]              |
+----------------------------------------------------------+
```

- Preset grid: 2 columns, 8px gap
- Preset button: `--bg`, 1.5px border `--ink-05`, radius 12px, 14px padding, mono 15px weight 700
- Selected: red border, red-soft bg
- Custom input: same search-box style with ₹ prefix
- Confirm: full width, red bg, pill radius, 14px weight 700, red shadow
- Disabled: `--ink-10` bg, `--ink-40` text

### 2.13 Recharge Modal (Bottom Sheet)

```
+----------------------------------------------------------+
|                    [====]                                  |
| Recharge                                     [X]         |
| Raj Patel · 027484255 · Monthly: ₹247                   |
|                                                          |
| [ 1 Month | 3 Months (5% off) | 6 Months | 12 Months ] |
|                                                          |
| Subtotal (1mo × ₹247)                        ₹247       |
| Total                                         ₹247       |
|                                                          |
| [========= Pay ₹247 from Wallet =========]              |
+----------------------------------------------------------+
```

- Context line: 12px, `--ink-40`, bold name + VC + monthly bill
- Plan toggle: pill-style, same as tab pills
- Active plan: white bg, ink text, shadow
- Discount badge: 9px, green-dot color
- Summary card: `--bg`, radius 14px, 14px padding
- Summary rows: 12px, label `--ink-40`, value mono weight 600
- Total row: top border, 14px/16px weight 800
- Confirm: same as top-up but shows "Pay ₹X from Wallet"

### 2.14 Toast Notifications

- Fixed, top center, z-index 999
- Pill shape, 13px weight 600, card shadow
- Success: `#e8f8ee` bg, `#15803d` text, `#bbf7d0` border
- Info: `#eef4fb` bg, `#1d4ed8` text, `#bfdbfe` border
- Auto-dismiss: 2800ms
- Animation: popIn 300ms

### 2.15 AI Floating Action Button

- Fixed, bottom-right, 52px circle
- Gradient: `red → red-dark`, white icon
- Shadow: `0 4px 20px rgba(229,57,53,0.3)`
- BETA badge: amber bg, 7px text, weight 800, white border
- Position: 70px from bottom, 20px from right

---

## 3. Flutter Widget Mapping

| POC Component | Flutter Widget | File Path |
|--------------|---------------|-----------|
| Header | `SliverAppBar` or custom `Container` | `lib/presentation/common/widgets/app_header.dart` |
| Wallet Bar | `WalletBar` widget | `lib/presentation/common/widgets/wallet_bar.dart` |
| Overview Donut | `CustomPainter` or `fl_chart` PieChart | `lib/presentation/screens/home/widgets/overview_donut.dart` |
| Legend Grid | `OverviewLegend` widget | `lib/presentation/screens/home/widgets/overview_legend.dart` |
| Alert Chips | `AlertChipsRow` (horizontal ListView) | `lib/presentation/screens/home/widgets/alert_chips.dart` |
| Wallet History | `WalletHistoryPanel` (animated toggle) | `lib/presentation/screens/home/widgets/wallet_history_panel.dart` |
| Search Bar | `AppSearchBar` reusable | `lib/presentation/common/widgets/app_search_bar.dart` |
| Pill Tabs | `PillTabBar` reusable | `lib/presentation/common/widgets/pill_tab_bar.dart` |
| Subscriber Card | `SubscriberCard` with status-aware actions | `lib/presentation/common/widgets/subscriber_card.dart` |
| Alpha Sidebar | `AlphabetSidebar` | `lib/presentation/common/widgets/alphabet_sidebar.dart` |
| Detail Sheet | `showModalBottomSheet` + `SubscriberDetailSheet` | `lib/presentation/screens/customers/widgets/subscriber_detail_sheet.dart` |
| Circle Actions | `CircleActionBar` reusable | `lib/presentation/common/widgets/circle_action_bar.dart` |
| Bottom Nav | `BottomNavigationBar` in `AppShell` | `lib/presentation/common/widgets/app_shell.dart` |
| Top-Up Modal | `WalletTopUpSheet` | `lib/presentation/screens/home/widgets/wallet_topup_sheet.dart` |
| Recharge Modal | `RechargeSheet` | `lib/presentation/screens/payments/widgets/recharge_sheet.dart` |
| Toast | `ScaffoldMessenger` or custom overlay | `lib/presentation/common/widgets/app_toast.dart` |
| AI FAB | `FloatingActionButton` | in `AppShell` |
| Status Dot | `StatusDot` reusable | `lib/presentation/common/widgets/status_dot.dart` |
| Avatar | `UserAvatar` (initials + hash color) | `lib/presentation/common/widgets/user_avatar.dart` |
| Mono Text | Helper extension `Text.mono()` | `lib/core/utils/text_extensions.dart` |

---

## 4. Status Color Mapping

| Status | Dot Color | Usage |
|--------|-----------|-------|
| `active` | `#00c853` (green-dot) | Active subscriber |
| `deactivated` | `#ff1744` (red-dot) | Deactivated subscriber |
| `suspended` | `#f5a623` (amber) | Suspended / on hold |
| `fresh` | `#4a90d9` (blue) | New / unactivated box |

---

## 5. Context-Aware Actions Matrix

| Status | Action 1 | Action 2 | Action 3 | Action 4 |
|--------|----------|----------|----------|----------|
| **Active** | Recharge (red) | Refresh (blue) | Upgrade (purple) | Deactivate (red-dot) |
| **Deactivated** | Recharge (red) | Activate (green) | Refresh (blue) | Upgrade (purple) |
| **Fresh** | Activate (green) | Add Pkg (amber) | Refresh (blue) | Pairing (ink-40) |

---

## 6. Bottom Navigation Mapping to Routes

| Tab | Icon | Route | Screen |
|-----|------|-------|--------|
| Home | `home` | `/` | Dashboard + Overview + Subscriber List |
| Subscribers | `users` | `/subscribers` | Subscriber Management (search, filter, bulk) |
| Reports | `bar-chart` | `/reports` | Reports Hub |
| Transactions | `dollar` | `/transactions` | Payment History + PG Transactions |
| Settings | `settings` | `/settings` | Settings Screen |

---

## 7. Dark Theme Implementation

Flutter should use `ThemeMode.system` with manual override toggle.

```dart
// Theme toggle stored in SharedPreferences key: 'ezyquick-theme'
// Values: 'light' | 'dark'
// Default: system

// All color tokens should be defined in AppColors with both light/dark variants
// Use Theme.of(context).extension<AppColors>() for access
```

Every component must support dark theme. The POC has full dark theme CSS — use the dark token values from Section 1.2.

---

## 8. Icon System

The POC uses inline SVG symbols. Flutter equivalent:

| Approach | Package |
|----------|---------|
| **Recommended:** Lucide Icons | `lucide_icons` (already in pubspec) |
| Alternative: Custom SVG | `flutter_svg` with asset SVGs |

Icon mapping from POC → Lucide:
| POC Symbol | Lucide Equivalent |
|-----------|------------------|
| `i-wallet` | `LucideIcons.wallet` |
| `i-bell` | `LucideIcons.bell` |
| `i-search` | `LucideIcons.search` |
| `i-zap` | `LucideIcons.zap` |
| `i-package` | `LucideIcons.package` |
| `i-refresh` | `LucideIcons.refreshCw` |
| `i-link` | `LucideIcons.link` |
| `i-headphones` | `LucideIcons.headphones` |
| `i-power` | `LucideIcons.power` |
| `i-home` | `LucideIcons.home` |
| `i-users` | `LucideIcons.users` |
| `i-bar-chart` | `LucideIcons.barChart3` |
| `i-dollar` | `LucideIcons.dollarSign` |
| `i-settings` | `LucideIcons.settings` |
| `i-plus` | `LucideIcons.plus` |
| `i-x` | `LucideIcons.x` |
| `i-globe` | `LucideIcons.globe` |
| `i-sun` | `LucideIcons.sun` |
| `i-moon` | `LucideIcons.moon` |
| `i-bot` | `LucideIcons.bot` |
| `i-tv` | `LucideIcons.tv` |
| `i-sort` | `LucideIcons.arrowDownUp` |
| `i-list` | `LucideIcons.list` |
| `i-check-circle` | `LucideIcons.checkCircle` |
| `i-alert-tri` | `LucideIcons.alertTriangle` |
| `i-credit-card` | `LucideIcons.creditCard` |
| `i-message` | `LucideIcons.messageSquare` |
| `i-box` | `LucideIcons.box` |

---

*This spec should be the primary UI reference for the Flutter implementation. Every pixel, color, spacing, and animation should match this POC.*
