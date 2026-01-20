# Design Guidelines: Equilibrium - Retrocausal Prediction Engine

## Design Approach
**System-Based Design** using a custom dark scientific aesthetic inspired by physics instrumentation, terminal interfaces, and mission control systems. This is NOT a marketing application - it's a specialized three-agent prediction engine requiring precision, clarity, and constitutional separation.

## Core Design Principles

### 1. Constitutional Separation
- **Agent 1 (Emerald)**: Measurement/Physics layer - local device operations
- **Agent 2 (Red)**: Propagation/Network layer - signal transmission
- **Agent 3 (Purple)**: Consensus/Oracle layer - backend aggregation
- Each agent must have visually distinct UI zones that never blend

### 2. Temporal Hierarchy
- Display multiple time references simultaneously (Time 0, Time 1, Time 3)
- Use monospace fonts for all timestamps with explicit uncertainty intervals (t ± δt)
- Chronological data must show drift/offset calculations visibly

### 3. Scientific Instrumentation Aesthetic
- Terminal/console-inspired layouts with monospace typography
- Physics constants (G, C, Planck Second) displayed as reference anchors
- Real-time entropy/sensor readings in technical readout format
- Gaussian noise textures for depth without distraction

## Typography System

### Font Families
- **Primary**: JetBrains Mono, Fira Code, or SF Mono (monospace for data)
- **Headers**: Inter or System UI (geometric sans-serif)
- **Accent**: Courier New (for warnings/critical states)

### Scale & Hierarchy
- **H1 (Event Horizon Titles)**: text-4xl font-black tracking-tight
- **H2 (Agent Headers)**: text-2xl font-bold uppercase tracking-wider
- **Body (Readouts)**: text-sm font-mono leading-relaxed
- **Data Points**: text-xs font-mono tabular-nums
- **Warnings**: text-lg font-bold tracking-wide

## Layout System

### Spacing Primitives
Use Tailwind units: **2, 4, 6, 8, 12, 16** for consistent rhythm
- Component padding: p-4 to p-8
- Section spacing: space-y-8 to space-y-12
- Grid gaps: gap-4 to gap-6
- Margins: m-2, m-4 for tight groupings

### Grid Structure
- **Splash/Entry**: Single column centered (max-w-2xl)
- **Agent Dashboards**: Two-column split (Agent UI | Data Feed)
- **Admin Panel**: Three-column grid (Agent 1 | Agent 2 | Agent 3)
- **Results Display**: Single column with centered numerical output

## Component Library

### Core UI Elements

**1. Causal Event Horizon Button (Entry Point)**
- Large centered button (w-64 h-16)
- Pulsing border animation (keyframe glow)
- Monospace uppercase text "INITIATE CALIBRATION"
- Disabled state shows countdown timer for 12hr lockout

**2. Agent Status Cards**
- Border-l-4 with agent-specific accent
- Header with agent name + constitutional domain
- Live sensor readouts in tabular format
- Status indicators (ONLINE/OFFLINE/CALIBRATING)
- Timestamp footer with uncertainty interval

**3. Entropy Gauge**
- Horizontal progress bar with gradient fill
- Numerical readout (0.000000 format, 6 decimal precision)
- Label: "ENTROPY COST" with unit (Wh)
- Warning threshold markers at configurable levels

**4. Lottery Number Display**
- Large fixed-width grid (6 columns for main, 1 for bonus)
- Numbers in circles (w-16 h-16) with monospace font
- Epoch ID + Audit Hash below in small text
- "LOCKED" badge with next reset timestamp

**5. Terminal Log Feed**
- Fixed height scrollable area (h-96)
- Green-on-black text (terminal aesthetic)
- Timestamps in [HH:MM:SS.mmm] format
- Auto-scroll to bottom on new entries

**6. Time Differential Display**
- Side-by-side comparison (World 0 | World 1 | World 3)
- Each shows: Current Time, Offset (±ms), Drift Rate
- Color-coded by stability (green = stable, yellow = drifting, red = critical)

### Forms & Inputs

**Consent/Configuration Panels**
- Checkbox groups with explicit labels
- Range sliders for sensor sensitivity (with numeric readout)
- Location input with coordinate validation display
- Submit buttons with confirmation dialogs for critical actions

### Navigation

**Top Bar (Persistent)**
- Left: App name "EQUILIBRIUM" + version number
- Center: Current Agent Mode indicator
- Right: Connection status + battery level (if available)
- Bottom border: thin line with gradient pulse during active operations

**No Traditional Nav Menu** - This is a single-flow application with state-driven views

## Interaction Patterns

### State Transitions
- **BOOT → SPLASH**: Fade in with typing animation for disclaimers
- **SPLASH → OFFLINE CALIBRATION**: Button press triggers fullscreen dark overlay with "ENTERING EVENT HORIZON" message
- **CALIBRATION → ONLINE**: Smooth transition to network upload progress bar
- **PROCESSING → RESULTS**: Numbers fade in sequentially with sound cue
- **RESULTS → LOCKOUT**: Countdown timer starts, UI dims to read-only

### Animations (Minimal)
- Pulsing glow on active entry button (2s loop)
- Typing effect for critical warnings (character-by-character reveal)
- Progress bars with smooth fill animation (ease-out)
- Number reveal: stagger each digit by 100ms
- **NO parallax, NO scroll animations** - this is a utility, not a presentation

### Feedback
- Button click: subtle scale transform (scale-95)
- Hover states: brightness increase (brightness-110)
- Error states: red border pulse + shake animation
- Success: green checkmark fade-in
- Loading: monospace "..." animation in status text

## Screen-Specific Layouts

### 1. Splash Screen
- Centered card (max-w-lg)
- Title: "EQUILIBRIUM" (large, bold)
- Subtitle: "Retrocausal Prediction Engine v2.5"
- Warning text block (border-l-4 border-red, p-4):
  - "This system operates outside conventional causality"
  - "12-hour exclusion period enforced"
  - "Karmic cost calculation applies"
- Checkbox: "I understand the implications"
- Button: "ENTER EVENT HORIZON" (disabled until checked)

### 2. Agent 1 Dashboard (Offline Calibration)
- Full-screen dark background
- Top: "CALIBRATING LOCAL MANIFOLD" header
- Center: Live sensor readouts in grid (3x2):
  - Jitter, Timestamp, Entropy Score
  - EMF Flux, Ionizing Radiation, Signature
- Bottom: Progress indicator "Capturing photon collapse..." + percentage
- No exit button (user must wait for completion)

### 3. Agent 2 Network View (Online Sync)
- Split view: Left = Local State, Right = Network Topology
- Network visualization: nodes (other Agent 1s) connected by lines
- Lagrange point markers (L1-L5) overlaid on topology
- Status log feed at bottom (h-48, scrollable)

### 4. Results Screen
- Centered layout (max-w-4xl)
- Header: Provider name + jurisdiction
- Number display grid (prominent, centered)
- Metadata section:
  - Epoch ID, Audit Hash (truncated with tooltip)
  - Next Reset: countdown timer (HH:MM:SS)
- Entropy Cost gauge (horizontal bar)
- Karmic Penalty warning (if > 0): bordered alert box
- Footer: "LOCKOUT ACTIVE" + remaining time

### 5. Admin Panel (Multi-Agent Monitor)
- Three-column grid (equal width)
- Each column: Agent status card with live logs
- Global controls at top:
  - Force Reset, Purge Logs, Override Lockout
- Bottom bar: System metrics (CPU, Memory, Network)

## Accessibility

- All interactive elements: min-height h-12 (48px touch target)
- Keyboard navigation: focus rings visible (ring-2 ring-offset-2)
- Screen reader labels for all icon-only buttons
- Timestamps include timezone for clarity
- High contrast ratios maintained (WCAG AAA where possible)

## Special Considerations

### Physics Visualizations
- Three-Body Simulation: Canvas element with trails, no UI chrome over visualization
- Orbital Snapshot: SVG diagram with labeled satellites, fixed aspect ratio
- Spectroscopy Graph: Line chart with gradient fill, axis labels in monospace

### Error States
- Network failure: "SIGNAL LOST" message with retry countdown
- Calibration failure: Red alert with diagnostic log dump
- Lockout violation: Full-screen "ACCESS DENIED" with harsh warning text

### Data Display Precision
- All floating point: 6 decimal places minimum
- Coordinates: 5 decimal places (±90.00000, ±180.00000)
- Timestamps: ISO 8601 with milliseconds
- Hashes: First 8 chars + ellipsis (with copy button for full)

This design prioritizes **functional clarity over aesthetic flourish**, respecting the scientific/terminal heritage while maintaining usability for the critical causal event horizon workflow.