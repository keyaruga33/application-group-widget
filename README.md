<div align="center">

<img src="images/logo.png" width="130" alt="Application Group logo">

# Application Group &nbsp;·&nbsp; گروه برنامه‌ها

### Group your apps, folders, and documents into clean, responsive containers on KDE Plasma&nbsp;6

<p>
  <img src="https://img.shields.io/badge/Plasma-6-1d99f3?style=for-the-badge&logo=kde&logoColor=white" alt="Plasma 6">
  <img src="https://img.shields.io/badge/Qt-6-41cd52?style=for-the-badge&logo=qt&logoColor=white" alt="Qt 6">
  <img src="https://img.shields.io/badge/License-GPL--3.0-blue?style=for-the-badge" alt="GPL-3.0">
  <img src="https://img.shields.io/badge/version-1.0.2-8e44ad?style=for-the-badge" alt="v1.0.2">
</p>

<p>
  <a href="README.md"><b>English</b></a>
  &nbsp;•&nbsp;
  <a href="README_FA.md">فارسی</a>
</p>

<p>
  <a href="https://www.opendesktop.org/p/2378509/"><b>Get it on the KDE Store</b></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/keyaruga33/application-group-widget/releases">Releases</a>
  &nbsp;·&nbsp;
  <a href="https://github.com/keyaruga33/application-group-widget/issues">Report a Bug</a>
</p>

</div>

---

<img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/folder.svg" width="22" align="top"> &nbsp;**Application Group** is a lightweight KDE Plasma 6 widget built to solve a simple, annoying problem: desktop clutter and endless menu diving. 

Instead of scattering shortcuts across multiple monitors or digging through full-screen application launchers just to start your workday, Application Group lets you bundle your everyday tools, project folders, `.desktop` launchers, and files into tidy, customized boxes.

Keep a group open directly on your **desktop** as an interactive workspace dashboard, or drop it into your **panel** where it collapses into a single icon with a live item counter badge. Click it, and an identical popup opens instantly. Drag in files from Dolphin, pin the popup open while sorting things out, pick icons with KDE's native icon browser, and let the widget adapt to your system colors on its own.

## <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/image.svg" width="26" align="top"> &nbsp;Screenshots

<div align="center">

<table>
  <tr>
    <td align="center"><img src="images/screenshots/app-group-desktop.png" width="420" alt="Application Group on Desktop"><br><sub><b>Desktop Mode</b> — your project workspace and folders right on the wallpaper</sub></td>
    <td align="center"><img src="images/screenshots/app-group-panel.png" width="420" alt="Application Group in Panel"><br><sub><b>Panel Mode</b> — quick popup access with live badge &amp; pin support</sub></td>
  </tr>
</table>

<table>
  <tr>
    <td align="center"><img src="images/screenshots/app-group-config-general.png" width="270" alt="General Settings"><br><sub>General &amp; Panel Settings</sub></td>
    <td align="center"><img src="images/screenshots/app-group-config-appearance.png" width="270" alt="Appearance Settings"><br><sub>Appearance &amp; Grid Customization</sub></td>
    <td align="center"><img src="images/screenshots/app-group-config-items.png" width="270" alt="Items Management"><br><sub>Items Manager &amp; Reordering</sub></td>
  </tr>
</table>

</div>

## <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/sparkles.svg" width="26" align="top"> &nbsp;What it does

No external dependencies, no background daemon eating memory, and no tricky configuration. Add it to your layout and it is ready to work.

### <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/layers.svg" width="20" align="top"> &nbsp;Drag &amp; Drop Anything

Grab anything from Dolphin, your desktop, or your browser and drop it right into the widget:

| Item Type | Examples | What happens |
| --------- | -------- | ------------ |
| **Applications &amp; `.desktop` files** | Firefox, Telegram, Dolphin, custom `.desktop` shortcuts | Runs the application natively via KIO / KService (never opens in a text editor) |
| **Directories** | `~/Documents`, `~/Projects`, `/var/log` | Opens immediately in Dolphin or your default file manager |
| **Documents &amp; Media** | PDFs, text files, photos, shell scripts | Opens in its registered viewer (Okular, Gwenview, etc.) |
| **Web Links** | `https://github.com`, documentation bookmarks | Opens directly in your default web browser |

### <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/layout.svg" width="20" align="top"> &nbsp;Desktop or Panel — you choose

Place it wherever your workflow needs it:

- **On your desktop**, it acts as a permanent, organized launcher container. Pick a frosted glass background, a sleek card outline, or make it completely flat with custom corner radii and background opacity.
- **In your panel**, it sits quietly as an icon of your choice. An optional high-contrast badge tells you how many items are inside. Dragging an item over the panel icon pops the drawer open automatically so you can drop files right in.

### <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/component.svg" width="20" align="top"> &nbsp;The Pin Button (📌)

Normally, panel popups close the second you click outside or focus another window. When you are moving files from Dolphin into a group, that gets annoying fast.

Click the **Pin button (📌)** in the header (or right-click the background and choose Pin). The popup stays firmly open on top of your windows until you unpin it, letting you drag and drop multiple items across folders without losing your place.

### <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/api.svg" width="20" align="top"> &nbsp;Built-in System Apps Explorer

Do not want to dig through file paths just to add a tool? Click **Add (+) → System Applications**:

- Real-time search through all desktop apps installed on your machine.
- Filter by name, description, or desktop category.
- One-click addition with official app titles and native system icons automatically applied.

### <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/sparkles.svg" width="20" align="top"> &nbsp;Official KDE Icon Picker

No guessing icon names or editing text fields. Clicking the icon picker opens KDE's native `KIconThemes.IconDialog`, giving you a visual search across your active Breeze or third-party icon theme.

### <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/refresh.svg" width="20" align="top"> &nbsp;Drag to Reorder On the Fly

Keep your most-used items where your muscle memory expects them. Grab any card with your mouse and drag it left or right inside the grid to change its order. A clear highlight bar shows you exactly where it will land when you let go.

### <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/wrench.svg" width="20" align="top"> &nbsp;Right-Click Context Menus Anywhere

Every item card has a right-click menu to edit, delete, nudge left/right, open the containing directory, or launch. 

Even if you hide the title bar header completely for an ultra-minimal look, right-clicking any empty spot in the background brings up a menu to pin the window, add new items, or open settings.

### <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/globe.svg" width="20" align="top"> &nbsp;Bilingual &amp; Flawless RTL

Application Group was written with first-class Persian and English support from day one:

- **Language options**: Persian, English, or follow your system locale.
- **True Right-to-Left (RTL)**: The entire layout, badges, search bars, and card flows mirror naturally in Persian without strange alignment glitches.
- Authentic, refined Persian terminology tailored for software engineering standards.

## <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/download.svg" width="26" align="top"> &nbsp;Installation

### <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/kde.svg" width="18" align="top"> &nbsp;The easy way — KDE Store

1. Right-click your desktop or panel and choose **Add or Manage Widgets…**
2. Click **Get New…** → **Download New Plasma Widgets**.
3. Search for **Application Group**.
4. Click **Install**, then drag it onto your desktop or panel.

> <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/link.svg" width="14" align="top"> **[View Application Group on the KDE Store →](https://www.opendesktop.org/p/2378509/)**

### <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/package.svg" width="18" align="top"> &nbsp;From a release file

1. Download the latest `.zip` package from the [Releases](https://github.com/keyaruga33/application-group-widget/releases) page.
2. Right-click your panel or desktop → **Add Widgets…** → **Get New…**
3. Select **Install From Local File…** and pick the downloaded archive.

### <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/terminal.svg" width="18" align="top"> &nbsp;From source

```bash
git clone https://github.com/keyaruga33/application-group-widget.git
cd application-group-widget
make install
```

To update an existing installation after pulling updates:

```bash
make upgrade
```

## <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/wrench.svg" width="26" align="top"> &nbsp;Configuration

Right-click the widget and select **Configure Application Group…**. Options are organized across three intuitive tabs:

<table>
  <tr>
    <td valign="top" width="33%">
      <b><img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/layers.svg" width="15" align="top"> General</b><br><br>
      • Custom group title &amp; header toggle<br>
      • Quick search filter bar toggle<br>
      • Panel icon &amp; KDE Icon Dialog picker<br>
      • Item count badge with contrast coloring<br>
      • Single-click vs. double-click launch<br>
      • Sort modes (Manual, Alphabetical, Usage)<br>
      • Language (Auto, Persian, English)
    </td>
    <td valign="top" width="33%">
      <b><img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/component.svg" width="15" align="top"> Appearance</b><br><br>
      • View mode: Grid or List<br>
      • Columns mode: Responsive Auto or Fixed (2–8)<br>
      • Icon sizes: Small (24px) up to Huge (64px)<br>
      • Card styles: Modern Card, Frosted Glass, Flat, Outline<br>
      • Background opacity &amp; corner radius sliders<br>
      • Show/hide labels &amp; font size offset
    </td>
    <td valign="top" width="33%">
      <b><img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/api.svg" width="15" align="top"> Items</b><br><br>
      • Full visual manager of all grouped items<br>
      • Move items up, down, or reorder<br>
      • Edit titles, icons, and destination paths<br>
      • Browse &amp; add installed system apps<br>
      • Delete individual entries or clear all
    </td>
  </tr>
</table>

## <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/performance.svg" width="26" align="top"> &nbsp;Lightweight &amp; Respectful

A desktop widget should stay out of your CPU's way. 

- **Zero idle polling**: No background intervals checking directories when nothing is happening.
- **Decoupled native execution**: Launching apps delegates through KDE's KIO and system process runners so commands run cleanly without hanging your desktop shell.
- **Lazy app catalog**: The system applications database is only queried when you actually open the Add dialog, keeping initial Plasma startup instant.

## <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/cpu.svg" width="26" align="top"> &nbsp;Requirements

- **KDE Plasma 6.0** or newer
- **Qt 6**

> Application Group is built specifically for KDE Plasma 6 using modern Kirigami and Plasma components. It does not run on Plasma 5, GNOME, or XFCE.

## <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/roadmap.svg" width="26" align="top"> &nbsp;What's next

- Multi-tab groupings inside a single container
- Category separator lines inside list view
- Document thumbnail previews for images and PDFs
- Optional badge for running application indicators

## <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/contributing.svg" width="26" align="top"> &nbsp;Contributing

Have an idea, found an odd bug, or want to make it look even sharper? Contributions are very welcome.

- <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/bug.svg" width="14" align="top"> **[Open an issue](https://github.com/keyaruga33/application-group-widget/issues)** if something is broken or could be better.
- <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/pull-request.svg" width="14" align="top"> Feel free to submit a **pull request** with fixes or improvements.

## <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/license.svg" width="26" align="top"> &nbsp;License

Application Group is free and open source software licensed under the **[GPL-3.0](LICENSE)** license.

## <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/heart.svg" width="26" align="top"> &nbsp;Support

If Application Group makes your desktop a nicer place to work, leaving a **⭐ star** on GitHub goes a long way.

If you would like to buy me a coffee to support ongoing development:

> <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/coffee.svg" width="15" align="top"> **[Buy me a coffee →](https://www.coffeete.ir/keyaruga333)**

## <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/link.svg" width="26" align="top"> &nbsp;Links

| | |
| --- | --- |
| <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/github.svg" width="15" align="top"> GitHub | https://github.com/keyaruga33/application-group-widget |
| <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/kde.svg" width="15" align="top"> KDE Store | https://www.opendesktop.org/p/2378509/ |
| <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/release.svg" width="15" align="top"> Releases | https://github.com/keyaruga33/application-group-widget/releases |
| <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/issue.svg" width="15" align="top"> Issues | https://github.com/keyaruga33/application-group-widget/issues |

<div align="center">
<br>

<img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/plasma.svg" width="20" align="top"> &nbsp;**Built for KDE Plasma 6** &nbsp;·&nbsp; <img src="https://raw.githubusercontent.com/keyaruga33/keyaruga33/main/assets/icons/folder.svg" width="18" align="top"> &nbsp;_Keep your workspace grouped, clean, and right where you need it._

</div>
