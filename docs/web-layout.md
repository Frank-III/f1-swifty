Looking at these F1 application screenshots, I'll create detailed ASCII art representations of each layout:

## Layout 1 - Live Timing Dashboard

```
┌─────────────────────────────────────────────────────────────────────┐
│  0  ‖  •  ⟨⟩  🇬🇧 British Grand Prix: Race              52/52 │Track Clear│
│                    00:00:00                                         │
│                                                                     │
│  (24)  (20)  (63)  ☁️  1.7                                        │
│  TRC   AIR         m/s                                             │
│                                                                     │
│ ┌─────┬─────┬─────┬───────┬──────────┬──────────┐                │
│ │  1  │ NOR │ DRS │  +2   │ 1:30.690 │          │                │
│ │     │     │     │       │ 1:29.734 │          │                │
│ ├─────┼─────┼─────┼───────┼──────────┼──────────┤                │
│ │  2  │ PIA │ DRS │   -   │ 1:32.340 │ +6.812   │                │
│ │     │     │     │       │ 1:29.337 │ +6.812   │                │
│ ├─────┼─────┼─────┼───────┼──────────┼──────────┤                │
│ │  3  │ HUL │ DRS │  +16  │ 1:31.705 │ +27.930  │                │
│ │     │     │     │       │ 1:30.933 │ +34.742  │                │
│ └─────┴─────┴─────┴───────┴──────────┴──────────┘                │
│                                                                     │
│        ┌────────────────────────────────────┐                     │
│        │           Track Map                 │                     │
│        │         ╱─────────╲                │                     │
│        │     ╱──╱           ╲──╲            │                     │
│        │   ╱  ╱   NOR•       ╲  ╲           │                     │
│        │  │  │    •SAI  •OCO  │  │          │                     │
│        │  │  │ •BEA           │  │          │                     │
│        │  │   ╲ •RUS          ╱  │          │                     │
│        │   ╲   ╲             ╱   ╱          │                     │
│        │    ╲   ╲___________╱   ╱           │                     │
│        │     ╲      •ALB       ╱            │                     │
│        │      ╲  STR• GAS•    ╱             │                     │
│        │       ╲  •HAM       ╱              │                     │
│        │        ╲ HUL• VER• ╱               │                     │
│        │         ╲─────────╱                │                     │
│        │                    •PIA            │                     │
│        └────────────────────────────────────┘                     │
│                                                                     │
│ [Continues with remaining drivers...]                              │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

Left Sidebar:
├─ Live Timing (selected)
├─ Dashboard
├─ Track Map
├─ Standings
├─ Weather
├─ General
├─ Settings
├─ Schedule
├─ Help
├─ Home
├─ Links
├─ Github
├─ Discord
├─ Buy me a coffee
└─ Sponsor me
```

## Layout 2 - Detailed Timing Screen

```
┌─────────────────────────────────────────────────────────────────────┐
│  0  ‖  •  ⟨⟩  🇬🇧 British Grand Prix: Race              52/52 │Track Clear│
│                    00:00:00                                         │
│                                                                     │
│  (24)  (20)  (63)  ☁️  1.7                                        │
│  TRC   AIR         m/s                                             │
│                                                                     │
│ ┌───┬─────┬─────┬───┬─────┬────────┬─────────┬─────────┬─────────┬─────┬──────┐
│ │ 1 │ NOR │ DRS │ M │ L 8 │  +2    │ -- ---  │ 1:30.690│ ●●●●●●● │25.023│  96  │
│ │   │     │     │   │PIT 2│        │         │ 36.855  │28.812   │24.312│ 2    │
│ ├───┼─────┼─────┼───┼─────┼────────┼─────────┼─────────┼─────────┼─────┼──────┤
│ │ 2 │ PIA │ DRS │ M │ L 9 │   -    │ +6.812  │ 1:32.340│ ●●●●●●● │24.909│ 100  │
│ │   │     │     │   │PIT 2│        │ +6.812  │ 36.663  │28.768   │24.299│ 5 km/h│
│ ├───┼─────┼─────┼───┼─────┼────────┼─────────┼─────────┼─────────┼─────┼──────┤
│ │ 3 │ HUL │ DRS │ M │ L10 │  +16   │+27.930  │ 1:31.705│ ●●●●●●● │25.093│ 118  │
│ │   │     │     │   │PIT 2│        │+34.742  │ 37.271  │29.341   │24.543│ 3 km/h│
│ └───┴─────┴─────┴───┴─────┴────────┴─────────┴─────────┴─────────┴─────┴──────┘
│                                                                     │
│ Legend:                                                             │
│ M = Medium tires, S = Soft tires, H = Hard tires                  │
│ Yellow dots = Sector times, Speed trap on right                    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Layout 3 - Championship Standings

```
┌─────────────────────────────────────────────────────────────────────┐
│  0  ‖  •  ⟨⟩  🇬🇧 British Grand Prix: Race              52/52 │Track Clear│
│                    00:00:00                                         │
│                                                                     │
│        Driver Championship Standings        Team Championship Standings│
│                                                                     │
│  ─  1  Oscar Piastri           234  +18   ─  1  🟠 McLaren    460  +43│
│  ─  2  Lando Norris            226  +25   ─  2  🟡 Ferrari    222  +12│
│  ─  3  Max Verstappen          165  +10   ─  3  ⚪ Mercedes   210  +1 │
│  ─  4  George Russell          147  +1    ─  4  🟣 Red Bull   172  +10│
│  ─  5  Charles Leclerc         119   -    ─  5  🔵 Williams    59  +4 │
│  ─  6  Lewis Hamilton          103  +12   +3 6  🟢 Kick Sauber 41  +15│
│  ─  7  Kimi Antonelli           63   -    -1 7  🔵 Racing Bulls 36   - │
│  ─  8  Alexander Albon          46  +4    ─  8  ⚫ Aston Martin 36  +8 │
│  +1 9  Nico Hulkenberg          37  +15   -2 9  🔴 Haas F1 Team 29   - │
│  -1 10 Esteban Ocon             23   -    ─ 10  🔵 Alpine      19  +8 │
│  ─  11 Isack Hadjar             21   -                              │
│  ─  12 Lance Stroll             20  +6                              │
│  +3 13 Pierre Gasly             19  +8                              │
│  -1 14 Fernando Alonso          16  +2                              │
│  -1 15 Carlos Sainz             13   -                              │
│  -1 16 Liam Lawson              12   -                              │
│  ─  17 Yuki Tsunoda             10   -                              │
│  ─  18 Oliver Bearman            6   -                              │
│  ─  19 Gabriel Bortoleto         4   -                              │
│  ─  20 Franco Colapinto          0   -                              │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Layout 4 - Mobile Live Timing (Portrait)

```
┌─────────────────────────────────┐
│ ⟨⟩   0   ‖  •52/52  │Track Clear│
│                                 │
│ 🇬🇧 British Grand Prix: Race    │
│      00:00:00                   │
│                                 │
│  24    20    63   ☁️   1.7     │
│  TRC   AIR        🌧️   m/s     │
│                                 │
│┌──┬─────┬─────┬───┬────┬───────┬────────┐
││1 │ NOR │ DRS │ M │L 8 │  +2   │ -- --- │
││  │     │     │   │PIT2│   -   │ -- --- │
│├──┼─────┼─────┼───┼────┼───────┼────────┤
││2 │ PIA │ DRS │ M │L 9 │   -   │ +6.812 │
││  │     │     │   │PIT2│   -   │ +6.812 │
│├──┼─────┼─────┼───┼────┼───────┼────────┤
││3 │ HUL │ DRS │ M │L10 │ +16   │+27.930 │
││  │     │     │   │PIT2│   -   │+34.742 │
│├──┼─────┼─────┼───┼────┼───────┼────────┤
││4 │ HAM │ DRS │ S │L14 │  +1   │ +5.070 │
││  │     │     │   │PIT2│   -   │+39.812 │
│├──┼─────┼─────┼───┼────┼───────┼────────┤
││5 │ VER │ DRS │ M │L11 │  -4   │+16.969 │
││  │     │     │   │PIT2│   -   │+56.781 │
│└──┴─────┴─────┴───┴────┴───────┴────────┘
│                                 │
│ [Scroll for more drivers...]    │
│                                 │
└─────────────────────────────────┘
```

## Layout 5 - Mobile with Track Map

```
┌─────────────────────────────────┐
│ ⟨⟩   0   ‖  •52/52  │Track Clear│
│                                 │
│ 🇬🇧 British Grand Prix: Race    │
│      00:00:00                   │
│                                 │
│  24    20    63   ☁️   1.7     │
│  TRC   AIR        🌧️   m/s     │
│                                 │
│    ┌─────────────────────┐      │
│    │    ╱─────────╲      │      │
│    │  ╱─╱ NOR•     ╲─╲   │      │
│    │ ╱ ╱    •SAI    ╲ ╲  │      │
│    ││ │  •OCO  •BEA │ │  │      │
│    ││ │     •RUS    │ │  │      │
│    │╲ ╲             ╱ ╱  │      │
│    │ ╲ ╲___________╱ ╱   │      │
│    │  ╲    •ALB     ╱    │      │
│    │   ╲ STR• GAS• ╱     │      │
│    │    ╲  •HAM   ╱      │      │
│    │     ╲HUL•VER╱       │      │
│    │      ╲─────╱        │      │
│    │         •PIA        │      │
│    └─────────────────────┘      │
│                                 │
│┌──┬─────┬─────┬────┬──────┬─────────┐
││1 │ NOR │ DRS │ +2 │ ---- │1:30.690 │
││  │     │     │ -  │ ---- │1:29.734 │
│├──┼─────┼─────┼────┼──────┼─────────┤
││2 │ PIA │ DRS │ -  │+6.812│1:32.340 │
││  │     │     │ -  │+6.812│1:29.337 │
│└──┴─────┴─────┴────┴──────┴─────────┘
│                                 │
└─────────────────────────────────┘
```

Key elements across all layouts:
- Weather indicators (Temperature, Air temp, Wind speed, Humidity)
- Lap counter (52/52)
- Track status (Track Clear)
- DRS indicators for each driver
- Tire compounds (M=Medium, S=Soft, H=Hard)
- Pit stop counts
- Position changes (+/- numbers)
- Time gaps to leader
- Lap times (current and best)
- Driver abbreviations and team colors
- Interactive track map showing live positions
- Championship standings with points and changes
