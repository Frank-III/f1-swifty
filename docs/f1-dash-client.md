Directory Structure:

└── ./
    └── dash
        ├── src
        │   ├── app
        │   │   ├── (nav)
        │   │   │   ├── help
        │   │   │   │   └── page.tsx
        │   │   │   ├── schedule
        │   │   │   │   └── page.tsx
        │   │   │   ├── layout.tsx
        │   │   │   └── page.tsx
        │   │   ├── dashboard
        │   │   │   ├── driver
        │   │   │   │   └── [nr]
        │   │   │   │       └── page.tsx
        │   │   │   ├── settings
        │   │   │   │   ├── layout.tsx
        │   │   │   │   └── page.tsx
        │   │   │   ├── standings
        │   │   │   │   └── page.tsx
        │   │   │   ├── track-map
        │   │   │   │   └── page.tsx
        │   │   │   ├── weather
        │   │   │   │   ├── map-timeline.tsx
        │   │   │   │   ├── map.tsx
        │   │   │   │   └── page.tsx
        │   │   │   ├── layout.tsx
        │   │   │   └── page.tsx
        │   │   ├── embed
        │   │   │   └── page.tsx
        │   │   ├── global-error.tsx
        │   │   ├── layout.tsx
        │   │   └── not-found.tsx
        │   ├── components
        │   │   ├── complications
        │   │   │   ├── Gauge.tsx
        │   │   │   ├── Humidity.tsx
        │   │   │   ├── Rain.tsx
        │   │   │   ├── Temperature.tsx
        │   │   │   └── WindSpeed.tsx
        │   │   ├── dashboard
        │   │   │   ├── DriverViolations.tsx
        │   │   │   ├── LeaderBoard.tsx
        │   │   │   ├── Map.tsx
        │   │   │   ├── RaceControl.tsx
        │   │   │   ├── RaceControlMessage.tsx
        │   │   │   ├── RadioMessage.tsx
        │   │   │   ├── TeamRadios.tsx
        │   │   │   └── TrackViolations.tsx
        │   │   ├── driver
        │   │   │   ├── Driver.tsx
        │   │   │   ├── DriverCarMetrics.tsx
        │   │   │   ├── DriverDRS.tsx
        │   │   │   ├── DriverGap.tsx
        │   │   │   ├── DriverHistoryTires.tsx
        │   │   │   ├── DriverInfo.tsx
        │   │   │   ├── DriverLapTime.tsx
        │   │   │   ├── DriverMiniSectors.tsx
        │   │   │   ├── DriverPedals.tsx
        │   │   │   ├── DriverTag.tsx
        │   │   │   └── DriverTire.tsx
        │   │   ├── schedule
        │   │   │   ├── Countdown.tsx
        │   │   │   ├── NextRound.tsx
        │   │   │   ├── Round.tsx
        │   │   │   ├── Schedule.tsx
        │   │   │   └── WeekendSchedule.tsx
        │   │   ├── settings
        │   │   │   └── FavoriteDrivers.tsx
        │   │   ├── ui
        │   │   │   ├── Button.tsx
        │   │   │   ├── Input.tsx
        │   │   │   ├── Modal.tsx
        │   │   │   ├── PlayControls.tsx
        │   │   │   ├── Progress.tsx
        │   │   │   ├── SegmentedControls.tsx
        │   │   │   ├── Select.tsx
        │   │   │   ├── SelectMultiple.tsx
        │   │   │   ├── Slider.tsx
        │   │   │   └── Toggle.tsx
        │   │   ├── ConnectionStatus.tsx
        │   │   ├── DelayInput.tsx
        │   │   ├── DelayTimer.tsx
        │   │   ├── Flag.tsx
        │   │   ├── Footer.tsx
        │   │   ├── LapCount.tsx
        │   │   ├── Note.tsx
        │   │   ├── NumberDiff.tsx
        │   │   ├── OledModeProvider.tsx
        │   │   ├── Qualifying.tsx
        │   │   ├── QualifyingDriver.tsx
        │   │   ├── ScrollHint.tsx
        │   │   ├── SessionInfo.tsx
        │   │   ├── Sidebar.tsx
        │   │   ├── SidenavButton.tsx
        │   │   ├── TrackInfo.tsx
        │   │   └── WeatherInfo.tsx
        │   ├── hooks
        │   │   ├── useBuffer.ts
        │   │   ├── useDataEngine.ts
        │   │   ├── useDevMode.ts
        │   │   ├── useSocket.ts
        │   │   ├── useStatefulBuffer.ts
        │   │   ├── useStores.ts
        │   │   └── useWakeLock.ts
        │   ├── lib
        │   │   ├── calculatePosition.ts
        │   │   ├── circle.ts
        │   │   ├── dateFormatter.ts
        │   │   ├── fetchMap.ts
        │   │   ├── geocode.ts
        │   │   ├── getTrackStatusMessage.ts
        │   │   ├── getWindDirection.ts
        │   │   ├── groupSessionByDay.ts
        │   │   ├── inflate.ts
        │   │   ├── map.ts
        │   │   ├── merge.ts
        │   │   ├── params.ts
        │   │   ├── rainviewer.ts
        │   │   ├── sorting.ts
        │   │   ├── toTrackTime.ts
        │   │   └── utcToLocalMs.ts
        │   ├── stores
        │   │   ├── useDataStore.ts
        │   │   ├── useSettingsStore.ts
        │   │   └── useSidebarStore.ts
        │   ├── styles
        │   │   └── globals.css
        │   ├── types
        │   │   ├── geocode.type.ts
        │   │   ├── map.type.ts
        │   │   ├── message.type.ts
        │   │   ├── rainviewer.type.ts
        │   │   ├── schedule.type.ts
        │   │   └── state.type.ts
        │   ├── env-script.tsx
        │   ├── env.ts
        │   ├── metadata.ts
        │   └── viewport.ts
        └── next.config.ts



---
File: /dash/src/app/(nav)/help/page.tsx
---

import Image from "next/image";

import Note from "@/components/Note";
import DriverDRS from "@/components/driver/DriverDRS";
import DriverTire from "@/components/driver/DriverTire";
import DriverPedals from "@/components/driver/DriverPedals";
import TemperatureComplication from "@/components/complications/Temperature";
import HumidityComplication from "@/components/complications/Humidity";
import WindSpeedComplication from "@/components/complications/WindSpeed";
import RainComplication from "@/components/complications/Rain";

import unknownTireIcon from "public/tires/unknown.svg";
import mediumTireIcon from "public/tires/medium.svg";
import interTireIcon from "public/tires/intermediate.svg";
import hardTireIcon from "public/tires/hard.svg";
import softTireIcon from "public/tires/soft.svg";
import wetTireIcon from "public/tires/wet.svg";

export default function HelpPage() {
	return (
		<div>
			<h1 className="my-4 text-3xl">Help Page</h1>

			<p>This page explains some core features and UI elements of f1-dash.</p>

			<h2 className="my-4 text-2xl">Colors</h2>

			<p>
				A core element in the UI of f1-dash, inspired by official Formula 1 graphics, is the color-coding system used for lap times, sector times,
				mini sectors, and gaps. Each color has a meaning in the context of lap times, sector times, or mini sectors.
			</p>

			<div className="my-4 flex flex-col">
				<div className="flex gap-1">
					<p className="flex items-center gap-1">
						<span className="size-4 rounded-md bg-white" /> White
					</p>
					<p>Last lap time</p>
				</div>

				<div className="flex gap-1">
					<p className="flex items-center gap-1 text-yellow-500">
						<span className="size-4 rounded-md bg-amber-400" /> Yellow
					</p>
					<p>Slower than personal best</p>
				</div>

				<div className="flex gap-1">
					<p className="flex items-center gap-1 text-emerald-500">
						<span className="size-4 rounded-md bg-emerald-500" /> Green
					</p>
					<p>Personal best</p>
				</div>

				<div className="flex gap-1">
					<p className="flex items-center gap-1 text-violet-500">
						<span className="size-4 rounded-md bg-violet-500" /> Purple
					</p>
					<p>Overall best</p>
				</div>

				<div className="flex gap-1">
					<p className="flex items-center gap-1 text-blue-500">
						<span className="size-4 rounded-md bg-blue-500" /> Blue
					</p>
					<p>Driver in the pit lane</p>
				</div>
			</div>

			<Note>
				Only mini sectors use the yellow color. Using yellow for all drivers not improving their lap times would make
				the UI look cluttered, as many text elements would be yellow simultaneously.
			</Note>

			<h2 className="my-4 text-2xl">Leaderboard</h2>

			<p className="mb-4">
				The leaderboard shows all the drivers of the ongoing session. Depending on the driver&apos;s status and the
				session&apos;s progression, some drivers may have a colored background.
			</p>

			<div className="grid grid-cols-1 gap-x-4 divide-y divide-zinc-800 sm:grid-cols-3 sm:divide-y-0">
				<div>
					<p className="rounded-md bg-violet-800/30 p-2">Driver has a purple background</p>
					<p className="p-2">Driver has the fastest overall lap time</p>
				</div>

				<div className="pt-4 sm:pt-0">
					<p className="rounded-md border p-2 opacity-50">Driver is a bit transparent</p>
					<p className="p-2">Driver has crashed or retired from the session</p>
				</div>

				<div className="pt-4 sm:pt-0">
					<p className="rounded-md bg-red-800/30 p-2">Driver has a red background</p>
					<p className="p-2">Driver is in the danger zone during qualifying</p>
				</div>
			</div>

			<h2 className="my-4 text-2xl">DRS & PIT Status</h2>

			<p className="mb-4">
				Each driver in the leaderboard has a DRS and PIT status indicator. It shows whether a driver has no DRS, is less
				than 1 second behind the driver ahead (and has DRS from the detection zone), has DRS active, or is in the pit
				lane or leaving it.
			</p>

			<p className="mb-4">
				Overall it gives you a quick overview if the driver is going into the pits and might drop a few places behind or
				if the driver has DRS and a chance to overtake the driver ahead.
			</p>

			<div className="mb-4 flex flex-col gap-4">
				<div className="flex items-center gap-2">
					<div className="w-[4rem]">
						<DriverDRS on={false} possible={false} inPit={false} pitOut={false} />
					</div>

					<p>Off: No DRS (default)</p>
				</div>

				<div className="flex items-center gap-2">
					<div className="w-[4rem]">
						<DriverDRS on={false} possible={true} inPit={false} pitOut={false} />
					</div>

					<p>Possible: Eligible for DRS in the next zone</p>
				</div>

				<div className="flex items-center gap-2">
					<div className="w-[4rem]">
						<DriverDRS on={true} possible={false} inPit={false} pitOut={false} />
					</div>

					<p>Active: DRS is active</p>
				</div>

				<div className="flex items-center gap-2">
					<div className="w-[4rem]">
						<DriverDRS on={false} possible={false} inPit={true} pitOut={false} />
					</div>

					<p>PIT: In the pit lane or leaving</p>
				</div>
			</div>

			<h2 className="my-4 text-2xl">Tires</h2>

			<p className="mb-4">
				We also show the different tires a driver can use and how many laps they have done on them. <br />
				In this example, the driver has a soft tire which is 12 laps old and he pitted one time.
			</p>

			<div className="mb-4">
				<DriverTire
					stints={[
						{ totalLaps: 12, compound: "SOFT" },
						{ totalLaps: 12, compound: "SOFT", new: "TRUE" },
					]}
				/>
			</div>

			<p className="mb-4">These are the different icons for the different tire compounds:</p>

			<div className="mb-4 flex flex-wrap gap-4">
				<div className="flex items-center gap-2">
					<Image src={softTireIcon} alt="soft" className="size-8" />
					<p>Soft</p>
				</div>

				<div className="flex items-center gap-2">
					<Image src={mediumTireIcon} alt="medium" className="size-8" />
					<p>Medium</p>
				</div>

				<div className="flex items-center gap-2">
					<Image src={hardTireIcon} alt="hard" className="size-8" />
					<p>Hard</p>
				</div>

				<div className="flex items-center gap-2">
					<Image src={interTireIcon} alt="intermediate" className="size-8" />
					<p>Intermediate</p>
				</div>

				<div className="flex items-center gap-2">
					<Image src={wetTireIcon} alt="wet" className="size-8" />
					<p>Wet</p>
				</div>

				<div className="flex items-center gap-2">
					<Image src={unknownTireIcon} alt="unknown" className="size-8" />
					<p>Unknown</p>
				</div>
			</div>

			<Note className="mb-4">
				Sometimes the tire type is unknown. This can happen at the beginning of a session or when something goes wrong.
			</Note>

			<h2 className="my-4 text-2xl">Delay Control</h2>

			<p className="mb-4">
				When using f1-dash while watching on TV, F1TV, or your favorite streaming platform, you may notice that f1-dash
				updates much earlier than your stream. This can make exciting race events less interesting, as you see them on
				f1-dash before experiencing them on your stream. This is where the delay control comes in.
			</p>

			<p className="mb-4">
				With delay control, you can set a delay in seconds to make f1-dash update later than it normally would. So
				setting a 30-second delay will cause f1-dash to update 30 seconds later than it normally would.
				<br />
				You can use this to sync your stream with f1-dash.
			</p>

			<Note className="mb-4">
				Currently you can only set a delay that is the time you have been on the dashboard page. So 30s on a 20s page
				visit makes you wait 10s until playback of the updates resumes. (This will be changed in the future)
			</Note>

			<h3 className="my-4 text-xl">What to look for when syncing?</h3>

			<ul className="list ml-6 list-disc">
				<li>
					Start of a new lap <span className="text-zinc-500">(race)</span>
				</li>
				<li>
					Session clock <span className="text-zinc-500">(practice, qualifying)</span>
				</li>
				<li>If available mini sectors</li>
			</ul>

			<h2 className="my-4 text-2xl">Driver Pedals</h2>

			<div className="mb-4 flex flex-col gap-4">
				<div className="flex items-center gap-6">
					<div className="w-[4rem]">
						<DriverPedals className="bg-red-500" value={1} maxValue={3} />
					</div>

					<p>
						Shows if the driver is braking <span className="text-zinc-500">(on / off)</span>
					</p>
				</div>

				<div className="flex items-center gap-6">
					<div className="w-[4rem]">
						<DriverPedals className="bg-emerald-500" value={3} maxValue={4} />
					</div>

					<p>
						Shows how much the driver is pressing the throttle pedal <span className="text-zinc-500">(0-100%)</span>
					</p>
				</div>

				<div className="flex items-center gap-6">
					<div className="w-[4rem]">
						<DriverPedals className="bg-blue-500" value={2} maxValue={3} />
					</div>

					<p>
						Shows the engine&apos;s RPM <span className="text-zinc-500">(0 - 15&apos;000)</span>
					</p>
				</div>
			</div>

			<h2 className="my-4 text-2xl">Weather</h2>

			<div className="mb-4 flex flex-col gap-2">
				<div className="flex flex-row items-center gap-2">
					<TemperatureComplication value={39} label="TRC" />
					<p>This shows the current track temperature.</p>
				</div>

				<div className="flex flex-row items-center gap-2">
					<TemperatureComplication value={26} label="AIR" />
					<p>This shows the current air temperature.</p>
				</div>

				<div className="flex flex-row items-center gap-2">
					<HumidityComplication value={36} />
					<p>This shows the current humidity.</p>
				</div>

				<div className="flex flex-row items-center gap-2">
					<RainComplication rain={true} />
					<p>This shows if it&apos;s raining or not.</p>
				</div>

				<div className="flex flex-row items-center gap-2">
					<WindSpeedComplication speed={2.9} directionDeg={250} />
					<p>This shows the current wind speed in m/s and cardinal direction.</p>
				</div>
			</div>
		</div>
	);
}



---
File: /dash/src/app/(nav)/schedule/page.tsx
---

import { Suspense } from "react";

import NextRound from "@/components/schedule/NextRound";
import Schedule from "@/components/schedule/Schedule";

export default async function SchedulePage() {
	return (
		<div>
			<div className="my-4">
				<h1 className="text-3xl">Up Next</h1>
				<p className="text-zinc-500">All times are local time</p>
			</div>

			<Suspense fallback={<NextRoundLoading />}>
				<NextRound />
			</Suspense>

			<div className="my-4">
				<h1 className="text-3xl">Schedule</h1>
				<p className="text-zinc-500">All times are local time</p>
			</div>

			<Suspense fallback={<FullScheduleLoading />}>
				<Schedule />
			</Suspense>
		</div>
	);
}

const RoundLoading = () => {
	return (
		<div className="flex flex-col gap-1">
			<div className="h-12 w-full animate-pulse rounded-md bg-zinc-800" />

			<div className="grid grid-cols-3 gap-8 pt-1">
				{Array.from({ length: 3 }).map((_, i) => (
					<div key={`day.${i}`} className="grid grid-rows-2 gap-2">
						<div className="h-12 w-full animate-pulse rounded-md bg-zinc-800" />
						<div className="h-12 w-full animate-pulse rounded-md bg-zinc-800" />
					</div>
				))}
			</div>
		</div>
	);
};

const NextRoundLoading = () => {
	return (
		<div className="grid h-44 grid-cols-1 gap-8 sm:grid-cols-2">
			<div className="flex flex-col gap-4">
				<div className="h-1/2 w-3/4 animate-pulse rounded-md bg-zinc-800" />
				<div className="h-1/2 w-3/4 animate-pulse rounded-md bg-zinc-800" />
			</div>

			<RoundLoading />
		</div>
	);
};

const FullScheduleLoading = () => {
	return (
		<div className="mb-20 grid grid-cols-1 gap-8 md:grid-cols-2">
			{Array.from({ length: 6 }).map((_, i) => (
				<RoundLoading key={`round.${i}`} />
			))}
		</div>
	);
};



---
File: /dash/src/app/(nav)/layout.tsx
---

import { type ReactNode } from "react";
import Image from "next/image";
import Link from "next/link";

import githubIcon from "public/icons/github.svg";
import coffeeIcon from "public/icons/bmc-logo.svg";

import Footer from "@/components/Footer";

type Props = {
	children: ReactNode;
};

export default function Layout({ children }: Props) {
	return (
		<>
			<nav className="sticky top-0 left-0 z-10 flex h-12 w-full items-center justify-between gap-4 border-b border-zinc-800 p-2 px-4 backdrop-blur-lg">
				<div className="flex gap-4">
					<Link className="transition duration-100 active:scale-95" href="/">
						Home
					</Link>
					<Link className="transition duration-100 active:scale-95" href="/dashboard">
						Dashboard
					</Link>
					<Link className="transition duration-100 active:scale-95" href="/schedule">
						Schedule
					</Link>
					<Link className="transition duration-100 active:scale-95" href="/help">
						Help
					</Link>
				</div>

				<div className="hidden items-center gap-4 pr-2 sm:flex">
					<Link
						className="flex items-center gap-2 transition duration-100 active:scale-95"
						href="https://www.buymeacoffee.com/slowlydev"
						target="_blank"
					>
						<Image src={coffeeIcon} alt="Buy Me A Coffee" width={20} height={20} />
						<span>Coffee</span>
					</Link>

					<Link
						className="flex items-center gap-2 transition duration-100 active:scale-95"
						href="https://github.com/slowlydev/f1-dash"
						target="_blank"
					>
						<Image src={githubIcon} alt="GitHub" width={20} height={20} />
						<span>GitHub</span>
					</Link>
				</div>
			</nav>

			<main className="container mx-auto max-w-(--breakpoint-lg) px-4">
				{children}

				<Footer />
			</main>
		</>
	);
}



---
File: /dash/src/app/(nav)/page.tsx
---

import Image from "next/image";
import Link from "next/link";

import Button from "@/components/ui/Button";
import ScrollHint from "@/components/ScrollHint";

import icon from "public/tag-logo.svg";

export default function Home() {
	return (
		<div>
			<section className="flex h-screen w-full flex-col items-center pt-20 sm:justify-center sm:pt-0">
				<Image src={icon} alt="f1-dash tag logo" width={200} />

				<h1 className="my-20 text-center text-5xl font-bold">
					Real-time Formula 1 <br />
					telemetry and timing
				</h1>

				<div className="flex flex-wrap gap-4">
					<Link href="/dashboard">
						<Button className="rounded-xl! border-2 border-transparent p-4 font-medium">Go to Dashboard</Button>
					</Link>

					<Link href="/schedule">
						<Button className="rounded-xl! border-2 border-zinc-700 bg-transparent! p-4 font-medium">
							Check Schedule
						</Button>
					</Link>
				</div>

				<ScrollHint />
			</section>

			<section className="pb-20">
				<h2 className="mb-4 text-2xl">What&apos;s f1-dash?</h2>

				<p className="text-md">
					f1-dash is a hobby project of mine that I started in 2023. It is a real-time telemetry and timing dashboard
					for Formula 1. It allows you to see the live telemetry data of the cars on the track and also the live timing,
					which includes things like lap times, sector times, the gaps between the drivers, their tire choices and much
					more.
				</p>
			</section>

			<section className="pb-20">
				<h2 className="mb-4 text-2xl">What&apos;s next?</h2>

				<p className="text-md">
					The new design of v3 enables more pages and features. So in the future there will be incremental updates
					and new features coming. If you have any suggestions or feedback, feel free to reach out on GitHub or the
					Discord.
				</p>
			</section>
		</div>
	);
}


---
File: /dash/src/app/dashboard/driver/[nr]/page.tsx
---

export default function DriverPage() {
	return (
		<div>
			<p>comming soon</p>
		</div>
	);
}



---
File: /dash/src/app/dashboard/settings/layout.tsx
---

import type { ReactNode } from "react";

type Props = Readonly<{
	children: ReactNode;
}>;

export default function Layout({ children }: Props) {
	return <div className="max-w-(--breakpoint-lg) p-4">{children}</div>;
}



---
File: /dash/src/app/dashboard/settings/page.tsx
---

"use client";

import SegmentedControls from "@/components/ui/SegmentedControls";
import Button from "@/components/ui/Button";
import Slider from "@/components/ui/Slider";
import Input from "@/components/ui/Input";

import FavoriteDrivers from "@/components/settings/FavoriteDrivers";

import DelayInput from "@/components/DelayInput";
import DelayTimer from "@/components/DelayTimer";
import Toggle from "@/components/ui/Toggle";

import { useSettingsStore } from "@/stores/useSettingsStore";
import Footer from "@/components/Footer";

export default function SettingsPage() {
	const settings = useSettingsStore();
	return (
		<div>
			<h1 className="mb-4 text-3xl">Settings</h1>

			<h2 className="my-4 text-2xl">Visual</h2>

			<div className="flex gap-2">
				<Toggle enabled={settings.carMetrics} setEnabled={(v) => settings.setCarMetrics(v)} />
				<p className="text-zinc-500">Show Car Metrics (RPM, Gear, Speed)</p>
			</div>

			<div className="flex gap-2">
				<Toggle enabled={settings.showCornerNumbers} setEnabled={(v) => settings.setShowCornerNumbers(v)} />
				<p className="text-zinc-500">Show Corner Numbers on Track Map</p>
			</div>

			<div className="flex gap-2">
				<Toggle enabled={settings.tableHeaders} setEnabled={(v) => settings.setTableHeaders(v)} />
				<p className="text-zinc-500">Show Driver Table Header</p>
			</div>

			<div className="flex gap-2">
				<Toggle enabled={settings.showBestSectors} setEnabled={(v) => settings.setShowBestSectors(v)} />
				<p className="text-zinc-500">Show Drivers Best Sectors</p>
			</div>

			<div className="flex gap-2">
				<Toggle enabled={settings.showMiniSectors} setEnabled={(v) => settings.setShowMiniSectors(v)} />
				<p className="text-zinc-500">Show Drivers Mini Sectors</p>
			</div>

			<div className="flex gap-2">
				<Toggle enabled={settings.oledMode} setEnabled={(v) => settings.setOledMode(v)} />
				<p className="text-zinc-500">OLED Mode (Pure Black Background)</p>
			</div>

			<div className="flex gap-2">
				<Toggle enabled={settings.useSafetyCarColors} setEnabled={(v) => settings.setUseSafetyCarColors(v)} />
				<p className="text-zinc-500">Use Safety Car Colors</p>
			</div>

			<h2 className="my-4 text-2xl">Race Control</h2>

			<div className="flex gap-2">
				<Toggle enabled={settings.raceControlChime} setEnabled={(v) => settings.setRaceControlChime(v)} />
				<p className="text-zinc-500">Play Chime on new Race Control Message</p>
			</div>

			{settings.raceControlChime && (
				<div className="flex flex-row items-center gap-2">
					<Input
						value={String(settings.raceControlChimeVolume)}
						setValue={(v) => {
							const numericValue = Number(v);
							if (!isNaN(numericValue)) {
								settings.setRaceControlChimeVolume(numericValue);
							}
						}}
					/>
					<Slider
						className="!w-52"
						value={settings.raceControlChimeVolume}
						setValue={(v) => settings.setRaceControlChimeVolume(v)}
					/>

					<p className="text-zinc-500">Race Control Chime Volume</p>
				</div>
			)}

			<h2 className="my-4 text-2xl">Favorite Drivers</h2>

			<p className="mb-4">Select your favorite drivers to highlight them on the dashboard.</p>

			<FavoriteDrivers />

			<h2 className="my-4 text-2xl">Speed Metric</h2>

			<p className="mb-4">Choose the unit in which you want to display speeds.</p>

			<SegmentedControls
				id="speed-unit"
				selected={settings.speedUnit}
				onSelect={settings.setSpeedUnit}
				options={[
					{ label: "km/h", value: "metric" },
					{ label: "mp/h", value: "imperial" },
				]}
			/>

			<h2 className="my-4 text-2xl">Delay</h2>

			<p className="mb-4">
				Here you have to option to set a delay for the data, it will displayed the amount entered in seconds later than
				on the live edge. On the Dashboard page there is the same delay input field so you can set it without going to
				the settings. It can be found in the most top bar on the right side.
			</p>

			<div className="flex items-center gap-2">
				<DelayTimer />
				<DelayInput />
				<p className="text-zinc-500">Delay in seconds</p>
			</div>

			<Button className="mt-2 bg-red-500!" onClick={() => settings.setDelay(0)}>
				Reset delay
			</Button>

			<Footer />
		</div>
	);
}



---
File: /dash/src/app/dashboard/standings/page.tsx
---

"use client";

import { useDataStore } from "@/stores/useDataStore";

import NumberDiff from "@/components/NumberDiff";
import Image from "next/image";

export default function Standings() {
	const driverStandings = useDataStore((state) => state?.championshipPrediction?.drivers);
	const teamStandings = useDataStore((state) => state?.championshipPrediction?.teams);

	const drivers = useDataStore((state) => state.driverList);

	const isRace = useDataStore((state) => state.sessionInfo?.type === "Race");

	if (!isRace) {
		return (
			<div className="flex h-full w-full flex-col items-center justify-center">
				<p>championship standings unavailable</p>
				<p className="text-sm text-zinc-500">currently only available during a race</p>
			</div>
		);
	}

	return (
		<div className="grid h-full grid-cols-1 divide-y divide-zinc-800 lg:grid-cols-2 lg:divide-x lg:divide-y-0">
			<div className="h-full p-4">
				<h2 className="text-xl">Driver Championship Standings</h2>

				<div className="divide flex flex-col divide-y divide-zinc-800">
					{!driverStandings &&
						new Array(20).fill("").map((_, index) => <SkeletonItem key={`driver.loading.${index}`} />)}

					{driverStandings &&
						drivers &&
						Object.values(driverStandings)
							.sort((a, b) => a.predictedPosition - b.predictedPosition)
							.map((driver) => {
								const driverDetails = drivers[driver.racingNumber];

								if (!driverDetails) {
									return null;
								}

								return (
									<div
										className="grid p-2"
										style={{
											gridTemplateColumns: "2rem 2rem auto 4rem 4rem",
										}}
										key={driver.racingNumber}
									>
										<NumberDiff old={driver.currentPosition} current={driver.predictedPosition} />
										<p>{driver.predictedPosition}</p>

										<p>
											{driverDetails.firstName} {driverDetails.lastName}
										</p>

										<p>{driver.predictedPoints}</p>

										<NumberDiff old={driver.predictedPoints} current={driver.currentPoints} />
									</div>
								);
							})}
				</div>
			</div>

			<div className="h-full p-4">
				<h2 className="text-xl">Team Championship Standings</h2>

				<div className="divide flex flex-col divide-y divide-zinc-800">
					{!teamStandings && new Array(10).fill("").map((_, index) => <SkeletonItem key={`team.loading.${index}`} />)}

					{teamStandings &&
						Object.values(teamStandings)
							.sort((a, b) => a.predictedPosition - b.predictedPosition)
							.map((team) => (
								<div
									className="grid p-2"
									style={{
										gridTemplateColumns: "2rem 2rem 2rem auto 4rem 4rem",
									}}
									key={team.teamName}
								>
									<NumberDiff old={team.currentPosition} current={team.predictedPosition} />
									<p>{team.predictedPosition}</p>

									<Image
										src={`/team-logos/${team.teamName.replaceAll(" ", "-").toLowerCase()}.${"svg"}`}
										alt={team.teamName}
										width={24}
										height={24}
										className="overflow-hidden rounded-lg"
									/>

									<p>{team.teamName}</p>

									<p>{team.predictedPoints}</p>

									<NumberDiff old={team.predictedPoints} current={team.currentPoints} />
								</div>
							))}
				</div>
			</div>
		</div>
	);
}

const SkeletonItem = () => {
	return (
		<div
			className="grid gap-2 p-2"
			style={{
				gridTemplateColumns: "2rem 2rem auto 4rem 4rem 4rem",
			}}
		>
			<div className="h-4 w-4 animate-pulse rounded-md bg-zinc-800" />
			<div className="h-4 w-4 animate-pulse rounded-md bg-zinc-800" />
			<div className="h-4 w-4 animate-pulse rounded-md bg-zinc-800" />
			<div className="h-4 w-16 animate-pulse rounded-md bg-zinc-800" />
			<div className="h-4 w-8 animate-pulse rounded-md bg-zinc-800" />
			<div className="h-4 w-8 animate-pulse rounded-md bg-zinc-800" />
			<div className="h-4 w-4 animate-pulse rounded-md bg-zinc-800" />
		</div>
	);
};



---
File: /dash/src/app/dashboard/track-map/page.tsx
---

"use client";

import { AnimatePresence, motion } from "motion/react";
import clsx from "clsx";

import Map from "@/components/dashboard/Map";
import DriverTag from "@/components/driver/DriverTag";
import DriverDRS from "@/components/driver/DriverDRS";
import DriverInfo from "@/components/driver/DriverInfo";
import DriverGap from "@/components/driver/DriverGap";
import DriverLapTime from "@/components/driver/DriverLapTime";

import { sortPos } from "@/lib/sorting";

import { useCarDataStore, useDataStore } from "@/stores/useDataStore";
import type { Driver, TimingDataDriver } from "@/types/state.type";
import { useSettingsStore } from "@/stores/useSettingsStore";

export default function TrackMap() {
	const drivers = useDataStore((state) => state?.driverList);
	const driversTiming = useDataStore((state) => state?.timingData);

	return (
		<div className="flex flex-col-reverse md:h-full md:flex-row">
			<div className="flex w-full flex-col gap-0.5 overflow-y-auto border-zinc-800 md:h-full md:w-fit md:rounded-lg md:border md:p-2">
				{(!drivers || !driversTiming) &&
					new Array(20).fill("").map((_, index) => <SkeletonDriver key={`driver.loading.${index}`} />)}

				{drivers && driversTiming && (
					<AnimatePresence>
						{Object.values(driversTiming.lines)
							.sort(sortPos)
							.map((timingDriver, index) => (
								<TrackMapDriver
									key={`trackmap.driver.${timingDriver.racingNumber}`}
									position={index + 1}
									driver={drivers[timingDriver.racingNumber]}
									timingDriver={timingDriver}
								/>
							))}
					</AnimatePresence>
				)}
			</div>

			<div className="md:flex-1">
				<Map />
			</div>
		</div>
	);
}

type TrackMapDriverProps = {
	position: number;
	driver: Driver;
	timingDriver: TimingDataDriver;
};

const hasDRS = (drs: number) => drs > 9;

const possibleDRS = (drs: number) => drs === 8;

const inDangerZone = (position: number, sessionPart: number) => {
	switch (sessionPart) {
		case 1:
			return position > 15;
		case 2:
			return position > 10;
		case 3:
		default:
			return false;
	}
};

const TrackMapDriver = ({ position, driver, timingDriver }: TrackMapDriverProps) => {
	const sessionPart = useDataStore((state) => state?.timingData?.sessionPart);
	const timingStatsDriver = useDataStore((state) => state?.timingStats?.lines[driver.racingNumber]);
	const appTimingDriver = useDataStore((state) => state?.timingAppData?.lines[driver.racingNumber]);
	const hasFastest = timingStatsDriver?.personalBestLapTime.position == 1;

	const carData = useCarDataStore((state) =>
		state?.carsData ? state.carsData[driver.racingNumber].Channels : undefined,
	);

	const favoriteDriver = useSettingsStore((state) => state.favoriteDrivers.includes(driver.racingNumber));

	return (
		<motion.div
			layout="position"
			className={clsx("flex flex-col gap-1 rounded-lg p-1.5 select-none", {
				"opacity-50": timingDriver.knockedOut || timingDriver.retired || timingDriver.stopped,
				"bg-sky-800/30": favoriteDriver,
				"bg-violet-800/30": hasFastest,
				"bg-red-800/30": sessionPart != undefined && inDangerZone(position, sessionPart),
			})}
		>
			<div
				className="grid items-center gap-2"
				style={{
					gridTemplateColumns: "5.5rem 3.5rem 4rem 5rem 5rem",
				}}
			>
				<DriverTag className="min-w-full!" short={driver.tla} teamColor={driver.teamColour} position={position} />
				<DriverDRS
					on={carData ? hasDRS(carData[45]) : false}
					possible={carData ? possibleDRS(carData[45]) : false}
					inPit={timingDriver.inPit}
					pitOut={timingDriver.pitOut}
				/>
				<DriverInfo timingDriver={timingDriver} gridPos={appTimingDriver ? parseInt(appTimingDriver.gridPos) : 0} />
				<DriverGap timingDriver={timingDriver} sessionPart={sessionPart} />
				<DriverLapTime last={timingDriver.lastLapTime} best={timingDriver.bestLapTime} hasFastest={hasFastest} />
			</div>
		</motion.div>
	);
};

const SkeletonDriver = () => {
	const animateClass = "h-8 animate-pulse rounded-md bg-zinc-800";

	return (
		<div
			className="grid place-items-center items-center gap-1 p-1"
			style={{
				gridTemplateColumns: "5.5rem 4rem 5.5rem 5rem 5rem",
			}}
		>
			<div className={animateClass} style={{ width: "100%" }} />

			<div className={animateClass} style={{ width: "90%" }} />

			{new Array(2).fill(null).map((_, index) => (
				<div className="flex w-full flex-col gap-1" key={`skeleton.${index}`}>
					<div className={clsx(animateClass, "h-4!")} />
					<div className={clsx(animateClass, "h-3! w-2/3")} />
				</div>
			))}

			<div className="flex w-full flex-col gap-1">
				<div className={clsx(animateClass, "h-3! w-4/5")} />
				<div className={clsx(animateClass, "h-4!")} />
			</div>
		</div>
	);
};



---
File: /dash/src/app/dashboard/weather/map-timeline.tsx
---

"use client";

import { unix } from "moment";
import { motion, useMotionValue, useDragControls, AnimatePresence } from "motion/react";

import { useState, useRef, useEffect, type RefObject } from "react";

function getProgressFromX<T extends HTMLElement>({
	x,
	containerRef,
}: {
	x: number;
	containerRef: RefObject<T | null>;
}) {
	const bounds = containerRef.current?.getBoundingClientRect();

	if (!bounds) return 0;

	const progress = (x - bounds.x) / bounds.width;
	return clamp(progress, 0, 1);
}

function getXFromProgress<T extends HTMLElement>({
	progress,
	containerRef,
}: {
	progress: number;
	containerRef: RefObject<T | null>;
}) {
	const bounds = containerRef.current?.getBoundingClientRect();

	if (!bounds) return 0;

	return progress * bounds.width;
}

function clamp(number: number, min: number, max: number) {
	return Math.max(min, Math.min(number, max));
}

function useInterval(callback: () => void, delay: number | null) {
	const intervalRef = useRef<null | NodeJS.Timeout>(null);
	const savedCallback = useRef(callback);

	useEffect(() => {
		savedCallback.current = callback;
	}, [callback]);

	useEffect(() => {
		const tick = () => savedCallback.current();

		if (typeof delay === "number") {
			intervalRef.current = setInterval(tick, delay);

			return () => {
				if (intervalRef.current) {
					clearInterval(intervalRef.current);
				}
			};
		}
	}, [delay]);

	return intervalRef;
}

type Props = {
	frames: {
		id: number;
		time: number;
	}[];

	setFrame: (id: number) => void;

	playing: boolean;
};

export default function Timeline({ frames, setFrame, playing }: Props) {
	const constraintsRef = useRef<HTMLDivElement | null>(null);
	const fullBarRef = useRef<null | HTMLDivElement>(null);
	const scrubberRef = useRef<null | HTMLButtonElement>(null);

	const scrubberX = useMotionValue(0);
	const currentTimePrecise = useMotionValue(0);
	const dragControls = useDragControls();

	const [dragging, setDragging] = useState<boolean>(false);
	const [time, setTime] = useState<number>(0); // relative to DURATION

	const startTime = frames[0].time;
	const endTime = frames[frames.length - 1].time;

	const DURATION = endTime - startTime;

	const currentTime = startTime + time;

	// let minsRemaining = Math.floor((DURATION - currentTime) / 60);
	// let secsRemaining = `${(DURATION - currentTime) % 60}`.padStart(2, "0");
	// let timecodeRemaining = `${minsRemaining}:${secsRemaining}`;
	// let progress = (currentTime / DURATION) * 100;

	useEffect(() => {
		const targetTime = startTime + time;

		// find the nearest frame, but it must be older
		const nearestFrame = frames.findLast((frame) => frame.time <= targetTime);

		if (nearestFrame) {
			setFrame(nearestFrame.id);
		}
	}, [time, frames, setFrame, startTime]);

	// every 0.5s, advance 10 minutes
	useInterval(
		() => {
			if (time < DURATION) {
				setTime((t) => t + 10 * 60);
			} else {
				setTime(0);
			}
		},
		playing ? 500 : null,
	);

	// every 0.01s, advance 0.2 minutes
	useInterval(
		() => {
			if (currentTimePrecise.get() < DURATION) {
				currentTimePrecise.set(currentTimePrecise.get() + 0.2 * 60); // 12

				const newX = getXFromProgress({
					containerRef: fullBarRef,
					progress: currentTimePrecise.get() / DURATION,
				});

				scrubberX.set(newX);
			} else {
				currentTimePrecise.set(0);
				scrubberX.set(0);
			}
		},
		playing ? 10 : null,
	);

	const legendCount = 10;
	const timeInterval = DURATION / (legendCount - 1);

	return (
		<div className="relative w-full select-none">
			<div
				className="relative mt-2"
				onPointerDown={(event) => {
					const newProgress = getProgressFromX({
						containerRef: fullBarRef,
						x: event.clientX,
					});
					dragControls.start(event, { snapToCursor: true });
					setTime(Math.floor(newProgress * DURATION));
					currentTimePrecise.set(newProgress * DURATION);
				}}
			>
				<div ref={fullBarRef} className="h-1 w-full rounded-full bg-zinc-800" />

				{/* <motion.div layout style={{ width: progressPreciseWidth }} className="absolute top-0">
					<div className="bg- absolute inset-0 h-[3px] rounded-full bg-slate-500"></div>
				</motion.div> */}

				<div className="absolute inset-0" ref={constraintsRef}>
					<motion.button
						className="absolute flex cursor-ew-resize items-center justify-center rounded-full active:cursor-grabbing"
						ref={scrubberRef}
						drag="x"
						dragConstraints={constraintsRef}
						dragControls={dragControls}
						dragElastic={0}
						dragMomentum={false}
						style={{ x: scrubberX }}
						onDrag={() => {
							if (!scrubberRef.current) return;
							const scrubberBounds = scrubberRef.current.getBoundingClientRect();
							const middleOfScrubber = scrubberBounds.x + scrubberBounds.width / 2;
							const newProgress = getProgressFromX({
								containerRef: fullBarRef,
								x: middleOfScrubber,
							});

							setTime(Math.floor(newProgress * DURATION));
							currentTimePrecise.set(newProgress * DURATION);
						}}
						onDragStart={() => setDragging(true)}
						onPointerDown={() => setDragging(true)}
						onPointerUp={() => setDragging(false)}
						onDragEnd={() => setDragging(false)}
					>
						<motion.div
							animate={{ scale: dragging ? 1.2 : 1 }}
							transition={{ type: "tween", duration: 0.15 }}
							initial={false}
							className="-mt-2 h-5 w-2 rounded-full bg-zinc-300"
						/>

						<AnimatePresence>
							{dragging && (
								// TODO add background blur so you can always see the time
								<motion.p
									className="absolute text-sm font-medium tracking-wide tabular-nums"
									initial={{ y: 12, opacity: 0 }}
									animate={{ y: 20, opacity: 1 }}
									exit={{ y: [20, 12], opacity: 0 }}
								>
									{unix(currentTime).format("HH:mm")}
								</motion.p>
							)}
						</AnimatePresence>
					</motion.button>
				</div>
			</div>

			<div className="mt-4 flex flex-row justify-between">
				{Array.from({ length: legendCount }).map((_, i) => {
					const legendTime = startTime + i * timeInterval;
					return (
						<div key={i} className="text-xs text-zinc-500">
							{unix(legendTime).format("HH:mm")}
						</div>
					);
				})}
			</div>
		</div>
	);
}



---
File: /dash/src/app/dashboard/weather/map.tsx
---

"use client";

import { useEffect, useRef, useState } from "react";

import maplibregl, { Map, Marker } from "maplibre-gl";
import "maplibre-gl/dist/maplibre-gl.css";

import { fetchCoords } from "@/lib/geocode";
import { getRainviewer } from "@/lib/rainviewer";

import { useDataStore } from "@/stores/useDataStore";

import PlayControls from "@/components/ui/PlayControls";

import Timeline from "./map-timeline";

export function WeatherMap() {
	const meeting = useDataStore((state) => state?.sessionInfo?.meeting);

	const [loading, setLoading] = useState<boolean>(true);

	const mapContainerRef = useRef<HTMLDivElement>(null);
	const mapRef = useRef<Map>(null);

	const [playing, setPlaying] = useState<boolean>(false);

	const [frames, setFrames] = useState<{ id: number; time: number }[]>([]);
	const currentFrameRef = useRef<number>(0);

	const handleMapLoad = async () => {
		if (!mapRef.current) return;

		const rainviewer = await getRainviewer();
		if (!rainviewer) return;

		const pathFrames = [...rainviewer.radar.past, ...rainviewer.radar.nowcast];

		for (let i = 0; i < pathFrames.length; i++) {
			const frame = pathFrames[i];

			mapRef.current.addLayer({
				id: `rainviewer-frame-${i}`,
				type: "raster",
				source: {
					type: "raster",
					tiles: [`${rainviewer.host}/${frame.path}/256/{z}/{x}/{y}/8/1_0.webp`],
					tileSize: 256,
				},
				paint: {
					"raster-opacity": 0,
					"raster-fade-duration": 200,
					"raster-resampling": "nearest",
				},
			});
		}

		setFrames(pathFrames.map((frame, i) => ({ time: frame.time, id: i })));
	};

	useEffect(() => {
		(async () => {
			if (!mapContainerRef.current) return;

			if (!meeting) return;

			const [coordsC, coordsA] = await Promise.all([
				fetchCoords(`${meeting.country.name}, ${meeting.location} circuit`),
				fetchCoords(`${meeting.country.name}, ${meeting.location} autodrome`),
			]);

			const coords = coordsC || coordsA;

			const libMap = new maplibregl.Map({
				container: mapContainerRef.current,
				style: "https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json",
				center: coords ? [coords.lon, coords.lat] : undefined,
				zoom: 10,
				canvasContextAttributes: {
					antialias: true,
				},
			});

			libMap.on("load", async () => {
				setLoading(false);

				if (coords) {
					new Marker().setLngLat([coords.lon, coords.lat]).addTo(libMap);
				}

				await handleMapLoad();
			});

			mapRef.current = libMap;
		})();
	}, [meeting]);

	const setFrame = (idx: number) => {
		mapRef.current?.setPaintProperty(`rainviewer-frame-${currentFrameRef.current}`, "raster-opacity", 0);
		mapRef.current?.setPaintProperty(`rainviewer-frame-${idx}`, "raster-opacity", 0.8);
		currentFrameRef.current = idx;
	};

	return (
		<div className="relative h-full w-full">
			<div ref={mapContainerRef} className="absolute h-full w-full" />

			{!loading && frames.length > 0 && (
				<div className="absolute right-0 bottom-0 left-0 z-20 m-2 flex gap-4 rounded-lg bg-black/80 p-4 backdrop-blur-xs md:right-auto md:w-lg">
					<PlayControls playing={playing} onClick={() => setPlaying((v) => !v)} />

					<Timeline frames={frames} setFrame={setFrame} playing={playing} />
				</div>
			)}

			{loading && <div className="h-full w-full animate-pulse rounded-lg bg-zinc-800" />}
		</div>
	);
}



---
File: /dash/src/app/dashboard/weather/page.tsx
---

import { WeatherMap } from "@/app/dashboard/weather/map";

export default function WeatherPage() {
	// calc height is a workaround, maybe think about refactoring sometime
	return (
		<div className="relative h-[calc(100%-142px)] w-full md:h-full">
			<WeatherMap />
		</div>
	);
}



---
File: /dash/src/app/dashboard/layout.tsx
---

"use client";

import { type ReactNode } from "react";
import { AnimatePresence, motion } from "motion/react";

import { useDataEngine } from "@/hooks/useDataEngine";
import { useWakeLock } from "@/hooks/useWakeLock";
import { useStores } from "@/hooks/useStores";
import { useSocket } from "@/hooks/useSocket";

import { useSettingsStore } from "@/stores/useSettingsStore";
import { useSidebarStore } from "@/stores/useSidebarStore";
import { useDataStore } from "@/stores/useDataStore";

import Sidebar from "@/components/Sidebar";
import SidenavButton from "@/components/SidenavButton";
import SessionInfo from "@/components/SessionInfo";
import WeatherInfo from "@/components/WeatherInfo";
import TrackInfo from "@/components/TrackInfo";
import DelayInput from "@/components/DelayInput";
import DelayTimer from "@/components/DelayTimer";
import ConnectionStatus from "@/components/ConnectionStatus";

type Props = {
	children: ReactNode;
};

export default function DashboardLayout({ children }: Props) {
	const stores = useStores();
	const { handleInitial, handleUpdate, maxDelay } = useDataEngine(stores);
	const { connected } = useSocket({ handleInitial, handleUpdate });

	const delay = useSettingsStore((state) => state.delay);
	const syncing = delay > maxDelay;

	useWakeLock();

	const ended = useDataStore((state) => state.sessionStatus?.status === "Ends");

	return (
		<div className="flex h-screen w-full md:pt-2 md:pr-2 md:pb-2">
			<Sidebar key="sidebar" connected={connected} />

			<motion.div layout="size" className="flex h-full w-full flex-1 flex-col md:gap-2">
				<DesktopStaticBar show={!syncing || ended} />
				<MobileStaticBar show={!syncing || ended} connected={connected} />

				<div className={!syncing || ended ? "no-scrollbar w-full flex-1 overflow-auto md:rounded-lg" : "hidden"}>
					<MobileDynamicBar />
					{children}
				</div>

				<div
					className={
						syncing && !ended
							? "flex h-full flex-1 flex-col items-center justify-center gap-2 border-zinc-800 md:rounded-lg md:border"
							: "hidden"
					}
				>
					<h1 className="my-20 text-center text-5xl font-bold">Syncing...</h1>
					<p>Please wait for {delay - maxDelay} seconds.</p>
					<p>Or make your delay smaller.</p>
				</div>
			</motion.div>
		</div>
	);
}

function MobileDynamicBar() {
	return (
		<div className="flex flex-col divide-y divide-zinc-800 border-b border-zinc-800 md:hidden">
			<div className="p-2">
				<SessionInfo />
			</div>
			<div className="p-2">
				<WeatherInfo />
			</div>
		</div>
	);
}

function MobileStaticBar({ show, connected }: { show: boolean; connected: boolean }) {
	const open = useSidebarStore((state) => state.open);

	return (
		<div className="flex w-full items-center justify-between overflow-hidden border-b border-zinc-800 p-2 md:hidden">
			<div className="flex items-center gap-2">
				<SidenavButton key="mobile" onClick={() => open()} />

				<DelayInput saveDelay={500} />
				<DelayTimer />

				<ConnectionStatus connected={connected} />
			</div>

			{show && <TrackInfo />}
		</div>
	);
}

function DesktopStaticBar({ show }: { show: boolean }) {
	const pinned = useSidebarStore((state) => state.pinned);
	const pin = useSidebarStore((state) => state.pin);

	return (
		<div className="hidden w-full flex-row justify-between overflow-hidden rounded-lg border border-zinc-800 p-2 md:flex">
			<div className="flex items-center gap-2">
				<AnimatePresence>
					{!pinned && <SidenavButton key="desktop" className="shrink-0" onClick={() => pin()} />}

					<motion.div key="session-info" layout="position">
						<SessionInfo />
					</motion.div>
				</AnimatePresence>
			</div>

			<div className="hidden md:items-center lg:flex">{show && <WeatherInfo />}</div>

			<div className="flex justify-end">{show && <TrackInfo />}</div>
		</div>
	);
}



---
File: /dash/src/app/dashboard/page.tsx
---

"use client";

import LeaderBoard from "@/components/dashboard/LeaderBoard";
import RaceControl from "@/components/dashboard/RaceControl";
import TeamRadios from "@/components/dashboard/TeamRadios";
import TrackViolations from "@/components/dashboard/TrackViolations";
import Map from "@/components/dashboard/Map";
import Footer from "@/components/Footer";

export default function Page() {
	return (
		<div className="flex w-full flex-col gap-2">
			<div className="flex w-full flex-col gap-2 2xl:flex-row">
				<div className="overflow-x-auto">
					<LeaderBoard />
				</div>

				<div className="flex-1 2xl:max-h-[50rem]">
					<Map />
				</div>
			</div>

			<div className="grid grid-cols-1 gap-2 divide-y divide-zinc-800 *:h-[30rem] *:overflow-y-auto *:rounded-lg *:border *:border-zinc-800 *:p-2 md:divide-y-0 lg:grid-cols-3">
				<div>
					<RaceControl />
				</div>

				<div>
					<TeamRadios />
				</div>

				<div>
					<TrackViolations />
				</div>
			</div>

			<Footer />
		</div>
	);
}



---
File: /dash/src/app/embed/page.tsx
---

export default function EmbedPage() {
	return (
		<div className="flex h-screen w-screen flex-col items-center justify-center">
			<p>embeds have been disabled for now</p>
			<p className="text-sm text-zinc-500">
				enjoy live telemetry and more on{" "}
				<a className="text-blue-500" href="https://f1-dash.com" target="_blank">
					f1-dash.com
				</a>{" "}
				directly
			</p>
		</div>
	);
}



---
File: /dash/src/app/global-error.tsx
---

"use client";

import Button from "@/components/ui/Button";

export default function Error({ error, reset }: { error: Error & { digest?: string }; reset: () => void }) {
	return (
		<div className="flex h-dvh w-full flex-col items-center justify-center">
			<h2>Something went wrong!</h2>
			<p>{error.message}</p>
			<Button onClick={() => reset()}>Try again</Button>
		</div>
	);
}



---
File: /dash/src/app/layout.tsx
---

import { type ReactNode } from "react";
import Script from "next/script";

import "@/styles/globals.css";

import { env } from "@/env";
import EnvScript from "@/env-script";
import OledModeProvider from "@/components/OledModeProvider";

import { GeistMono } from "geist/font/mono";
import { GeistSans } from "geist/font/sans";

export { metadata } from "@/metadata";
export { viewport } from "@/viewport";

type Props = Readonly<{
	children: ReactNode;
}>;

export default function RootLayout({ children }: Props) {
	return (
		<html lang="en" className={`${GeistSans.variable} ${GeistMono.variable} font-sans text-white`}>
			<head>
				<EnvScript />

				{env.DISABLE_IFRAME === "1" && (
					<Script strategy="beforeInteractive" id="no-embed">
						{`if (window.self !== window.top && window.location.pathname !== "/embed") {window.location.href = "/embed"; }`}
					</Script>
				)}

				{env.TRACKING_ID && env.TRACKING_URL && (
					// Umami Analytics
					<Script async defer data-website-id={env.TRACKING_ID} src={env.TRACKING_URL} />
				)}
			</head>

			<body>
				<OledModeProvider>{children}</OledModeProvider>
			</body>
		</html>
	);
}


---
File: /dash/src/app/not-found.tsx
---

import Link from "next/link";

import Button from "@/components/ui/Button";

export default function NotFound() {
	return (
		<div className="container mx-auto max-w-(--breakpoint-lg) px-4">
			<section className="flex h-screen w-full flex-col items-center pt-20 sm:justify-center sm:pt-0">
				<p className="text-center text-8xl font-bold">404</p>

				<h1 className="my-20 text-center text-5xl font-bold">Page not found</h1>

				<div className="flex flex-wrap gap-4">
					<Link href="/">
						<Button className="rounded-xl! border-2 border-zinc-700 bg-transparent! p-4 font-medium">
							Go back to home
						</Button>
					</Link>
				</div>
			</section>
		</div>
	);
}



---
File: /dash/src/components/complications/Gauge.tsx
---

import { clamping, describeArc, polarToCartesian } from "@/lib/circle";

type Props = {
	value: number;
	max: number;
	gradient: "temperature" | "humidity";
};

export default function Gauge({ value, max, gradient }: Props) {
	const startAngle = -130;
	const endAngle = 130;
	const size = 50;
	const strokeWidth = 5;

	const dot = polarToCartesian(
		size / 2,
		size / 2,
		size / 2 - strokeWidth / 2,
		clamping(value, startAngle, endAngle, max),
	);

	return (
		<svg xmlns="http://www.w3.org/2000/svg" width="50" height="50" viewBox="0 0 50 50" fill="none" className="absolute">
			<defs>
				<linearGradient id="temperature">
					<stop offset="0%" stopColor="#BFDC30" />
					<stop offset="10%" stopColor="#B3FE00" />
					<stop offset="30%" stopColor="#FFE620" />
					<stop offset="60%" stopColor="#FF9500" />
					<stop offset="90%" stopColor="#FA114F" />
				</linearGradient>

				<linearGradient id="humidity">
					<stop offset="0%" stopColor="#01DF6E" />
					<stop offset="10%" stopColor="#55CAF1" />
					<stop offset="30%" stopColor="#4EBCFA" />
					<stop offset="60%" stopColor="#36A6F9" />
					<stop offset="90%" stopColor="#5855D6" />
				</linearGradient>
			</defs>

			<path
				d={describeArc(size / 2, size / 2, size / 2 - strokeWidth / 2, startAngle, endAngle)}
				strokeWidth={strokeWidth}
				stroke={`url(#${gradient})`}
				strokeLinecap="round"
			/>

			<circle cx={dot.x} cy={dot.y} z="10" r="3.5" fill="none" stroke="black" strokeWidth="3" />
		</svg>
	);
}



---
File: /dash/src/components/complications/Humidity.tsx
---

import Image from "next/image";

import Gauge from "./Gauge";

import humidityIcon from "public/icons/humidity.svg";

type Props = {
	value: number;
};

export default function HumidityComplication({ value }: Props) {
	return (
		<div className="relative flex h-[55px] w-[55px] items-center justify-center rounded-full bg-black">
			<Gauge value={value} max={100} gradient="humidity" />

			<div className="mt-2 flex flex-col items-center gap-0.5">
				<p className="flex h-[22px] shrink-0 text-xl leading-[normal] font-medium text-[color:var(--Base-Text,#F2F2F2)] not-italic">
					{value}
				</p>
				<Image src={humidityIcon} alt="humidity icon" className="h-[11px] w-auto" />
			</div>
		</div>
	);
}



---
File: /dash/src/components/complications/Rain.tsx
---

import Image from "next/image";

import rainIcon from "public/icons/cloud.heavyrain.svg";
import noRainIcon from "public/icons/cloud.rain.svg";

type Props = {
	rain: boolean;
};

export default function RainComplication({ rain }: Props) {
	return (
		<div className="relative flex h-[55px] w-[55px] items-center justify-center rounded-full bg-black">
			{rain ? (
				<Image src={rainIcon} alt="rain" className="h-[25px] w-auto" />
			) : (
				<Image src={noRainIcon} alt="no rain" className="h-[25px] w-auto" />
			)}
		</div>
	);
}



---
File: /dash/src/components/complications/Temperature.tsx
---

import Gauge from "./Gauge";

type Props = {
	value: number;
	label: "TRC" | "AIR";
};

export default function TemperatureComplication({ value, label }: Props) {
	return (
		<div className="relative flex h-[55px] w-[55px] items-center justify-center rounded-full bg-black">
			<Gauge value={value} max={label === "TRC" ? 60 : 40} gradient="temperature" />

			<div className="mt-2 flex flex-col items-center gap-0.5">
				<p className="flex h-[22px] shrink-0 text-xl leading-[normal] font-medium text-[color:var(--Base-Text,#F2F2F2)] not-italic">
					{value}
				</p>
				<p className="flex h-[11px] shrink-0 text-center text-[10px] leading-[normal] font-medium text-[color:var(--Multicolor-Green,#67E151)] not-italic">
					{label}
				</p>
			</div>
		</div>
	);
}



---
File: /dash/src/components/complications/WindSpeed.tsx
---

import { getWindDirection } from "@/lib/getWindDirection";

type Props = {
	speed: number;
	directionDeg: number;
};

export default function WindSpeedComplication({ speed, directionDeg }: Props) {
	return (
		<div className="relative flex h-[55px] w-[55px] items-center justify-center rounded-full bg-black">
			<div className="flex flex-col items-center">
				<p className="text-center text-[10px] leading-none font-medium text-blue-400">
					{getWindDirection(directionDeg)}
				</p>

				<p className="text-xl leading-none font-medium text-white">{speed}</p>

				<p className="text-center text-[10px] leading-none font-medium text-white">m/s</p>
			</div>
		</div>
	);
}



---
File: /dash/src/components/dashboard/DriverViolations.tsx
---

import type { Driver, TimingData } from "@/types/state.type";

import { calculatePosition } from "@/lib/calculatePosition";

import DriverTag from "@/components/driver/DriverTag";

type Props = {
	driver: Driver;
	driverViolations: number;
	driversTiming: TimingData | undefined;
};

export default function DriverViolations({ driver, driverViolations, driversTiming }: Props) {
	return (
		<div className="flex gap-2 p-1.5" key={`violation.${driver.racingNumber}`}>
			<DriverTag className="h-fit" teamColor={driver.teamColour} short={driver.tla} />

			<div className="flex flex-col justify-around text-sm leading-none text-zinc-600">
				<p>
					{driverViolations} Violation{driverViolations > 1 ? "s" : ""}
					{driverViolations > 4 && <span> - {Math.round(driverViolations / 5) * 5}s Penalty</span>}
				</p>
				{driverViolations > 4 && driversTiming && (
					<p>
						{calculatePosition(Math.round(driverViolations / 5) * 5, driver.racingNumber, driversTiming)}
						th after penalty
					</p>
				)}
			</div>
		</div>
	);
}



---
File: /dash/src/components/dashboard/LeaderBoard.tsx
---

import { AnimatePresence, LayoutGroup } from "motion/react";
import clsx from "clsx";

import { useSettingsStore } from "@/stores/useSettingsStore";
import { useDataStore } from "@/stores/useDataStore";

import { sortPos } from "@/lib/sorting";

import Driver from "@/components/driver/Driver";

export default function LeaderBoard() {
	const drivers = useDataStore((state) => state?.driverList);
	const driversTiming = useDataStore((state) => state?.timingData);

	const showTableHeader = useSettingsStore((state) => state.tableHeaders);

	return (
		<div className="flex w-fit flex-col gap-0.5">
			{showTableHeader && <TableHeaders />}

			{(!drivers || !driversTiming) &&
				new Array(20).fill("").map((_, index) => <SkeletonDriver key={`driver.loading.${index}`} />)}

			<LayoutGroup key="drivers">
				{drivers && driversTiming && (
					<AnimatePresence>
						{Object.values(driversTiming.lines)
							.sort(sortPos)
							.map((timingDriver, index) => (
								<Driver
									key={`leaderBoard.driver.${timingDriver.racingNumber}`}
									position={index + 1}
									driver={drivers[timingDriver.racingNumber]}
									timingDriver={timingDriver}
								/>
							))}
					</AnimatePresence>
				)}
			</LayoutGroup>
		</div>
	);
}

const TableHeaders = () => {
	const carMetrics = useSettingsStore((state) => state.carMetrics);

	return (
		<div
			className="grid items-center gap-2 p-1 px-2 text-sm font-medium text-zinc-500"
			style={{
				gridTemplateColumns: carMetrics
					? "5.5rem 3.5rem 5.5rem 4rem 5rem 5.5rem auto 10.5rem"
					: "5.5rem 3.5rem 5.5rem 4rem 5rem 5.5rem auto",
			}}
		>
			<p>Position</p>
			<p>DRS</p>
			<p>Tire</p>
			<p>Info</p>
			<p>Gap</p>
			<p>LapTime</p>
			<p>Sectors</p>
			{carMetrics && <p>Car Metrics</p>}
		</div>
	);
};

const SkeletonDriver = () => {
	const carMetrics = useSettingsStore((state) => state.carMetrics);

	const animateClass = "h-8 animate-pulse rounded-md bg-zinc-800";

	return (
		<div
			className="grid items-center gap-2 p-1.5"
			style={{
				gridTemplateColumns: carMetrics
					? "5.5rem 3.5rem 5.5rem 4rem 5rem 5.5rem auto 10.5rem"
					: "5.5rem 3.5rem 5.5rem 4rem 5rem 5.5rem auto",
			}}
		>
			<div className={animateClass} style={{ width: "100%" }} />

			<div className={animateClass} style={{ width: "100%" }} />

			<div className="flex w-full gap-2">
				<div className={clsx(animateClass, "w-8")} />

				<div className="flex flex-1 flex-col gap-1">
					<div className={clsx(animateClass, "h-4!")} />
					<div className={clsx(animateClass, "h-3! w-2/3")} />
				</div>
			</div>

			{new Array(2).fill(null).map((_, index) => (
				<div className="flex w-full flex-col gap-1" key={`skeleton.${index}`}>
					<div className={clsx(animateClass, "h-4!")} />
					<div className={clsx(animateClass, "h-3! w-2/3")} />
				</div>
			))}

			<div className="flex w-full flex-col gap-1">
				<div className={clsx(animateClass, "h-3! w-4/5")} />
				<div className={clsx(animateClass, "h-4!")} />
			</div>

			<div className="flex w-full gap-1">
				{new Array(3).fill(null).map((_, index) => (
					<div className="flex w-full flex-col gap-1" key={`skeleton.sector.${index}`}>
						<div className={clsx(animateClass, "h-4!")} />
						<div className={clsx(animateClass, "h-3! w-2/3")} />
					</div>
				))}
			</div>

			{carMetrics && (
				<div className="flex w-full gap-2">
					<div className={clsx(animateClass, "w-8")} />

					<div className="flex flex-1 flex-col gap-1">
						<div className={clsx(animateClass, "h-1/2!")} />
						<div className={clsx(animateClass, "h-1/2!")} />
					</div>
				</div>
			)}
		</div>
	);
};



---
File: /dash/src/components/dashboard/Map.tsx
---

import { useEffect, useMemo, useState } from "react";
import clsx from "clsx";

import type { PositionCar } from "@/types/state.type";
import type { Map, TrackPosition } from "@/types/map.type";

import { fetchMap } from "@/lib/fetchMap";

import { useDataStore, usePositionStore } from "@/stores/useDataStore";
import { useSettingsStore } from "@/stores/useSettingsStore";
import { getTrackStatusMessage } from "@/lib/getTrackStatusMessage";
import {
	createSectors,
	findYellowSectors,
	getSectorColor,
	type MapSector,
	prioritizeColoredSectors,
	rad,
	rotate,
} from "@/lib/map";

// This is basically fearlessly copied from
// https://github.com/tdjsnelling/monaco

const SPACE = 1000;
const ROTATION_FIX = 90;

type Corner = {
	number: number;
	pos: TrackPosition;
	labelPos: TrackPosition;
};

export default function Map() {
	const showCornerNumbers = useSettingsStore((state) => state.showCornerNumbers);
	const favoriteDrivers = useSettingsStore((state) => state.favoriteDrivers);

	const positions = usePositionStore((state) => state.positions);
	const drivers = useDataStore((state) => state?.driverList);
	const trackStatus = useDataStore((state) => state?.trackStatus);
	const timingDrivers = useDataStore((state) => state?.timingData);
	const raceControlMessages = useDataStore((state) => state?.raceControlMessages?.messages);
	const circuitKey = useDataStore((state) => state?.sessionInfo?.meeting.circuit.key);

	const [[minX, minY, widthX, widthY], setBounds] = useState<(null | number)[]>([null, null, null, null]);
	const [[centerX, centerY], setCenter] = useState<(null | number)[]>([null, null]);

	const [points, setPoints] = useState<null | { x: number; y: number }[]>(null);
	const [sectors, setSectors] = useState<MapSector[]>([]);
	const [corners, setCorners] = useState<Corner[]>([]);
	const [rotation, setRotation] = useState<number>(0);
	const [finishLine, setFinishLine] = useState<null | { x: number; y: number; startAngle: number }>(null);

	useEffect(() => {
		(async () => {
			if (!circuitKey) return;
			const mapJson = await fetchMap(circuitKey);

			if (!mapJson) return;

			const centerX = (Math.max(...mapJson.x) - Math.min(...mapJson.x)) / 2;
			const centerY = (Math.max(...mapJson.y) - Math.min(...mapJson.y)) / 2;

			const fixedRotation = mapJson.rotation + ROTATION_FIX;

			const sectors = createSectors(mapJson).map((s) => ({
				...s,
				start: rotate(s.start.x, s.start.y, fixedRotation, centerX, centerY),
				end: rotate(s.end.x, s.end.y, fixedRotation, centerX, centerY),
				points: s.points.map((p) => rotate(p.x, p.y, fixedRotation, centerX, centerY)),
			}));

			const cornerPositions: Corner[] = mapJson.corners.map((corner) => ({
				number: corner.number,
				pos: rotate(corner.trackPosition.x, corner.trackPosition.y, fixedRotation, centerX, centerY),
				labelPos: rotate(
					corner.trackPosition.x + 540 * Math.cos(rad(corner.angle)),
					corner.trackPosition.y + 540 * Math.sin(rad(corner.angle)),
					fixedRotation,
					centerX,
					centerY,
				),
			}));

			const rotatedPoints = mapJson.x.map((x, index) => rotate(x, mapJson.y[index], fixedRotation, centerX, centerY));

			const pointsX = rotatedPoints.map((item) => item.x);
			const pointsY = rotatedPoints.map((item) => item.y);

			const cMinX = Math.min(...pointsX) - SPACE;
			const cMinY = Math.min(...pointsY) - SPACE;
			const cWidthX = Math.max(...pointsX) - cMinX + SPACE * 2;
			const cWidthY = Math.max(...pointsY) - cMinY + SPACE * 2;

			const rotatedFinishLine = rotate(mapJson.x[0], mapJson.y[0], fixedRotation, centerX, centerY);

			const dx = rotatedPoints[3].x - rotatedPoints[0].x;
			const dy = rotatedPoints[3].y - rotatedPoints[0].y;
			const startAngle = Math.atan2(dy, dx) * (180 / Math.PI);

			setCenter([centerX, centerY]);
			setBounds([cMinX, cMinY, cWidthX, cWidthY]);
			setSectors(sectors);
			setPoints(rotatedPoints);
			setRotation(fixedRotation);
			setCorners(cornerPositions);
			setFinishLine({ x: rotatedFinishLine.x, y: rotatedFinishLine.y, startAngle });
		})();
	}, [circuitKey]);

	const yellowSectors = useMemo(() => findYellowSectors(raceControlMessages), [raceControlMessages]);

	const renderedSectors = useMemo(() => {
		const status = getTrackStatusMessage(trackStatus?.status ? parseInt(trackStatus.status) : undefined);

		return sectors
			.map((sector) => {
				const color = getSectorColor(sector, status?.bySector, status?.trackColor, yellowSectors);
				return {
					color,
					pulse: status?.pulse,
					number: sector.number,
					strokeWidth: color === "stroke-white" ? 60 : 120,
					d: `M${sector.points[0].x},${sector.points[0].y} ${sector.points.map((point) => `L${point.x},${point.y}`).join(" ")}`,
				};
			})
			.sort(prioritizeColoredSectors);
	}, [trackStatus, sectors, yellowSectors]);

	if (!points || !minX || !minY || !widthX || !widthY) {
		return (
			<div className="h-full w-full p-2" style={{ minHeight: "35rem" }}>
				<div className="h-full w-full animate-pulse rounded-lg bg-zinc-800" />
			</div>
		);
	}

	return (
		<svg
			viewBox={`${minX} ${minY} ${widthX} ${widthY}`}
			className="h-full w-full xl:max-h-screen"
			xmlns="http://www.w3.org/2000/svg"
		>
			<path
				className="stroke-gray-800"
				strokeWidth={300}
				strokeLinejoin="round"
				fill="transparent"
				d={`M${points[0].x},${points[0].y} ${points.map((point) => `L${point.x},${point.y}`).join(" ")}`}
			/>

			{renderedSectors.map((sector) => {
				const style = sector.pulse
					? {
							animation: `${sector.pulse * 100}ms linear infinite pulse`,
						}
					: {};
				return (
					<path
						key={`map.sector.${sector.number}`}
						className={sector.color}
						strokeWidth={sector.strokeWidth}
						strokeLinecap="round"
						strokeLinejoin="round"
						fill="transparent"
						d={sector.d}
						style={style}
					/>
				);
			})}

			{finishLine && (
				<rect
					x={finishLine.x - 75}
					y={finishLine.y}
					width={240}
					height={20}
					fill="red"
					stroke="red"
					strokeWidth={70}
					transform={`rotate(${finishLine.startAngle + 90}, ${finishLine.x + 25}, ${finishLine.y})`}
				/>
			)}

			{showCornerNumbers &&
				corners.map((corner) => (
					<CornerNumber
						key={`corner.${corner.number}`}
						number={corner.number}
						x={corner.labelPos.x}
						y={corner.labelPos.y}
					/>
				))}

			{centerX && centerY && positions && drivers && (
				<>
					{positions["241"] && positions["241"].Z !== 0 && (
						// Aston Martin
						<SafetyCar
							key="safety.car.241"
							rotation={rotation}
							centerX={centerX}
							centerY={centerY}
							pos={positions["241"]}
							color="229971"
						/>
					)}

					{positions["242"] && positions["242"].Z !== 0 && (
						// Aston Martin
						<SafetyCar
							key="safety.car.242"
							rotation={rotation}
							centerX={centerX}
							centerY={centerY}
							pos={positions["242"]}
							color="229971"
						/>
					)}

					{positions["243"] && positions["243"].Z !== 0 && (
						// Mercedes
						<SafetyCar
							key="safety.car.243"
							rotation={rotation}
							centerX={centerX}
							centerY={centerY}
							pos={positions["243"]}
							color="B90F09"
						/>
					)}

					{Object.values(drivers)
						.reverse()
						.filter((driver) => !!positions[driver.racingNumber].X && !!positions[driver.racingNumber].Y)
						.map((driver) => {
							const timingDriver = timingDrivers?.lines[driver.racingNumber];
							const hidden = timingDriver
								? timingDriver.knockedOut || timingDriver.stopped || timingDriver.retired
								: false;
							const pit = timingDriver ? timingDriver.inPit : false;

							return (
								<CarDot
									key={`map.driver.${driver.racingNumber}`}
									favoriteDriver={favoriteDrivers.length > 0 ? favoriteDrivers.includes(driver.racingNumber) : false}
									name={driver.tla}
									color={driver.teamColour}
									pit={pit}
									hidden={hidden}
									pos={positions[driver.racingNumber]}
									rotation={rotation}
									centerX={centerX}
									centerY={centerY}
								/>
							);
						})}
				</>
			)}
		</svg>
	);
}

type CornerNumberProps = {
	number: number;
	x: number;
	y: number;
};

const CornerNumber: React.FC<CornerNumberProps> = ({ number, x, y }) => {
	return (
		<text x={x} y={y} className="fill-zinc-700" fontSize={300} fontWeight="semibold">
			{number}
		</text>
	);
};

type CarDotProps = {
	name: string;
	color: string | undefined;
	favoriteDriver: boolean;

	pit: boolean;
	hidden: boolean;

	pos: PositionCar;
	rotation: number;

	centerX: number;
	centerY: number;
};

const CarDot = ({ pos, name, color, favoriteDriver, pit, hidden, rotation, centerX, centerY }: CarDotProps) => {
	const rotatedPos = rotate(pos.X, pos.Y, rotation, centerX, centerY);
	const transform = [`translateX(${rotatedPos.x}px)`, `translateY(${rotatedPos.y}px)`].join(" ");

	return (
		<g
			className={clsx("fill-zinc-700", { "opacity-30": pit }, { "opacity-0!": hidden })}
			style={{
				transition: "all 1s linear",
				transform,
				...(color && { fill: `#${color}` }),
			}}
		>
			<circle id={`map.driver.circle`} r={120} />
			<text
				id={`map.driver.text`}
				fontWeight="bold"
				fontSize={120 * 3}
				style={{
					transform: "translateX(150px) translateY(-120px)",
				}}
			>
				{name}
			</text>

			{favoriteDriver && (
				<circle
					id={`map.driver.favorite`}
					className="stroke-sky-400"
					r={180}
					fill="transparent"
					strokeWidth={40}
					style={{ transition: "all 1s linear" }}
				/>
			)}
		</g>
	);
};

type SafetyCarProps = {
	pos: PositionCar;
	rotation: number;
	centerX: number;
	centerY: number;
	color: string;
};

const SafetyCar = ({ pos, rotation, centerX, centerY, color }: SafetyCarProps) => {
	const useSafetyCarColors = useSettingsStore((state) => state.useSafetyCarColors);

	return (
		<CarDot
			name="Safety Car"
			pos={pos}
			rotation={rotation}
			centerX={centerX}
			centerY={centerY}
			favoriteDriver={false}
			pit={false}
			hidden={false}
			color={useSafetyCarColors ? color : "DDD"}
		/>
	);
};



---
File: /dash/src/components/dashboard/RaceControl.tsx
---

import { AnimatePresence } from "motion/react";
import { useEffect, useRef } from "react";
import clsx from "clsx";

import { useSettingsStore } from "@/stores/useSettingsStore";
import { useDataStore } from "@/stores/useDataStore";

import { sortUtc } from "@/lib/sorting";

import { RaceControlMessage } from "@/components/dashboard/RaceControlMessage";

export default function RaceControl() {
	const messages = useDataStore((state) => state.raceControlMessages?.messages);
	const gmtOffset = useDataStore((state) => state.sessionInfo?.gmtOffset);

	const raceControlChime = useSettingsStore((state) => state.raceControlChime);
	const raceControlChimeVolume = useSettingsStore((state) => state.raceControlChimeVolume);

	const chimeRef = useRef<HTMLAudioElement | null>(null);
	const pastMessageTimestamps = useRef<string[] | null>(null);

	useEffect(() => {
		if (typeof window !== "undefined") {
			const chime = new Audio("/sounds/chime.mp3");
			chime.volume = raceControlChimeVolume / 100;
			chimeRef.current = chime;

			return () => {
				chimeRef.current = null;
			};
		}
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, []);

	useEffect(() => {
		if (typeof window === "undefined") return;

		if (messages === undefined) return;

		if (!pastMessageTimestamps.current) {
			pastMessageTimestamps.current = messages.map((msg) => msg.utc);
			return;
		}

		const newMessages = messages.filter((msg) => !pastMessageTimestamps.current?.includes(msg.utc));

		if (newMessages.length > 0 && raceControlChime) {
			chimeRef.current?.play();
		}

		pastMessageTimestamps.current = messages.map((msg) => msg.utc);
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [messages]);

	return (
		<ul className="flex flex-col gap-2">
			{!messages &&
				new Array(7).fill("").map((_, index) => <SkeletonMessage key={`msg.loading.${index}`} index={index} />)}

			{messages && gmtOffset && (
				<AnimatePresence>
					{messages
						.sort(sortUtc)
						.filter((msg) => (msg.flag ? msg.flag.toLowerCase() !== "blue" : true))
						.map((msg, i) => (
							<RaceControlMessage key={`msg.${i}`} msg={msg} gmtOffset={gmtOffset} />
						))}
				</AnimatePresence>
			)}
		</ul>
	);
}

const SkeletonMessage = ({ index }: { index: number }) => {
	const animateClass = "h-6 animate-pulse rounded-md bg-zinc-800";

	const flag = index % 4 === 0;
	const long = index % 5 === 0;
	const mid = index % 3 === 0;

	return (
		<li className="flex flex-col gap-1 p-2">
			<div className={clsx(animateClass, "h-4! w-16")} />

			<div className="flex gap-1">
				{flag && <div className={clsx(animateClass, "w-6")} />}
				<div className={animateClass} style={{ width: long ? "100%" : mid ? "75%" : "40%" }} />
			</div>
		</li>
	);
};



---
File: /dash/src/components/dashboard/RaceControlMessage.tsx
---

import { motion } from "motion/react";
import { utc } from "moment";
import Image from "next/image";
import clsx from "clsx";

import type { Message } from "@/types/state.type";

import { useSettingsStore } from "@/stores/useSettingsStore";

import { toTrackTime } from "@/lib/toTrackTime";

type Props = {
	msg: Message;
	gmtOffset: string;
};

const getDriverNumber = (msg: Message) => {
	const match = msg.message.match(/CAR (\d+)/);
	return match?.[1];
};

export function RaceControlMessage({ msg, gmtOffset }: Props) {
	const favoriteDriver = useSettingsStore((state) => state.favoriteDrivers.includes(getDriverNumber(msg) ?? ""));

	const localTime = utc(msg.utc).local().format("HH:mm:ss");
	const trackTime = utc(toTrackTime(msg.utc, gmtOffset)).format("HH:mm");

	return (
		<motion.li
			layout="position"
			animate={{ opacity: 1, scale: 1 }}
			initial={{ opacity: 0, scale: 0.8 }}
			className={clsx("flex items-center justify-between gap-1 rounded-lg p-2", { "bg-sky-800/30": favoriteDriver })}
		>
			<div>
				<div className="flex items-center gap-1 text-sm leading-none text-zinc-500">
					{msg.lap && (
						<>
							<p>Lap {msg.lap}</p>
							{"·"}
						</>
					)}
					<time dateTime={localTime}>{localTime}</time>
					{"·"}
					<time className="text-zinc-700" dateTime={trackTime}>
						{trackTime}
					</time>
				</div>

				<p className="text-sm">{msg.message}</p>
			</div>

			{msg.flag && msg.flag !== "CLEAR" && (
				<Image
					src={`/flags/${msg.flag.toLowerCase().replaceAll(" ", "-")}-flag.svg`}
					alt={msg.flag}
					width={25}
					height={25}
				/>
			)}
		</motion.li>
	);
}



---
File: /dash/src/components/dashboard/RadioMessage.tsx
---

import { useRef, useState } from "react";
import { motion } from "motion/react";
import { utc } from "moment";
import clsx from "clsx";

import type { Driver, RadioCapture } from "@/types/state.type";

import { useSettingsStore } from "@/stores/useSettingsStore";

import { toTrackTime } from "@/lib/toTrackTime";

import DriverTag from "@/components/driver/DriverTag";
import PlayControls from "@/components/ui/PlayControls";
import Progress from "@/components/ui/Progress";

type Props = {
	driver: Driver;
	capture: RadioCapture;
	basePath: string;
	gmtOffset: string;
};

export default function RadioMessage({ driver, capture, basePath, gmtOffset }: Props) {
	const audioRef = useRef<HTMLAudioElement | null>(null);
	const intervalRef = useRef<NodeJS.Timeout | null>(null);

	const [playing, setPlaying] = useState<boolean>(false);
	const [duration, setDuration] = useState<number>(10);
	const [progress, setProgress] = useState<number>(0);

	const loadMeta = () => {
		if (!audioRef.current) return;
		setDuration(audioRef.current.duration);
	};

	const onEnded = () => {
		setPlaying(false);
		setProgress(0);

		if (intervalRef.current) {
			clearInterval(intervalRef.current);
		}
	};

	const updateProgress = () => {
		if (!audioRef.current) return;
		setProgress(audioRef.current.currentTime);
	};

	const togglePlayback = () => {
		setPlaying((old) => {
			if (!audioRef.current) return old;

			if (!old) {
				audioRef.current.play();
				intervalRef.current = setInterval(updateProgress, 10);
			} else {
				audioRef.current.pause();

				if (intervalRef.current) {
					clearInterval(intervalRef.current);
				}

				setTimeout(() => {
					setProgress(0);
					audioRef.current?.fastSeek(0);
				}, 10000);
			}

			return !old;
		});
	};

	const favoriteDriver = useSettingsStore((state) => state.favoriteDrivers.includes(driver.racingNumber));

	const localTime = utc(capture.utc).local().format("HH:mm:ss");
	const trackTime = utc(toTrackTime(capture.utc, gmtOffset)).format("HH:mm");

	return (
		<motion.li
			animate={{ opacity: 1, scale: 1 }}
			initial={{ opacity: 0, scale: 0.9 }}
			className={clsx("flex flex-col gap-1 rounded-lg p-2", { "bg-sky-800/30": favoriteDriver })}
		>
			<div className="flex items-center gap-1 text-sm leading-none text-zinc-500">
				<time dateTime={localTime}>{localTime}</time>
				{"·"}
				<time className="text-zinc-700" dateTime={trackTime}>
					{trackTime}
				</time>
			</div>

			<div className="flex items-center gap-1">
				<DriverTag className="!w-fit" teamColor={driver.teamColour} short={driver.tla} />

				<PlayControls playing={playing} onClick={togglePlayback} />
				<Progress duration={duration} progress={progress} />

				<audio
					preload="none"
					src={`${basePath}${capture.path}`}
					ref={audioRef}
					onEnded={() => onEnded()}
					onLoadedMetadata={() => loadMeta()}
				/>
			</div>
		</motion.li>
	);
}



---
File: /dash/src/components/dashboard/TeamRadios.tsx
---

import { AnimatePresence } from "motion/react";
import clsx from "clsx";

import { useDataStore } from "@/stores/useDataStore";

import { sortUtc } from "@/lib/sorting";

import RadioMessage from "@/components/dashboard/RadioMessage";

export default function TeamRadios() {
	const drivers = useDataStore((state) => state.driverList);
	const teamRadios = useDataStore((state) => state.teamRadio);
	const sessionPath = useDataStore((state) => state.sessionInfo?.path);

	const gmtOffset = useDataStore((state) => state.sessionInfo?.gmtOffset);

	const basePath = `https://livetiming.formula1.com/static/${sessionPath}`;

	// TODO add notice that we only show 20

	return (
		<ul className="flex flex-col gap-2">
			{!teamRadios && new Array(6).fill("").map((_, index) => <SkeletonMessage key={`radio.loading.${index}`} />)}

			{teamRadios && gmtOffset && drivers && teamRadios.captures && (
				<AnimatePresence>
					{teamRadios.captures
						.sort(sortUtc)
						.slice(0, 20)
						.map((teamRadio, i) => (
							<RadioMessage
								key={`radio.${i}`}
								driver={drivers[teamRadio.racingNumber]}
								capture={teamRadio}
								basePath={basePath}
								gmtOffset={gmtOffset}
							/>
						))}
				</AnimatePresence>
			)}
		</ul>
	);
}

const SkeletonMessage = () => {
	const animateClass = "h-6 animate-pulse rounded-md bg-zinc-800";

	return (
		<li className="flex flex-col gap-1 p-2">
			<div className={clsx(animateClass, "h-4! w-16")} />

			<div
				className="grid place-items-center items-center gap-4"
				style={{
					gridTemplateColumns: "2rem 20rem",
				}}
			>
				<div className="place-self-start">
					<div className={clsx(animateClass, "h-8! w-14")} />
				</div>

				<div className="flex items-center gap-4">
					<div className={clsx(animateClass, "h-6 w-6")} />
					<div className={clsx(animateClass, "h-2! w-60")} />
				</div>
			</div>
		</li>
	);
};



---
File: /dash/src/components/dashboard/TrackViolations.tsx
---

import type { Driver } from "@/types/state.type";

import { useDataStore } from "@/stores/useDataStore";

import DriverViolations from "./DriverViolations";

type Violations = {
	[key: string]: number;
};

const findCarNumber = (message: string): string | undefined => {
	const match = message.match(/CAR (\d+)/);
	return match?.[1];
};

const sortViolations = (driverA: Driver, driverB: Driver, violations: Violations): number => {
	const a = violations[driverA.racingNumber];
	const b = violations[driverB.racingNumber];
	return b - a;
};

export default function TrackViolations() {
	const messages = useDataStore((state) => state.raceControlMessages);
	const drivers = useDataStore((state) => state.driverList);
	const driversTiming = useDataStore((state) => state.timingData);

	const trackLimits =
		messages?.messages
			.filter((rcm) => rcm.category == "Other")
			.filter((rcm) => rcm.message.includes("TRACK LIMITS"))
			.reduce((acc: Violations, violations) => {
				const carNr = findCarNumber(violations.message);
				if (!carNr) return acc;

				if (acc[carNr] === undefined) {
					acc[carNr] = 1;
				} else {
					const newValue = acc[carNr] + 1;
					acc[carNr] = newValue;
				}

				return acc;
			}, {}) ?? {};

	const violationDrivers = drivers
		? Object.values(drivers).filter((driver) => trackLimits[driver.racingNumber] > 0)
		: undefined;

	return (
		<div className="flex flex-col gap-0.5">
			{violationDrivers && violationDrivers.length < 1 && (
				<div className="flex h-96 w-full flex-col items-center justify-center">
					<p className="text-gray-500">No violations yet</p>
				</div>
			)}

			{violationDrivers &&
				trackLimits &&
				violationDrivers
					.sort((a, b) => sortViolations(a, b, trackLimits))
					.map((driver) => (
						<DriverViolations
							key={`violation.driver.${driver.racingNumber}`}
							driver={driver}
							driversTiming={driversTiming ?? undefined}
							driverViolations={trackLimits[driver.racingNumber]}
						/>
					))}
		</div>
	);
}



---
File: /dash/src/components/driver/Driver.tsx
---

"use client";

import clsx from "clsx";
import { motion } from "motion/react";

import type { Driver, TimingDataDriver } from "@/types/state.type";

import { useSettingsStore } from "@/stores/useSettingsStore";
import { useCarDataStore, useDataStore } from "@/stores/useDataStore";

import DriverTag from "./DriverTag";
import DriverDRS from "./DriverDRS";
import DriverGap from "./DriverGap";
import DriverTire from "./DriverTire";
import DriverMiniSectors from "./DriverMiniSectors";
import DriverLapTime from "./DriverLapTime";
import DriverInfo from "./DriverInfo";
import DriverCarMetrics from "./DriverCarMetrics";

type Props = {
	position: number;
	driver: Driver;
	timingDriver: TimingDataDriver;
};

const hasDRS = (drs: number) => drs > 9;

const possibleDRS = (drs: number) => drs === 8;

const inDangerZone = (position: number, sessionPart: number) => {
	switch (sessionPart) {
		case 1:
			return position > 15;
		case 2:
			return position > 10;
		case 3:
		default:
			return false;
	}
};

export default function Driver({ driver, timingDriver, position }: Props) {
	const sessionPart = useDataStore((state) => state?.timingData?.sessionPart);
	const timingStatsDriver = useDataStore((state) => state?.timingStats?.lines[driver.racingNumber]);
	const appTimingDriver = useDataStore((state) => state?.timingAppData?.lines[driver.racingNumber]);
	const carData = useCarDataStore((state) =>
		state?.carsData ? state.carsData[driver.racingNumber].Channels : undefined,
	);

	const hasFastest = timingStatsDriver?.personalBestLapTime.position == 1;

	const carMetrics = useSettingsStore((state) => state.carMetrics);

	const favoriteDriver = useSettingsStore((state) => state.favoriteDrivers.includes(driver.racingNumber));

	return (
		<motion.div
			layout="position"
			className={clsx("flex flex-col gap-1 rounded-lg p-1.5 select-none", {
				"opacity-50": timingDriver.knockedOut || timingDriver.retired || timingDriver.stopped,
				"bg-sky-800/30": favoriteDriver,
				"bg-violet-800/30": hasFastest,
				"bg-red-800/30": sessionPart != undefined && inDangerZone(position, sessionPart),
			})}
		>
			<div
				className="grid items-center gap-2"
				style={{
					gridTemplateColumns: carMetrics
						? "5.5rem 3.5rem 5.5rem 4rem 5rem 5.5rem auto 10.5rem"
						: "5.5rem 3.5rem 5.5rem 4rem 5rem 5.5rem auto",
				}}
			>
				<DriverTag className="min-w-full!" short={driver.tla} teamColor={driver.teamColour} position={position} />
				<DriverDRS
					on={carData ? hasDRS(carData[45]) : false}
					possible={carData ? possibleDRS(carData[45]) : false}
					inPit={timingDriver.inPit}
					pitOut={timingDriver.pitOut}
				/>
				<DriverTire stints={appTimingDriver?.stints} />
				<DriverInfo timingDriver={timingDriver} gridPos={appTimingDriver ? parseInt(appTimingDriver.gridPos) : 0} />
				<DriverGap timingDriver={timingDriver} sessionPart={sessionPart} />
				<DriverLapTime last={timingDriver.lastLapTime} best={timingDriver.bestLapTime} hasFastest={hasFastest} />
				<DriverMiniSectors
					sectors={timingDriver.sectors}
					bestSectors={timingStatsDriver?.bestSectors}
					tla={driver.tla}
				/>

				{carMetrics && carData && <DriverCarMetrics carData={carData} />}
			</div>
		</motion.div>
	);
}



---
File: /dash/src/components/driver/DriverCarMetrics.tsx
---

import { useSettingsStore } from "@/stores/useSettingsStore";

import type { CarDataChannels } from "@/types/state.type";

import DriverPedals from "./DriverPedals";

type Props = {
	carData: CarDataChannels;
};

function convertKmhToMph(kmhValue: number) {
	return Math.floor(kmhValue / 1.609344);
}

export default function DriverCarMetrics({ carData }: Props) {
	const speedUnit = useSettingsStore((state) => state.speedUnit);

	return (
		<div className="flex items-center gap-2 place-self-start">
			<p className="flex h-8 w-8 items-center justify-center font-mono text-lg">{carData[3]}</p>

			<div>
				<p className="text-right font-mono leading-none font-medium">
					{speedUnit === "metric" ? carData[2] : convertKmhToMph(carData[2])}
				</p>
				<p className="text-sm leading-none text-zinc-600">{speedUnit === "metric" ? "km/h" : "mp/h"}</p>
			</div>

			<div className="flex flex-col">
				<div className="flex flex-col gap-1">
					<DriverPedals className="bg-red-500" value={carData[5]} maxValue={1} />
					<DriverPedals className="bg-emerald-500" value={carData[4]} maxValue={100} />
					<DriverPedals className="bg-blue-500" value={carData[0]} maxValue={15000} />
				</div>
			</div>
		</div>
	);
}



---
File: /dash/src/components/driver/DriverDRS.tsx
---

import clsx from "clsx";

type Props = {
	on: boolean;
	possible: boolean;
	inPit: boolean;
	pitOut: boolean;
};

export default function DriverDRS({ on, possible, inPit, pitOut }: Props) {
	const pit = inPit || pitOut;

	return (
		<span
			className={clsx(
				"text-md inline-flex h-8 w-full items-center justify-center rounded-md border-2 font-mono font-black",
				{
					"border-zinc-700 text-zinc-700": !pit && !on && !possible,
					"border-zinc-400 text-zinc-400": !pit && !on && possible,
					"border-emerald-500 text-emerald-500": !pit && on,
					"border-cyan-500 text-cyan-500": pit,
				},
			)}
		>
			{pit ? "PIT" : "DRS"}
		</span>
	);
}



---
File: /dash/src/components/driver/DriverGap.tsx
---

import clsx from "clsx";

import type { TimingDataDriver } from "@/types/state.type";

type Props = {
	timingDriver: TimingDataDriver;
	sessionPart: number | undefined;
};

export default function DriverGap({ timingDriver, sessionPart }: Props) {
	const gapToLeader =
		timingDriver.gapToLeader ??
		(timingDriver.stats ? timingDriver.stats[sessionPart ? sessionPart - 1 : 0].timeDiffToFastest : undefined) ??
		timingDriver.timeDiffToFastest ??
		"";

	const gapToFront =
		timingDriver.intervalToPositionAhead?.value ??
		(timingDriver.stats ? timingDriver.stats[sessionPart ? sessionPart - 1 : 0].timeDifftoPositionAhead : undefined) ??
		timingDriver.timeDiffToPositionAhead ??
		"";

	const catching = timingDriver.intervalToPositionAhead?.catching;

	return (
		<div className="place-self-start">
			<p
				className={clsx("text-lg leading-none font-medium tabular-nums", {
					"text-emerald-500": catching,
					"text-zinc-500": !gapToFront,
				})}
			>
				{!!gapToFront ? gapToFront : "-- ---"}
			</p>

			<p className="text-sm leading-none text-zinc-500 tabular-nums">{!!gapToLeader ? gapToLeader : "-- ---"}</p>
		</div>
	);
}



---
File: /dash/src/components/driver/DriverHistoryTires.tsx
---

import Image from "next/image";

import type { Stint } from "@/types/state.type";

type Props = {
	stints: Stint[] | undefined;
};

export default function DriverHistoryTires({ stints }: Props) {
	const unknownCompound = (stint: Stint) =>
		!["soft", "medium", "hard", "intermediate", "wet"].includes(stint.compound?.toLowerCase() ?? "");

	return (
		<div className="flex flex-row items-center justify-start gap-1">
			{stints &&
				stints.map((stint, i) => (
					<div className="flex flex-col items-center gap-1" key={`driver.${i}`}>
						{unknownCompound(stint) && <Image src={"/tires/unknown.svg"} width={32} height={32} alt="unknown" />}
						{!unknownCompound(stint) && stint.compound && (
							<Image
								src={`/tires/${stint.compound.toLowerCase()}.${"svg"}`}
								width={32}
								height={32}
								alt={stint?.compound ?? ""}
							/>
						)}

						<p className="text-sm leading-none font-medium whitespace-nowrap text-zinc-600">{stint.totalLaps}L</p>
					</div>
				))}

			{(!stints || stints.length < 1) && (
				<>
					<LoadingTire />
					<LoadingTire />
					<LoadingTire />
				</>
			)}
		</div>
	);
}

function LoadingTire() {
	return (
		<div className="flex flex-col items-center gap-1">
			<div className="h-8 w-8 animate-pulse rounded-full bg-zinc-800" />
			<div className="h-4 w-8 animate-pulse rounded-md bg-zinc-800" />
		</div>
	);
}



---
File: /dash/src/components/driver/DriverInfo.tsx
---

import clsx from "clsx";

import type { TimingDataDriver } from "@/types/state.type";

type Props = {
	timingDriver: TimingDataDriver;
	gridPos?: number;
};

export default function DriverInfo({ timingDriver, gridPos }: Props) {
	const positionChange = gridPos && gridPos - parseInt(timingDriver.position);
	const gain = positionChange && positionChange > 0;
	const loss = positionChange && positionChange < 0;

	const status = timingDriver.knockedOut
		? "OUT"
		: !!timingDriver.cutoff
			? "CUTOFF"
			: timingDriver.retired
				? "RETIRED"
				: timingDriver.stopped
					? "STOPPED"
					: timingDriver.inPit
						? "PIT"
						: timingDriver.pitOut
							? "PIT OUT"
							: null;

	return (
		<div className="place-self-start">
			<p
				className={clsx("text-lg leading-none font-medium tabular-nums", {
					"text-emerald-500": gain,
					"text-red-500": loss,
					"text-zinc-500": !gain && !loss,
				})}
			>
				{positionChange !== undefined
					? gain
						? `+${positionChange}`
						: loss
							? positionChange
							: "-"
					: `${timingDriver.numberOfLaps}L`}
			</p>

			<p className="text-sm leading-none text-zinc-500">{status ?? "-"}</p>
		</div>
	);
}



---
File: /dash/src/components/driver/DriverLapTime.tsx
---

import clsx from "clsx";

import type { TimingDataDriver } from "@/types/state.type";

type Props = {
	last: TimingDataDriver["lastLapTime"];
	best: TimingDataDriver["bestLapTime"];
	hasFastest: boolean;
};

export default function DriverLapTime({ last, best, hasFastest }: Props) {
	return (
		<div className="place-self-start">
			<p
				className={clsx("text-lg leading-none font-medium tabular-nums", {
					"text-violet-600!": last.overallFastest,
					"text-emerald-500!": last.personalFastest,
					"text-zinc-500!": !last.value,
				})}
			>
				{!!last.value ? last.value : "-- -- ---"}
			</p>
			<p
				className={clsx("text-sm leading-none text-zinc-500 tabular-nums", {
					"text-violet-600!": hasFastest,
					"text-zinc-500!": !best.value,
				})}
			>
				{!!best.value ? best.value : "-- -- ---"}
			</p>
		</div>
	);
}



---
File: /dash/src/components/driver/DriverMiniSectors.tsx
---

import clsx from "clsx";

import type { TimingDataDriver, TimingStatsDriver } from "@/types/state.type";
import { useSettingsStore } from "@/stores/useSettingsStore";

type Props = {
	sectors: TimingDataDriver["sectors"];
	bestSectors: TimingStatsDriver["bestSectors"] | undefined;
	tla: string;
};

export default function DriverMiniSectors({ sectors = [], bestSectors, tla }: Props) {
	const showMiniSectors = useSettingsStore((state) => state.showMiniSectors);
	const showBestSectors = useSettingsStore((state) => state.showBestSectors);

	return (
		<div className="flex gap-2">
			{sectors.map((sector, i) => (
				<div key={`sector.${tla}.${i}`} className="flex flex-col gap-1">
					{showMiniSectors && (
						<div className="flex flex-row gap-1">
							{sector.segments.map((segment, j) => (
								<MiniSector status={segment.status} key={`sector.mini.${tla}.${j}`} />
							))}
						</div>
					)}

					<div className={clsx("flex", showMiniSectors ? "items-center gap-1" : "flex-col")}>
						<p
							className={clsx("text-lg leading-none font-medium tabular-nums", {
								"text-violet-600!": sector.overallFastest,
								"text-emerald-500!": sector.personalFastest,
								"text-zinc-500": !sector.value,
							})}
						>
							{!!sector.value ? sector.value : !!sector.previousValue ? sector.previousValue : "-- ---"}
						</p>

						{showBestSectors && (
							<p
								className={clsx("text-sm leading-none text-zinc-500 tabular-nums", {
									"text-violet-600!": bestSectors?.[i].position === 1,
								})}
							>
								{bestSectors && bestSectors[i].value ? bestSectors[i].value : "-- ---"}
							</p>
						)}
					</div>
				</div>
			))}
		</div>
	);
}

function MiniSector({ status }: { status: number }) {
	return (
		<div
			style={{ width: 10, height: 5, borderRadius: 2 }}
			className={clsx({
				"bg-amber-400": status === 2048 || status === 2052, // TODO unsure
				"bg-emerald-500": status === 2049,
				"bg-violet-600": status === 2051,
				"bg-blue-500": status === 2064,
				"bg-zinc-700": status === 0,
			})}
		/>
	);
}



---
File: /dash/src/components/driver/DriverPedals.tsx
---

"use client";

import { motion } from "motion/react";
import clsx from "clsx";

type Props = {
	value: number;
	maxValue: number;
	className: string;
};

export default function DriverPedals({ className, value, maxValue }: Props) {
	const progress = value / maxValue;

	return (
		<div className="h-1.5 w-20 overflow-hidden rounded-xl bg-zinc-700">
			<motion.div
				className={clsx("h-1.5", className)}
				style={{ width: `${progress * 100}%` }}
				animate={{ transitionDuration: "0.1s" }}
				layout
			/>
		</div>
	);
}



---
File: /dash/src/components/driver/DriverTag.tsx
---

import clsx from "clsx";

type Props = {
	teamColor: string;
	short: string;
	position?: number;
	className?: string;
};

export default function DriverTag({ position, teamColor, short, className }: Props) {
	return (
		<div
			id="walkthrough-driver-position"
			className={clsx(
				"flex w-fit items-center justify-between gap-0.5 rounded-lg bg-zinc-500 px-1 py-1 font-black",
				className,
			)}
			style={{ backgroundColor: `#${teamColor}` }}
		>
			{position && <p className="px-1 text-xl leading-none">{position}</p>}

			<div className="flex h-min w-min items-center justify-center rounded-md bg-white px-1">
				<p className="font-mono text-zinc-500" style={{ ...(teamColor && { color: `#${teamColor}` }) }}>
					{short}
				</p>
			</div>
		</div>
	);
}



---
File: /dash/src/components/driver/DriverTire.tsx
---

import Image from "next/image";

import type { Stint } from "@/types/state.type";

type Props = {
	stints: Stint[] | undefined;
};

export default function DriverTire({ stints }: Props) {
	const stops = stints ? stints.length - 1 : 0;
	const currentStint = stints ? stints[stints.length - 1] : null;
	const unknownCompound = !["soft", "medium", "hard", "intermediate", "wet"].includes(
		currentStint?.compound?.toLowerCase() ?? "",
	);

	return (
		<div className="flex flex-row items-center gap-2 place-self-start">
			{currentStint && !unknownCompound && currentStint.compound && (
				<Image
					src={"/tires/" + currentStint.compound.toLowerCase() + ".svg"}
					width={32}
					height={32}
					alt={currentStint.compound}
				/>
			)}

			{currentStint && unknownCompound && (
				<div className="flex h-8 w-8 items-center justify-center">
					<Image src={"/tires/unknown.svg"} width={32} height={32} alt={"unknown"} />
				</div>
			)}

			{!currentStint && <div className="h-8 w-8 animate-pulse rounded-full bg-zinc-800 font-semibold" />}

			<div>
				<p className="leading-none font-medium">
					L {currentStint?.totalLaps ?? 0}
					{currentStint?.new ? "" : "*"}
				</p>

				<p className="text-sm leading-none text-zinc-500">PIT {stops}</p>
			</div>
		</div>
	);
}



---
File: /dash/src/components/schedule/Countdown.tsx
---

"use client";

import { AnimatePresence, motion } from "motion/react";
import { useEffect, useRef, useState } from "react";
import { duration, now, utc } from "moment";

import type { Session } from "@/types/schedule.type";

type Props = {
	next: Session;
	type: "race" | "other";
};

export default function Countdown({ next, type }: Props) {
	const [[days, hours, minutes, seconds], setDuration] = useState<
		[number | null, number | null, number | null, number | null]
	>([null, null, null, null]);

	const nextMoment = utc(next.start);

	const requestRef = useRef<number | null>(null);

	useEffect(() => {
		const animateNextFrame = () => {
			const diff = duration(nextMoment.diff(now()));

			const days = parseInt(diff.asDays().toString());

			if (diff.asSeconds() > 0) {
				setDuration([days, diff.hours(), diff.minutes(), diff.seconds()]);
			} else {
				setDuration([0, 0, 0, 0]);
			}

			requestRef.current = requestAnimationFrame(animateNextFrame);
		};

		requestRef.current = requestAnimationFrame(animateNextFrame);
		return () => (requestRef.current ? cancelAnimationFrame(requestRef.current) : void 0);
	}, [nextMoment]);

	return (
		<div>
			<p className="text-lg">Next {type === "race" ? "race" : "session"} in</p>

			<AnimatePresence>
				<div className="grid auto-cols-max grid-flow-col gap-4 text-3xl">
					<div>
						{days != undefined && days != null ? (
							<motion.p
								className="min-w-12"
								key={days}
								initial={{ y: -10, opacity: 0 }}
								animate={{ y: 0, opacity: 1 }}
								exit={{ y: 10, opacity: 0 }}
							>
								{days}
							</motion.p>
						) : (
							<div className="h-9 w-12 animate-pulse rounded-md bg-zinc-800" />
						)}

						<p className="text-base text-zinc-500">days</p>
					</div>

					<div>
						{hours != undefined && hours != null ? (
							<motion.p
								className="min-w-12"
								key={hours}
								initial={{ y: -10, opacity: 0 }}
								animate={{ y: 0, opacity: 1 }}
								exit={{ y: 10, opacity: 0 }}
							>
								{hours}
							</motion.p>
						) : (
							<div className="h-9 w-12 animate-pulse rounded-md bg-zinc-800" />
						)}

						<p className="text-base text-zinc-500">hours</p>
					</div>

					<div>
						{minutes != undefined && minutes != null ? (
							<motion.p
								className="min-w-12"
								key={minutes}
								initial={{ y: -10, opacity: 0 }}
								animate={{ y: 0, opacity: 1 }}
								exit={{ y: 10, opacity: 0 }}
							>
								{minutes}
							</motion.p>
						) : (
							<div className="h-9 w-12 animate-pulse rounded-md bg-zinc-800" />
						)}

						<p className="text-base text-zinc-500">minutes</p>
					</div>

					<div>
						{seconds != undefined && seconds != null ? (
							<motion.p
								className="min-w-12"
								key={seconds}
								initial={{ y: -10, opacity: 0 }}
								animate={{ y: 0, opacity: 1 }}
								exit={{ y: 10, opacity: 0 }}
							>
								{seconds}
							</motion.p>
						) : (
							<div className="h-9 w-12 animate-pulse rounded-md bg-zinc-800" />
						)}

						<p className="text-base text-zinc-500">seconds</p>
					</div>
				</div>
			</AnimatePresence>
		</div>
	);
}



---
File: /dash/src/components/schedule/NextRound.tsx
---

import { connection } from "next/server";
import { utc } from "moment";

import Countdown from "@/components/schedule/Countdown";
import Round from "@/components/schedule/Round";

import { env } from "@/env";
import type { Round as RoundType } from "@/types/schedule.type";

export const getNext = async () => {
	await connection();

	try {
		const nextReq = await fetch(`${env.API_URL}/api/schedule/next`, {
			cache: "no-store",
		});
		const next: RoundType = await nextReq.json();

		return next;
	} catch (e) {
		console.error("error fetching next round", e);
		return null;
	}
};

export default async function NextRound() {
	const next = await getNext();

	if (!next) {
		return (
			<div className="flex h-44 flex-col items-center justify-center">
				<p>No upcoming weekend found</p>
			</div>
		);
	}

	const nextSession = next.sessions.filter((s) => utc(s.start) > utc() && s.kind.toLowerCase() !== "race")[0];
	const nextRace = next.sessions.find((s) => s.kind.toLowerCase() == "race");

	return (
		<div className="grid grid-cols-1 gap-8 sm:grid-cols-2">
			{nextSession || nextRace ? (
				<div className="flex flex-col gap-4">
					{nextSession && <Countdown next={nextSession} type="other" />}
					{nextRace && <Countdown next={nextRace} type="race" />}
				</div>
			) : (
				<div className="flex flex-col items-center justify-center">
					<p>No upcoming sessions found</p>
				</div>
			)}

			<Round round={next} />
		</div>
	);
}



---
File: /dash/src/components/schedule/Round.tsx
---

"use client";

import { now, utc } from "moment";
import clsx from "clsx";

import type { Round as RoundType } from "@/types/schedule.type";

import { groupSessionByDay } from "@/lib/groupSessionByDay";
import { formatDayRange, formatMonth } from "@/lib/dateFormatter";
import Flag from "@/components/Flag";

type Props = {
	round: RoundType;
	nextName?: string;
};

const countryCodeMap: Record<string, string> = {
	Australia: "aus",
	Austria: "aut",
	Azerbaijan: "aze",
	Bahrain: "brn",
	Belgium: "bel",
	Brazil: "bra",
	Canada: "can",
	China: "chn",
	Spain: "esp",
	France: "fra",
	"Great Britain": "gbr",
	"United Kingdom": "gbr",
	Germany: "ger",
	Hungary: "hun",
	Italy: "ita",
	Japan: "jpn",
	"Saudi Arabia": "ksa",
	Mexico: "mex",
	Monaco: "mon",
	Netherlands: "ned",
	Portugal: "por",
	Qatar: "qat",
	Singapore: "sgp",
	"United Arab Emirates": "uae",
	"United States": "usa",
};

export default function Round({ round, nextName }: Props) {
	const countryCode = countryCodeMap[round.countryName];

	return (
		<div className={clsx(round.over && "opacity-50")}>
			<div className="flex items-center justify-between border-b border-zinc-800 pb-2">
				<div className="flex items-center gap-2">
					<div className="flex items-center gap-2">
						<Flag countryCode={countryCode} className="h-8 w-11"></Flag>
						<p className="text-2xl">{round.countryName}</p>
					</div>
					{round.name === nextName && (
						<>
							{utc().isBetween(utc(round.start), utc(round.end)) ? (
								<p className="text-indigo-500">Current</p>
							) : (
								<p className="text-indigo-500">Up Next</p>
							)}
						</>
					)}
					{round.over && <p className="text-red-500">Over</p>}
				</div>

				<div className="flex gap-1">
					<p className="text-xl">{formatMonth(round.start, round.end)}</p>
					<p className="text-zinc-500">{formatDayRange(round.start, round.end)}</p>
				</div>
			</div>

			<div className="grid grid-cols-3 gap-8 pt-2">
				{groupSessionByDay(round.sessions).map((day, i) => (
					<div className="flex flex-col" key={`round.day.${i}`}>
						<p className="my-3 text-xl text-white">{utc(day.date).local().format("dddd")}</p>

						<div className="grid grid-rows-2 gap-2">
							{day.sessions.map((session, j) => (
								<div
									key={`round.day.${i}.session.${j}`}
									className={clsx("flex flex-col", !round.over && utc(session.end).isBefore(now()) && "opacity-50")}
								>
									<p className="w-28 overflow-hidden text-ellipsis whitespace-nowrap sm:w-auto">{session.kind}</p>

									<p className="text-sm leading-none text-zinc-500">
										{utc(session.start).local().format("HH:mm")} - {utc(session.end).local().format("HH:mm")}
									</p>
								</div>
							))}
						</div>
					</div>
				))}
			</div>
		</div>
	);
}



---
File: /dash/src/components/schedule/Schedule.tsx
---

import { connection } from "next/server";

import Round from "@/components/schedule/Round";

import type { Round as RoundType } from "@/types/schedule.type";

import { env } from "@/env";

export const getSchedule = async () => {
	await connection();

	try {
		const scheduleReq = await fetch(`${env.API_URL}/api/schedule`, {
			cache: "no-store",
		});
		const schedule: RoundType[] = await scheduleReq.json();

		return schedule;
	} catch (e) {
		console.error("error fetching schedule", e);
		return null;
	}
};

export default async function Schedule() {
	const schedule = await getSchedule();

	if (!schedule) {
		return (
			<div className="flex h-44 flex-col items-center justify-center">
				<p>Schedule not found</p>
			</div>
		);
	}

	const next = schedule.filter((round) => !round.over)[0];

	return (
		<div className="mb-20 grid grid-cols-1 gap-8 md:grid-cols-2">
			{schedule.map((round, roundI) => (
				<Round nextName={next?.name} round={round} key={`round.${roundI}`} />
			))}
		</div>
	);
}



---
File: /dash/src/components/schedule/WeekendSchedule.tsx
---

import { now, utc } from "moment";
import clsx from "clsx";

import { groupSessionByDay } from "@/lib/groupSessionByDay";

import type { Session } from "@/types/schedule.type";

type Props = {
	sessions: Session[];
};

export default function WeekendSchedule({ sessions }: Props) {
	return (
		<div className="grid grid-cols-3 gap-8 pt-2">
			{groupSessionByDay(sessions).map((day, i) => (
				<div className="flex flex-col" key={`next.round.day.${i}`}>
					<p>{utc(day.date).local().format("dddd")}</p>

					<div className="grid grid-rows-2 gap-2">
						{day.sessions.map((session, j) => (
							<div
								className={clsx("flex flex-col", utc(session.end).isBefore(now()) && "opacity-50")}
								key={`next.round.day.${i}.session.${j}`}
							>
								<p className="w-28 overflow-hidden text-ellipsis whitespace-nowrap sm:w-auto">{session.kind}</p>

								<p className="text-sm leading-none text-zinc-500">
									{utc(session.start).local().format("HH:mm")} - {utc(session.end).local().format("HH:mm")}
								</p>
							</div>
						))}
					</div>
				</div>
			))}
		</div>
	);
}



---
File: /dash/src/components/settings/FavoriteDrivers.tsx
---

"use client";

import { useEffect, useState } from "react";
import { motion } from "motion/react";
import Image from "next/image";

import xIcon from "public/icons/xmark.svg";

import type { Driver } from "@/types/state.type";

import { env } from "@/env";
import { useSettingsStore } from "@/stores/useSettingsStore";

import DriverTag from "@/components/driver/DriverTag";
import SelectMultiple from "@/components/ui/SelectMultiple";

export default function FavoriteDrivers() {
	const [drivers, setDrivers] = useState<Driver[] | null>(null);

	// TODO handle loading state
	// TODO handle error state
	// eslint-disable-next-line @typescript-eslint/no-unused-vars
	const [error, setError] = useState<string | null>(null);

	const { favoriteDrivers, setFavoriteDrivers, removeFavoriteDriver } = useSettingsStore();

	useEffect(() => {
		(async () => {
			try {
				const res = await fetch(`${env.NEXT_PUBLIC_LIVE_URL}/api/drivers`);
				const data = await res.json();
				setDrivers(data);
			} catch {
				setError("failed to fetch favorite drivers");
			}
		})();
	}, []);

	return (
		<div className="flex flex-col gap-2">
			<div className="flex gap-2">
				{favoriteDrivers.map((driverNumber) => {
					const driver = drivers?.find((d) => d.racingNumber === driverNumber);

					if (!driver) return null;

					return (
						<div key={driverNumber} className="flex items-center gap-1 rounded-xl border border-zinc-800 p-1">
							<DriverTag teamColor={driver.teamColour} short={driver.tla} />

							<motion.button
								whileHover={{ scale: 1.05 }}
								whileTap={{ scale: 0.95 }}
								onClick={() => removeFavoriteDriver(driverNumber)}
							>
								<Image src={xIcon} alt="x" width={30} />
							</motion.button>
						</div>
					);
				})}
			</div>

			<div className="w-80">
				<SelectMultiple
					placeholder="Select favorite drivers"
					options={drivers ? drivers.map((d) => ({ label: d.fullName, value: d.racingNumber })) : []}
					selected={favoriteDrivers}
					setSelected={setFavoriteDrivers}
				/>
			</div>
		</div>
	);
}



---
File: /dash/src/components/ui/Button.tsx
---

"use client";

import type { ReactNode } from "react";
import { motion } from "motion/react";
import clsx from "clsx";

type Props = {
	children: ReactNode;
	onClick?: () => void;
	className?: string;
};

export default function Button({ children, onClick, className }: Props) {
	// TODO add hover effect
	return (
		<motion.button
			whileHover={{ scale: 1.05 }}
			whileTap={{ scale: 0.95 }}
			className={clsx(className, "rounded-lg bg-zinc-800 p-2 text-center leading-none text-white")}
			onClick={onClick}
		>
			{children}
		</motion.button>
	);
}



---
File: /dash/src/components/ui/Input.tsx
---

"use client";

import clsx from "clsx";

type Props = {
	value: string;
	setValue: (value: string) => void;
};

export default function Input({ value, setValue }: Props) {
	return (
		<input
			className={clsx(
				"w-12 [appearance:textfield] rounded-lg bg-zinc-800 p-1 text-center text-sm [&::-webkit-inner-spin-button]:appearance-none [&::-webkit-outer-spin-button]:appearance-none",
			)}
			type="text"
			value={value}
			onChange={(e) => setValue(e.target.value)}
		/>
	);
}



---
File: /dash/src/components/ui/Modal.tsx
---

import { AnimatePresence, motion } from "motion/react";
import { type ReactNode } from "react";

type Props = {
	open: boolean;
	children: ReactNode;
};

export default function Modal({ children, open }: Props) {
	return (
		<AnimatePresence>
			{open && (
				<motion.div
					initial={{ opacity: 0 }}
					exit={{ opacity: 0 }}
					animate={{ opacity: 1 }}
					className="relative z-10"
					aria-labelledby="modal-title"
					role="dialog"
					aria-modal
				>
					<div className="fixed inset-0 backdrop-blur-xs transition-opacity" />

					<div className="fixed inset-0 z-40 w-screen overflow-y-auto">
						<div className="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
							<motion.div
								initial={{ opacity: 0, scale: 0.9 }}
								exit={{ opacity: 0, scale: 0.9 }}
								animate={{ opacity: 1, scale: 1 }}
								className="relative overflow-hidden rounded-xl bg-zinc-900 p-4 shadow-xl"
							>
								{children}
							</motion.div>
						</div>
					</div>
				</motion.div>
			)}
		</AnimatePresence>
	);
}



---
File: /dash/src/components/ui/PlayControls.tsx
---

"use client";

import { clsx } from "clsx";
import { AnimatePresence, motion } from "motion/react";

type Props = {
	id?: string;
	className?: string;
	playing: boolean;
	loading?: boolean;
	onClick: () => void;
};

export default function PlayControls({ id, className, playing, loading = false, onClick }: Props) {
	const variants = {
		initial: { opacity: 0, scale: 0.5 },
		animate: { opacity: 1, scale: 1 },
		exit: { opacity: 0, scale: 0.5 },
	};

	return (
		<div
			id={id}
			className={clsx("flex h-8 w-8 cursor-pointer items-center justify-center", className)}
			onClick={onClick}
		>
			<AnimatePresence>
				{!playing && !loading && (
					<motion.svg
						initial={variants.initial}
						animate={variants.animate}
						exit={variants.exit}
						width="13"
						height="16"
						viewBox="0 0 13 16"
						fill="none"
						xmlns="http://www.w3.org/2000/svg"
					>
						<motion.path
							d="M12 6.26795C13.3333 7.03775 13.3333 8.96225 12 9.73205L3 14.9282C1.66667 15.698 0 14.7358 0 13.1962L0 2.80385C0 1.26425 1.66667 0.301996 3 1.0718L12 6.26795Z"
							fill="white"
						/>
					</motion.svg>
				)}

				{playing && (
					<motion.svg
						initial={variants.initial}
						animate={variants.animate}
						exit={variants.exit}
						width="10"
						height="14"
						viewBox="0 0 10 14"
						fill="none"
						xmlns="http://www.w3.org/2000/svg"
					>
						<motion.rect x="7" width="3" height="14" rx="1.5" fill="white" />
						<motion.rect width="3" height="14" rx="1.5" fill="white" />
					</motion.svg>
				)}

				{!playing && loading && (
					<motion.svg
						initial={variants.initial}
						animate={variants.animate}
						exit={variants.exit}
						width="24"
						height="24"
						viewBox="0 0 24 24"
						fill="#fff"
						xmlns="http://www.w3.org/2000/svg"
					>
						<circle className="pulse-loading-spinner" cx="12" cy="12" r="0" />
						<circle className="pulse-loading-spinner" style={{ animationDelay: ".6s" }} cx="12" cy="12" r="0" />
					</motion.svg>
				)}
			</AnimatePresence>
		</div>
	);
}



---
File: /dash/src/components/ui/Progress.tsx
---

"use client";

import { motion } from "motion/react";

type Props = {
	duration: number;
	progress: number;
};

export default function Progress({ duration, progress }: Props) {
	const percent = progress / duration;

	return (
		<div className="h-2 w-full max-w-60 overflow-hidden rounded-xl bg-white/50">
			<motion.div
				className="h-2 bg-white"
				style={{ width: `${percent * 100}%` }}
				animate={{ transitionDuration: "0.1s" }}
				layout
			/>
		</div>
	);
}



---
File: /dash/src/components/ui/SegmentedControls.tsx
---

"use client";

import clsx from "clsx";
import { LayoutGroup, motion } from "motion/react";

type Props<T> = {
	id?: string;
	className?: string;
	options: {
		label: string;
		value: T;
	}[];
	selected: T;
	onSelect?: (val: T) => void;
};

export default function SegmentedControls<T>({ id, className, options, selected, onSelect }: Props<T>) {
	return (
		<LayoutGroup>
			<motion.div
				id={id}
				layoutRoot
				className={clsx("m-0 inline-flex h-fit justify-between rounded-lg bg-zinc-800 p-0.5", className)}
			>
				{options.map((option) => {
					const isActive = option.value === selected;
					return (
						<motion.div
							className="relative mb-0 leading-none"
							whileTap={isActive ? { scale: 0.95 } : { opacity: 0.6 }}
							key={option.label}
						>
							<button
								onClick={() => (onSelect ? onSelect(option.value) : void 0)}
								className="relative m-0 border-none bg-transparent px-5 py-2 leading-none"
							>
								{isActive && (
									<motion.div
										layoutDependency={isActive}
										layoutId={`segment-${id}`}
										className="absolute top-0 right-0 bottom-0 left-0 z-1 rounded-md bg-zinc-600"
									/>
								)}
								<span className="relative z-2">{option.label}</span>
							</button>
						</motion.div>
					);
				})}
			</motion.div>
		</LayoutGroup>
	);
}



---
File: /dash/src/components/ui/Select.tsx
---

"use client";

import { Combobox, ComboboxButton, ComboboxInput, ComboboxOption, ComboboxOptions } from "@headlessui/react";
import { useState } from "react";
import clsx from "clsx";

type Option<T> = {
	value: T;
	label: string;
};

type Props<T> = {
	placeholder?: string;

	options: Option<T>[];

	selected: T | null;
	setSelected: (value: T | null) => void;
};

export default function Select<T>({ placeholder, options, selected, setSelected }: Props<T>) {
	const [query, setQuery] = useState("");

	const filteredOptions =
		query === "" ? options : options.filter((option) => option.label.toLowerCase().includes(query.toLowerCase()));

	return (
		<Combobox value={selected} onChange={(value) => setSelected(value)} onClose={() => setQuery("")}>
			<div className="relative">
				<ComboboxInput
					placeholder={placeholder}
					className={clsx(
						"w-full rounded-lg border-none bg-white/5 py-1.5 pr-8 pl-3 text-sm/6 text-white",
						"focus:outline-hidden data-focus:outline-2 data-focus:-outline-offset-2 data-focus:outline-white/25",
					)}
					displayValue={(option: Option<T> | null) => option?.label ?? ""}
					onChange={(event) => setQuery(event.target.value)}
				/>
				<ComboboxButton className="group absolute inset-y-0 right-0 px-2.5">
					{/* <ChevronDownIcon className="size-4 fill-white/60 group-data-hover:fill-white" /> */}
				</ComboboxButton>
			</div>

			<ComboboxOptions
				anchor="bottom"
				className={clsx(
					"w-[var(--input-width)] rounded-xl border border-white/5 bg-white/5 p-1 [--anchor-gap:var(--spacing-1)] empty:invisible",
					"transition duration-100 ease-in data-leave:data-closed:opacity-0",
				)}
			>
				{filteredOptions.map((option, idx) => (
					<ComboboxOption
						key={idx}
						value={option.value}
						className="group flex cursor-pointer items-center gap-2 rounded-lg px-3 py-1.5 select-none data-focus:bg-white/10"
					>
						{/* <CheckIcon className="invisible size-4 fill-white group-data-selected:visible" /> */}
						<div className="text-sm/6 text-white">{option.label}</div>
					</ComboboxOption>
				))}
			</ComboboxOptions>
		</Combobox>
	);
}



---
File: /dash/src/components/ui/SelectMultiple.tsx
---

"use client";

import { Combobox, ComboboxButton, ComboboxInput, ComboboxOption, ComboboxOptions } from "@headlessui/react";
import { useState } from "react";
import clsx from "clsx";

type Option<T> = {
	value: T;
	label: string;
};

type Props<T> = {
	placeholder?: string;

	options: Option<T>[];

	selected: T[];
	setSelected: (value: T[]) => void;
};

export default function SelectMultiple<T>({ placeholder, options, selected, setSelected }: Props<T>) {
	const [query, setQuery] = useState("");

	const filteredOptions =
		query === "" ? options : options.filter((option) => option.label.toLowerCase().includes(query.toLowerCase()));

	return (
		<Combobox value={selected} onChange={(value) => setSelected(value)} onClose={() => setQuery("")} multiple>
			<div className="relative">
				<ComboboxInput
					placeholder={placeholder}
					className={clsx(
						"w-full rounded-lg border-none bg-zinc-900 py-1.5 pr-8 pl-3 text-sm/6 text-white",
						"focus:outline-hidden data-focus:outline-2 data-focus:-outline-offset-2 data-focus:outline-zinc-700",
					)}
					displayValue={(option: Option<T> | null) => option?.label ?? ""}
					onChange={(event) => setQuery(event.target.value)}
				/>
				<ComboboxButton className="group absolute inset-y-0 right-0 px-2.5">
					{/* <ChevronDownIcon className="size-4 fill-white/60 group-data-hover:fill-white" /> */}
				</ComboboxButton>
			</div>

			<ComboboxOptions
				anchor="bottom"
				className={clsx(
					"w-[var(--input-width)] rounded-xl border border-white/5 bg-zinc-900 p-1 [--anchor-gap:var(--spacing-1)] empty:invisible",
					"z-50 mt-1 transition duration-100 ease-in data-leave:data-closed:opacity-0",
				)}
			>
				{filteredOptions.slice(0, 5).map((option, idx) => (
					<ComboboxOption
						key={idx}
						value={option.value}
						className="group flex cursor-pointer items-center gap-2 rounded-lg px-3 py-1.5 select-none data-focus:bg-white/10"
					>
						{/* <CheckIcon className="invisible size-4 fill-white group-data-selected:visible" /> */}
						<div className="text-sm/6 text-white">{option.label}</div>
					</ComboboxOption>
				))}
			</ComboboxOptions>
		</Combobox>
	);
}



---
File: /dash/src/components/ui/Slider.tsx
---

"use client";

import clsx from "clsx";

type Props = {
	className?: string;
	value: number;
	setValue: (value: number) => void;
};

export default function Slider({ value, setValue, className }: Props) {
	return (
		<input
			type="range"
			value={value}
			className={clsx("h-2 w-full cursor-pointer appearance-none rounded-lg bg-zinc-800", className)}
			onChange={(e) => setValue(Number(e.target.value))}
		/>
	);
}



---
File: /dash/src/components/ui/Toggle.tsx
---

"use client";

import { Switch } from "@headlessui/react";
import clsx from "clsx";

type Props = {
	enabled: boolean;
	setEnabled: (value: boolean) => void;
};

export default function Toggle({ enabled, setEnabled }: Props) {
	return (
		<Switch.Group as="div" className="">
			<Switch
				checked={enabled}
				onChange={setEnabled}
				className={clsx(
					enabled ? "bg-indigo-500" : "bg-zinc-800",
					"relative inline-flex h-6 w-11 shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out",
				)}
			>
				<span
					aria-hidden="true"
					className={clsx(
						enabled ? "translate-x-5" : "translate-x-0",
						"pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow-sm ring-0 transition duration-200 ease-in-out",
					)}
				/>
			</Switch>
		</Switch.Group>
	);
}



---
File: /dash/src/components/ConnectionStatus.tsx
---

"use client";

import clsx from "clsx";

type Props = {
	connected?: boolean;
};

export default function ConnectionStatus({ connected }: Props) {
	return <div className={clsx("size-3 rounded-full", connected ? "bg-emerald-500" : "animate-pulse bg-red-500")} />;
}



---
File: /dash/src/components/DelayInput.tsx
---

"use client";

import clsx from "clsx";

import { useState, useRef, useEffect } from "react";

import { useSettingsStore } from "@/stores/useSettingsStore";

type Props = {
	className?: string;
	saveDelay?: number;
};

export default function DelayInput({ className, saveDelay }: Props) {
	const currentDelay = useSettingsStore((s) => s.delay);
	const setDelay = useSettingsStore((s) => s.setDelay);
	const isPaused = useSettingsStore((s) => s.delayIsPaused);

	const [delayState, setDelayState] = useState<string>(currentDelay.toString());

	const timeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);

	const updateDelay = (updateInput: boolean = false) => {
		const delay = delayState ? Math.max(parseInt(delayState), 0) : 0;
		setDelay(delay);
		if (updateInput) setDelayState(delay.toString());
	};

	useEffect(() => {
		if (isPaused) return;
		if (timeoutRef.current) clearTimeout(timeoutRef.current);
		timeoutRef.current = setTimeout(updateDelay, saveDelay || 0);
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [delayState]);

	useEffect(() => {
		if (!isPaused) setDelayState(currentDelay.toString());
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [isPaused]);

	useEffect(() => {
		if (isPaused) setDelayState(currentDelay.toString());
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [currentDelay]);

	const handleChange = (v: string) => {
		setDelayState(v);
	};

	return (
		<input
			className={clsx(
				"w-12 [appearance:textfield] rounded-lg bg-zinc-800 p-1 text-center text-sm disabled:opacity-50 [&::-webkit-inner-spin-button]:appearance-none [&::-webkit-outer-spin-button]:appearance-none",
				className,
			)}
			type="number"
			inputMode="numeric"
			min={0}
			placeholder="0s"
			value={delayState}
			onChange={(e) => handleChange(e.target.value)}
			onKeyDown={(e) => e.code == "Enter" && updateDelay(true)}
			onBlur={() => updateDelay(true)}
			disabled={isPaused}
		/>
	);
}



---
File: /dash/src/components/DelayTimer.tsx
---

"use client";

import { useRef } from "react";

import { useSettingsStore } from "@/stores/useSettingsStore";

import PlayControls from "@/components/ui/PlayControls";

export default function DelayTimer() {
	const intervalRef = useRef<NodeJS.Timeout | null>(null);
	const startTimeRef = useRef<number>(0);

	const setDelay = useSettingsStore((s) => s.setDelay);
	const currentDelay = useSettingsStore((s) => s.delay);
	const setDelayIsPaused = useSettingsStore((s) => s.setDelayIsPaused);
	const delayIsPaused = useSettingsStore((s) => s.delayIsPaused);

	const handleClick = () => {
		if (!delayIsPaused) {
			// Start timer from current delay
			startTimeRef.current = Date.now() - currentDelay * 1000;
			intervalRef.current = setInterval(() => {
				const elapsed = Math.floor((Date.now() - startTimeRef.current) / 1000);
				setDelay(elapsed);
			}, 100);
			setDelayIsPaused(true);
		} else {
			// Stop timer but keep current delay
			if (intervalRef.current) {
				clearInterval(intervalRef.current);
				intervalRef.current = null;
			}
			setDelayIsPaused(false);
		}
	};

	return <PlayControls playing={!delayIsPaused} onClick={handleClick} />;
}



---
File: /dash/src/components/Flag.tsx
---

import { clsx } from "clsx";
import Image from "next/image";

type Props = {
	countryCode: string | undefined;
	className?: string;
};

export default function Flag({ countryCode, className }: Props) {
	return (
		<div className={clsx("flex h-12 w-16 content-center justify-center", className)}>
			{countryCode ? (
				<Image
					src={`/country-flags/${countryCode.toLowerCase()}.${"svg"}`}
					alt={countryCode}
					width={64}
					height={48}
					className="overflow-hidden rounded-lg"
				/>
			) : (
				<div className="h-full w-full animate-pulse overflow-hidden rounded-lg bg-zinc-800" />
			)}
		</div>
	);
}



---
File: /dash/src/components/Footer.tsx
---

import Link from "next/link";

export default function Footer() {
	return (
		<footer className="my-8 text-sm text-zinc-500">
			<div className="mb-4 flex flex-wrap gap-2">
				<p>
					Made with ♥ by <TextLink website="https://slowly.dev">Slowly</TextLink>.
				</p>

				<p>
					<TextLink website="https://www.buymeacoffee.com/slowlydev">Buy me a coffee</TextLink> to support me.
				</p>

				<p>
					Contribute on <TextLink website="https://github.com/slowlydev/f1-dash">GitHub</TextLink>.
				</p>

				<p>
					Check out the Community <TextLink website="https://discord.gg/unJwu66NuB">Discord</TextLink>.
				</p>

				<p>
					Get{" "}
					<Link className="text-blue-500" href="/help">
						Help
					</Link>
					.
				</p>

				<p>Version: {process.env.version}</p>
			</div>

			<p>
				This project/website is unofficial and is not associated in any way with the Formula 1 companies. F1, FORMULA
				ONE, FORMULA 1, FIA FORMULA ONE WORLD CHAMPIONSHIP, GRAND PRIX and related marks are trademarks of Formula One
				Licensing B.V.
			</p>
		</footer>
	);
}

type TextLinkProps = {
	website: string;
	children: string;
};

const TextLink = ({ website, children }: TextLinkProps) => {
	return (
		<a className="text-blue-500" target="_blank" href={website}>
			{children}
		</a>
	);
};



---
File: /dash/src/components/LapCount.tsx
---

import { useDataStore } from "@/stores/useDataStore";

export default function LapCount() {
	const lapCount = useDataStore((state) => state.lapCount);

	return (
		<>
			{!!lapCount && (
				<p className="text-3xl font-extrabold whitespace-nowrap sm:hidden">
					{lapCount?.currentLap} / {lapCount?.totalLaps}
				</p>
			)}
		</>
	);
}



---
File: /dash/src/components/Note.tsx
---

import { type ReactNode } from "react";
import Image from "next/image";
import clsx from "clsx";

import infoIcon from "public/icons/info.svg";

type Props = {
	className?: string;
	children: ReactNode;
};

export default function Note({ children, className }: Props) {
	return (
		<div className={clsx("flex flex-col gap-1 border-l-4 border-blue-500 py-2 pl-4", className)}>
			<div className="flex items-center gap-1">
				<Image src={infoIcon} className="size-5" alt={"info icon"} />
				<p className="text-blue-500">Note</p>
			</div>
			<p>{children}</p>
		</div>
	);
}



---
File: /dash/src/components/NumberDiff.tsx
---

import clsx from "clsx";

type Props = {
	old: number;
	current: number;
};

export default function NumberDiff({ old, current }: Props) {
	const positionChange = old - current;
	const gain = positionChange > 0;
	const loss = positionChange < 0;

	return (
		<p
			className={clsx({
				"text-emerald-500": gain,
				"text-red-500": loss,
				"text-zinc-500": !gain && !loss,
			})}
		>
			{gain ? `+${positionChange}` : loss ? positionChange : "-"}
		</p>
	);
}



---
File: /dash/src/components/OledModeProvider.tsx
---

"use client";

import { useEffect, type ReactNode } from "react";

import { useSettingsStore } from "@/stores/useSettingsStore";

type Props = {
	children: ReactNode;
};

export default function OledModeProvider({ children }: Props) {
	const oledMode = useSettingsStore((state) => state.oledMode);

	useEffect(() => {
		document.documentElement.classList.toggle("bg-zinc-950", !oledMode);
		document.documentElement.classList.toggle("bg-black", oledMode);
	}, [oledMode]);

	return children;
}



---
File: /dash/src/components/Qualifying.tsx
---

"use client";

import { AnimatePresence } from "motion/react";
import clsx from "clsx";

import { useDataStore } from "@/stores/useDataStore";

import { sortQuali } from "@/lib/sorting";

import QualifyingDriver from "@/components/QualifyingDriver";

export default function Qualifying() {
	const driversTiming = useDataStore((state) => state.timingData);
	const appDriversTiming = useDataStore((state) => state.timingAppData);
	const drivers = useDataStore((state) => state.driverList);

	const qualifyingDrivers =
		!driversTiming?.lines || !drivers
			? []
			: Object.values(driversTiming.lines)
					.filter((d) => !d.pitOut && !d.inPit && !d.knockedOut && !d.stopped) // no out, no pit, no stopped
					.filter((d) => d.sectors.every((sec) => !sec.segments.find((s) => s.status === 2064))) // no in/out lap
					.filter((d) => d.sectors.map((s) => s.personalFastest).includes(true)); // has any personal fastest

	const sessionPart = driversTiming?.sessionPart;
	const comparingDriverPosition = sessionPart === 1 ? 15 : sessionPart === 2 ? 10 : sessionPart === 3 ? 1 : 1;
	const comparingDriver = driversTiming
		? Object.values(driversTiming.lines).find((d) => parseInt(d.position) === comparingDriverPosition)
		: undefined;

	return (
		<div className="flex gap-4 p-2">
			<AnimatePresence>
				{drivers &&
					qualifyingDrivers
						.sort(sortQuali)
						.map((timingDriver) => (
							<QualifyingDriver
								key={`qualifying.driver.${timingDriver.racingNumber}`}
								driver={drivers[timingDriver.racingNumber]}
								timingDriver={timingDriver}
								appTimingDriver={appDriversTiming?.lines[timingDriver.racingNumber]}
								currentBestName={comparingDriver ? drivers[comparingDriver?.racingNumber].tla : undefined}
								currentBestTime={comparingDriver ? comparingDriver.bestLapTime.value : undefined}
							/>
						))}

				{qualifyingDrivers.length < 1 && (
					<>
						{new Array(3).fill(null).map((_, i) => (
							<SkeletonQualifyingDriver key={`skeleton.qualifying.driver.${i}`} />
						))}
					</>
				)}
			</AnimatePresence>
		</div>
	);
}

const SkeletonQualifyingDriver = () => {
	const animateClass = "h-8 animate-pulse rounded-md bg-zinc-800";

	return (
		<div className="flex min-w-72 flex-col gap-2">
			<div className="flex justify-between">
				<div className={clsx(animateClass, "w-20")} />
				<div className={clsx(animateClass, "w-8")} />
			</div>

			<div className="flex w-full justify-between">
				<div className={clsx(animateClass, "w-8")} />

				<div className="flex flex-col items-end gap-1">
					<div className={clsx(animateClass, "h-4! w-10")} />
					<div className={clsx(animateClass, "h-3! w-14")} />
				</div>
			</div>

			<div className="flex w-full gap-1">
				{new Array(3).fill(null).map((_, index) => (
					<div className="flex w-full flex-col gap-1" key={`skeleton.sector.${index}`}>
						<div className={clsx(animateClass, "h-4!")} />
						<div className={clsx(animateClass, "h-3!")} />
					</div>
				))}
			</div>
		</div>
	);
};



---
File: /dash/src/components/QualifyingDriver.tsx
---

"use client";

import { motion } from "motion/react";
import Image from "next/image";
import clsx from "clsx";

import DriverTag from "./driver/DriverTag";

import type { Driver as DriverType, TimingAppDataDriver, TimingDataDriver } from "@/types/state.type";

type Props = {
	driver: DriverType;
	timingDriver: TimingDataDriver;
	appTimingDriver: TimingAppDataDriver | undefined;

	currentBestName: string | undefined;
	currentBestTime: string | undefined;
};

export default function DriverQuali({
	driver,
	timingDriver,
	appTimingDriver,
	currentBestName,
	currentBestTime,
}: Props) {
	const stints = appTimingDriver?.stints ?? [];
	const currentStint = stints ? stints[stints.length - 1] : null;
	const unknownCompound = !["soft", "medium", "hard", "intermediate", "wet"].includes(
		currentStint?.compound?.toLowerCase() ?? "",
	);

	const currentTime = timingDriver.sectors[2].value
		? timingDriver.sectors[2].value
		: timingDriver.sectors[1].value
			? timingDriver.sectors[1].value
			: timingDriver.sectors[0].value
				? timingDriver.sectors[0].value
				: "-- --";

	return (
		<motion.div
			layout
			className="flex min-w-72 flex-col gap-2"
			exit={{ opacity: 0 }}
			animate={{ opacity: 1 }}
			initial={{ opacity: 0 }}
		>
			<div className="flex justify-between">
				<DriverTag position={parseInt(timingDriver.position)} teamColor={driver.teamColour} short={driver.tla} />
				<div>
					{currentStint && !unknownCompound && currentStint.compound && (
						<Image
							src={`/tires/${currentStint.compound.toLowerCase()}.svg`}
							width={32}
							height={32}
							alt={currentStint.compound}
						/>
					)}

					{currentStint && unknownCompound && (
						<Image src={`/tires/unknown.svg`} width={32} height={32} alt={"unknown"} />
					)}

					{!currentStint && <div className="h-8 w-8 animate-pulse rounded-md bg-zinc-800 font-semibold" />}
				</div>
			</div>

			<div className="flex justify-between">
				<p className="text-3xl font-semibold">{currentTime}</p>

				<div className="flex flex-col items-end">
					{currentBestTime && (
						<>
							<p className="text-xl leading-none text-zinc-500">{currentBestTime}</p>
							<p className="text-sm leading-none font-medium text-zinc-500">{currentBestName}</p>
						</>
					)}
				</div>
			</div>

			<div className="grid grid-cols-3 gap-1">
				{timingDriver.sectors.map((sector, i) => (
					<div className="flex flex-col gap-1" key={`quali.sector.${driver.tla}.${i}`}>
						<div
							className={clsx("h-4 rounded-md", {
								"bg-zinc-500!": !sector.value,
								"bg-violet-500": sector.overallFastest,
								"bg-emerald-500": sector.personalFastest,
								"bg-amber-400": !sector.overallFastest && !sector.personalFastest,
							})}
						/>
						<p
							className={clsx("text-center text-lg leading-none font-semibold", {
								"text-zinc-500!": !sector.value,
								"text-violet-500": sector.overallFastest,
								"text-emerald-500": sector.personalFastest,
								"text-yellow-500": !sector.overallFastest && !sector.personalFastest,
							})}
						>
							{!!sector.value ? sector.value : "-- ---"}
						</p>
					</div>
				))}
			</div>
		</motion.div>
	);
}



---
File: /dash/src/components/ScrollHint.tsx
---

"use client";

import Image from "next/image";
import { motion } from "motion/react";

import downIcon from "public/icons/chevron-down.svg";

export default function ScrollHint() {
	return (
		<motion.div
			animate={{
				y: [0, 15, 0],
				transition: {
					repeat: Infinity,
					duration: 3.5,
					ease: "backInOut",
				},
			}}
			className="absolute bottom-20 mx-auto"
		>
			<Image alt="down icon" src={downIcon} width={20} height={20} />
		</motion.div>
	);
}



---
File: /dash/src/components/SessionInfo.tsx
---

"use client";

import { utc, duration } from "moment";

import { useDataStore } from "@/stores/useDataStore";
import { useSettingsStore } from "@/stores/useSettingsStore";

import Flag from "@/components/Flag";

const sessionPartPrefix = (name: string) => {
	switch (name) {
		case "Sprint Qualifying":
			return "SQ";
		case "Qualifying":
			return "Q";
		default:
			return "";
	}
};

export default function SessionInfo() {
	const clock = useDataStore((state) => state?.extrapolatedClock);
	const session = useDataStore((state) => state.sessionInfo);
	const timingData = useDataStore((state) => state.timingData);

	const delay = useSettingsStore((state) => state.delay);

	const timeRemaining =
		!!clock && !!clock.remaining
			? clock.extrapolating
				? utc(
						duration(clock.remaining)
							.subtract(utc().diff(utc(clock.utc)))
							.asMilliseconds() + (delay ? delay * 1000 : 0),
					).format("HH:mm:ss")
				: clock.remaining
			: undefined;

	return (
		<div className="flex items-center gap-2">
			<Flag countryCode={session?.meeting.country.code} />

			<div className="flex flex-col justify-center">
				{session ? (
					<h1 className="truncate text-sm leading-none font-medium text-white">
						{session.meeting.name}: {session.name ?? "Unknown"}
						{timingData?.sessionPart ? ` ${sessionPartPrefix(session.name)}${timingData.sessionPart}` : ""}
					</h1>
				) : (
					<div className="h-4 w-[250px] animate-pulse rounded-md bg-zinc-800" />
				)}

				{timeRemaining !== undefined ? (
					<p className="text-2xl leading-none font-extrabold">{timeRemaining}</p>
				) : (
					<div className="mt-1 h-6 w-[150px] animate-pulse rounded-md bg-zinc-800 font-semibold" />
				)}
			</div>
		</div>
	);
}



---
File: /dash/src/components/Sidebar.tsx
---

"use client";

import { usePathname } from "next/navigation";
import { AnimatePresence, motion } from "motion/react";
import { useEffect } from "react";
import Link from "next/link";
import clsx from "clsx";

import { useSidebarStore } from "@/stores/useSidebarStore";
import { useSettingsStore } from "@/stores/useSettingsStore";

import ConnectionStatus from "@/components/ConnectionStatus";
import DelayInput from "@/components/DelayInput";
import SidenavButton from "@/components/SidenavButton";
import DelayTimer from "@/components/DelayTimer";

const liveTimingItems = [
	{
		href: "/dashboard",
		name: "Dashboard",
	},
	{
		href: "/dashboard/track-map",
		name: "Track Map",
	},
	// {
	// 	href: "/dashboard/head-to-head",
	// 	name: "Head to Head",
	// },
	{
		href: "/dashboard/standings",
		name: "Standings",
	},
	{
		href: "/dashboard/weather",
		name: "Weather",
	},
];

type Props = {
	connected: boolean;
};

export default function Sidebar({ connected }: Props) {
	// const favoriteDrivers = useSettingsStore((state) => state.favoriteDrivers);
	// const drivers = useDataStore((state) => state.driverList);

	// const driverItems = drivers
	// 	? favoriteDrivers.map((nr) => ({
	// 			href: `/dashboard/driver/${nr}`,
	// 			name: drivers[nr].fullName,
	// 		}))
	// 	: null;

	const { opened, pinned } = useSidebarStore();
	const close = useSidebarStore((state) => state.close);
	const open = useSidebarStore((state) => state.open);

	const pin = useSidebarStore((state) => state.pin);
	const unpin = useSidebarStore((state) => state.unpin);
	
	const oledMode = useSettingsStore((state) => state.oledMode);

	useEffect(() => {
		const handleResize = () => {
			if (window.innerWidth < 768) {
				unpin();
			}
		};

		window.addEventListener("resize", handleResize);
		handleResize();

		return () => window.removeEventListener("resize", handleResize, false);
	}, [unpin]);

	return (
		<div>
			<motion.div className="hidden md:block" style={{ width: 216 }} animate={{ width: pinned ? 216 : 8 }} />

			<AnimatePresence>
				{opened && (
					<motion.div
						onTouchEnd={() => close()}
						className="fixed top-0 right-0 bottom-0 left-0 z-30 bg-black/20 backdrop-blur-sm md:hidden"
						initial={{ opacity: 0 }}
						animate={{ opacity: 1 }}
						exit={{ opacity: 0 }}
					/>
				)}
			</AnimatePresence>

			<motion.div
				className="no-scrollbar fixed top-0 bottom-0 left-0 z-40 flex overflow-y-auto"
				//
				onHoverEnd={!pinned ? () => close() : undefined}
				onHoverStart={!pinned ? () => open() : undefined}
				//
				animate={{ left: pinned || opened ? 0 : -216 }}
				transition={{ type: "spring", bounce: 0.1 }}
			>
				<nav
					className={clsx("m-2 flex w-52 flex-col p-2", {
						"rounded-lg border border-zinc-800": !pinned,
						"bg-black": oledMode,
						"bg-zinc-950": !oledMode,
					})}
				>
					<div className="flex items-center justify-between gap-2">
						<div className="flex items-center gap-2">
							<DelayInput saveDelay={500} />
							<DelayTimer />

							<ConnectionStatus connected={connected} />
						</div>

						<SidenavButton className="hidden md:flex" onClick={() => (pinned ? unpin() : pin())} />
						<SidenavButton className="md:hidden" onClick={() => close()} />
					</div>

					<p className="p-2 text-sm text-zinc-500">Live Timing</p>

					<div className="flex flex-col gap-1">
						{liveTimingItems.map((item) => (
							<Item key={item.href} item={item} />
						))}
					</div>

					{/* <p className="mt-4 p-2 text-sm text-zinc-500">Favorite Drivers</p>

					<div className="flex flex-col gap-1">
						{driverItems === null && (
							<>
								<div className="h-8 animate-pulse rounded-lg bg-zinc-800" />
								<div className="h-8 animate-pulse rounded-lg bg-zinc-800" />
							</>
						)}
						{driverItems !== null && driverItems.length === 0 && <div className="p-2">No favorites</div>}
						{driverItems?.map((item) => <Item key={item.href} item={item} />)}
					</div> */}

					<p className="mt-4 p-2 text-sm text-zinc-500">General</p>

					<div className="flex flex-col gap-1">
						<Item item={{ href: "/dashboard/settings", name: "Settings" }} />

						<Item target="_blank" item={{ href: "/schedule", name: "Schedule" }} />
						<Item target="_blank" item={{ href: "/help", name: "Help" }} />
						<Item target="_blank" item={{ href: "/", name: "Home" }} />
					</div>

					<p className="mt-4 p-2 text-sm text-zinc-500">Links</p>

					<div className="flex flex-col gap-1">
						<Item target="_blank" item={{ href: "https://github.com/slowlydev/f1-dash", name: "Github" }} />
						<Item target="_blank" item={{ href: "https://discord.gg/unJwu66NuB", name: "Discord" }} />
						<Item target="_blank" item={{ href: "https://buymeacoffee.com/slowlydev", name: "Buy me a coffee" }} />
						<Item target="_blank" item={{ href: "https://github.com/sponsors/slowlydev", name: "Sponsor me" }} />
					</div>
				</nav>
			</motion.div>
		</div>
	);
}

type ItemProps = {
	target?: string;
	item: { href: string; name: string };
};

const Item = ({ target, item }: ItemProps) => {
	const active = usePathname() === item.href;

	return (
		<Link href={item.href} target={target}>
			<div
				className={clsx("rounded-lg p-1 px-2 hover:bg-zinc-900", {
					"bg-zinc-800!": active,
				})}
			>
				{item.name}
			</div>
		</Link>
	);
};



---
File: /dash/src/components/SidenavButton.tsx
---

"use client";

import clsx from "clsx";
import { motion } from "motion/react";
import Image from "next/image";

import sidebarIcon from "public/icons/sidebar.svg";

type Props = {
	className?: string;
	onClick: () => void;
};

export default function SidenavButton({ className, onClick }: Props) {
	return (
		<motion.button
			onClick={onClick}
			animate={{ scale: 1, opacity: 1 }}
			exit={{ scale: 0, opacity: 0 }}
			whileTap={{ scale: 0.9 }}
			className={clsx("flex size-12 cursor-pointer items-center justify-center", className)}
		>
			<Image src={sidebarIcon} alt="sidebar icon" loading="eager" />
		</motion.button>
	);
}



---
File: /dash/src/components/TrackInfo.tsx
---

"use client";

import clsx from "clsx";

import { useDataStore } from "@/stores/useDataStore";

import { getTrackStatusMessage } from "@/lib/getTrackStatusMessage";

export default function TrackInfo() {
	const lapCount = useDataStore((state) => state.lapCount);
	const track = useDataStore((state) => state.trackStatus);

	const currentTrackStatus = getTrackStatusMessage(track?.status ? parseInt(track?.status) : undefined);

	return (
		<div className="flex flex-row items-center gap-4 md:justify-self-end">
			{!!lapCount && (
				<p className="text-3xl font-extrabold whitespace-nowrap">
					{lapCount?.currentLap} / {lapCount?.totalLaps}
				</p>
			)}

			{!!currentTrackStatus ? (
				<div
					className={clsx("flex h-8 items-center truncate rounded-md px-2", currentTrackStatus.color)}
					style={{
						boxShadow: `0 0 60px 10px ${currentTrackStatus.hex}`,
					}}
				>
					<p className="text-lg font-medium">{currentTrackStatus.message}</p>
				</div>
			) : (
				<div className="relative h-8 w-28 animate-pulse overflow-hidden rounded-lg bg-zinc-800" />
			)}
		</div>
	);
}



---
File: /dash/src/components/WeatherInfo.tsx
---

import TemperatureComplication from "./complications/Temperature";
import HumidityComplication from "./complications/Humidity";
import WindSpeedComplication from "./complications/WindSpeed";
import RainComplication from "./complications/Rain";

import { useDataStore } from "@/stores/useDataStore";

export default function DataWeatherInfo() {
	const weather = useDataStore((state) => state.weatherData);

	return (
		<div className="flex justify-between gap-4">
			{weather ? (
				<>
					<TemperatureComplication value={Math.round(parseFloat(weather.trackTemp))} label="TRC" />
					<TemperatureComplication value={Math.round(parseFloat(weather.airTemp))} label="AIR" />
					<HumidityComplication value={parseFloat(weather.humidity)} />
					<RainComplication rain={weather.rainfall === "1"} />
					<WindSpeedComplication speed={parseFloat(weather.windSpeed)} directionDeg={parseInt(weather.windDirection)} />
				</>
			) : (
				<>
					<Loading />
					<Loading />
					<Loading />
					<Loading />
					<Loading />
				</>
			)}
		</div>
	);
}

function Loading() {
	return <div className="h-[55px] w-[55px] animate-pulse rounded-full bg-zinc-800" />;
}



---
File: /dash/src/hooks/useBuffer.ts
---

import { useRef } from "react";

const KEEP_BUFFER_SECS = 5;

type Frame<T> = {
	data: T;
	timestamp: number;
};

export const useBuffer = <T>() => {
	const bufferRef = useRef<Frame<T>[]>([]);

	const set = (data: T) => {
		bufferRef.current = [{ data, timestamp: Date.now() }];
	};

	const push = (update: T) => {
		bufferRef.current.push({ data: update, timestamp: Date.now() });
	};

	const pushTimed = (update: T, timestamp: number) => {
		if (!Number.isFinite(timestamp) || timestamp < 0) return;

		bufferRef.current.push({ data: update, timestamp });
	};

	const latest = (): T | null => {
		const frame = bufferRef.current[bufferRef.current.length - 1];
		return frame ? frame.data : null;
	};

	const delayed = (delayedTime: number): T | null => {
		const buffer = bufferRef.current;
		const length = buffer.length;

		// Handle empty buffer
		if (length === 0) return null;

		// Handle case where all data is newer than delayedTime
		if (buffer[0].timestamp > delayedTime) return null;

		// Handle case where all data is older than delayedTime
		if (buffer[length - 1].timestamp < delayedTime) return buffer[length - 1].data;

		// binary search for the closest frame before delayedTime
		let left = 0;
		let right = length - 1;

		while (left <= right) {
			const mid = Math.floor((left + right) / 2);

			if (buffer[mid].timestamp <= delayedTime && (mid === length - 1 || buffer[mid + 1].timestamp > delayedTime)) {
				return buffer[mid].data;
			}

			if (buffer[mid].timestamp <= delayedTime) {
				left = mid + 1;
			} else {
				right = mid - 1;
			}
		}

		return null;
	};

	const cleanup = (delayedTime: number) => {
		const buffer = bufferRef.current;
		const length = buffer.length;

		// Handle empty buffer
		if (length === 0) return;
		if (length === 1) return;

		// Calculate the threshold time
		const thresholdTime = delayedTime - KEEP_BUFFER_SECS * 1000;

		// Find the index of the first frame that is newer than the threshold time
		let index = 0;
		while (index < length && buffer[index].timestamp <= thresholdTime) {
			index++;
		}

		// Ensure at least one frame is kept
		if (index > 0 && index < length) {
			bufferRef.current = buffer.slice(index - 1);
		} else if (index >= length) {
			bufferRef.current = [buffer[length - 1]];
		}
	};

	const maxDelay = (): number => {
		return bufferRef.current.length > 0 ? Math.floor((Date.now() - bufferRef.current[0].timestamp) / 1000) : 0;
	};

	return {
		set,
		push,
		pushTimed,
		latest,
		delayed,
		cleanup,
		maxDelay,
	};
};



---
File: /dash/src/hooks/useDataEngine.ts
---

"use client";

import { useEffect, useRef, useState } from "react";

import type { CarData, CarsData, Position, Positions, State } from "@/types/state.type";
import type { MessageInitial, MessageUpdate } from "@/types/message.type";

import { inflate } from "@/lib/inflate";
import { utcToLocalMs } from "@/lib/utcToLocalMs";

import { useSettingsStore } from "@/stores/useSettingsStore";

import { useBuffer } from "@/hooks/useBuffer";
import { useStatefulBuffer } from "@/hooks/useStatefulBuffer";

const UPDATE_MS = 200;

type Props = {
	updateState: (state: State) => void;
	updatePosition: (pos: Positions) => void;
	updateCarData: (car: CarsData) => void;
};

export const useDataEngine = ({ updateState, updatePosition, updateCarData }: Props) => {
	const buffers = {
		extrapolatedClock: useStatefulBuffer(),
		topThree: useStatefulBuffer(),
		timingStats: useStatefulBuffer(),
		timingAppData: useStatefulBuffer(),
		weatherData: useStatefulBuffer(),
		trackStatus: useStatefulBuffer(),
		sessionStatus: useStatefulBuffer(),
		driverList: useStatefulBuffer(),
		raceControlMessages: useStatefulBuffer(),
		sessionInfo: useStatefulBuffer(),
		sessionData: useStatefulBuffer(),
		lapCount: useStatefulBuffer(),
		timingData: useStatefulBuffer(),
		teamRadio: useStatefulBuffer(),
		championshipPrediction: useStatefulBuffer(),
	};

	const carBuffer = useBuffer<CarsData>();
	const posBuffer = useBuffer<Positions>();

	const [maxDelay, setMaxDelay] = useState<number>(0);

	const delayRef = useRef<number>(0);

	useSettingsStore.subscribe(
		(state) => state.delay,
		(delay) => (delayRef.current = delay),
		{ fireImmediately: true },
	);

	const intervalRef = useRef<NodeJS.Timeout | null>(null);

	const handleInitial = ({ carDataZ, positionZ, ...initial }: MessageInitial) => {
		updateState(initial);

		Object.keys(buffers).forEach((key) => {
			const data = initial[key as keyof typeof initial];
			const buffer = buffers[key as keyof typeof buffers];
			if (data) buffer.set(data);
		});

		if (carDataZ) {
			const carData = inflate<CarData>(carDataZ);
			updateCarData(carData.Entries[0].Cars);

			for (const entry of carData.Entries) {
				carBuffer.pushTimed(entry.Cars, utcToLocalMs(entry.Utc));
			}
		}

		if (positionZ) {
			const position = inflate<Position>(positionZ);
			updatePosition(position.Position[0].Entries);

			for (const entry of position.Position) {
				posBuffer.pushTimed(entry.Entries, utcToLocalMs(entry.Timestamp));
			}
		}
	};

	const handleUpdate = ({ carDataZ, positionZ, ...update }: MessageUpdate) => {
		Object.keys(buffers).forEach((key) => {
			const data = update[key as keyof typeof update];
			const buffer = buffers[key as keyof typeof buffers];
			if (data) buffer.push(data);
		});

		if (carDataZ) {
			const carData = inflate<CarData>(carDataZ);
			for (const entry of carData.Entries) {
				carBuffer.pushTimed(entry.Cars, utcToLocalMs(entry.Utc));
			}
		}

		if (positionZ) {
			const position = inflate<Position>(positionZ);
			for (const entry of position.Position) {
				posBuffer.pushTimed(entry.Entries, utcToLocalMs(entry.Timestamp));
			}
		}
	};

	const handleCurrentState = () => {
		const delay = delayRef.current;

		if (delay === 0) {
			const newStateFrame: Record<string, State[keyof State]> = {};

			Object.keys(buffers).forEach((key) => {
				const buffer = buffers[key as keyof typeof buffers];
				const latest = buffer.latest() as State[keyof State];
				if (latest) newStateFrame[key] = latest;
			});

			updateState(newStateFrame);

			const carFrame = carBuffer.latest();
			if (carFrame) updateCarData(carFrame);

			const posFrame = posBuffer.latest();
			if (posFrame) updatePosition(posFrame);
		} else {
			const delayedTimestamp = Date.now() - delay * 1000;

			Object.keys(buffers).forEach((key) => {
				const buffer = buffers[key as keyof typeof buffers];
				const delayed = buffer.delayed(delayedTimestamp);

				if (delayed) updateState({ [key]: delayed });

				setTimeout(() => buffer.cleanup(delayedTimestamp), 0);
			});

			const carFrame = carBuffer.delayed(delayedTimestamp);
			if (carFrame) {
				updateCarData(carFrame);

				setTimeout(() => carBuffer.cleanup(delayedTimestamp), 0);
			}

			const posFrame = posBuffer.delayed(delayedTimestamp);
			if (posFrame) {
				updatePosition(posFrame);

				setTimeout(() => posBuffer.cleanup(delayedTimestamp), 0);
			}
		}

		const maxDelay = Math.min(
			...Object.values(buffers)
				.map((buffer) => buffer.maxDelay())
				.filter((delay) => delay > 0),
			carBuffer.maxDelay(),
			posBuffer.maxDelay(),
		);

		setMaxDelay(maxDelay);
	};

	useEffect(() => {
		intervalRef.current = setInterval(handleCurrentState, UPDATE_MS);
		return () => (intervalRef.current ? clearInterval(intervalRef.current) : void 0);
		// TODO investigate if this might have performance issues
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, []);

	return {
		handleUpdate,
		handleInitial,
		maxDelay,
	};
};



---
File: /dash/src/hooks/useDevMode.ts
---

export const useDevMode = () => {
	let active = false;

	if (typeof window != undefined) {
		active = !!localStorage.getItem("dev");
	}

	return { active };
};



---
File: /dash/src/hooks/useSocket.ts
---

import { useEffect, useState } from "react";

import type { MessageInitial, MessageUpdate } from "@/types/message.type";

import { env } from "@/env";

type Props = {
	handleInitial: (data: MessageInitial) => void;
	handleUpdate: (data: MessageUpdate) => void;
};

export const useSocket = ({ handleInitial, handleUpdate }: Props) => {
	const [connected, setConnected] = useState<boolean>(false);

	useEffect(() => {
		const sse = new EventSource(`${env.NEXT_PUBLIC_LIVE_URL}/api/sse`);

		sse.onerror = () => setConnected(false);
		sse.onopen = () => setConnected(true);

		sse.addEventListener("initial", (message) => {
			handleInitial(JSON.parse(message.data));
		});

		sse.addEventListener("update", (message) => {
			handleUpdate(JSON.parse(message.data));
		});

		return () => sse.close();
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, []);

	return { connected };
};



---
File: /dash/src/hooks/useStatefulBuffer.ts
---

import { useRef } from "react";

import { merge } from "@/lib/merge";

import { useBuffer } from "@/hooks/useBuffer";

import type { RecursivePartial } from "@/types/message.type";

export const useStatefulBuffer = <T>() => {
	const currentRef = useRef<T | null>(null);
	const buffer = useBuffer<T>();

	const set = (data: T) => {
		currentRef.current = data;
		buffer.set(data);
	};

	const push = (update: RecursivePartial<T>) => {
		currentRef.current = merge(currentRef.current ?? {}, update) as T;
		if (currentRef.current) buffer.push(currentRef.current);
	};

	return {
		set,
		push,
		latest: buffer.latest,
		delayed: buffer.delayed,
		cleanup: buffer.cleanup,
		maxDelay: buffer.maxDelay,
	};
};



---
File: /dash/src/hooks/useStores.ts
---

import type { CarsData, Positions, State } from "@/types/state.type";

import { useCarDataStore, useDataStore, usePositionStore } from "@/stores/useDataStore";

type Fns = {
	updateState: (state: State) => void;
	updatePosition: (pos: Positions) => void;
	updateCarData: (car: CarsData) => void;
};

export const useStores = (): Fns => {
	const dataStore = useDataStore();
	const positionStore = usePositionStore();
	const carDataStore = useCarDataStore();

	return {
		updateState: (v) => dataStore.set(v),
		updatePosition: (v) => positionStore.set(v),
		updateCarData: (v) => carDataStore.set(v),
	};
};



---
File: /dash/src/hooks/useWakeLock.ts
---

import { useEffect, useRef } from "react";

export const useWakeLock = () => {
	const wakeLock = useRef<null | WakeLockSentinel>(null);

	useEffect(() => {
		if (typeof window != undefined) {
			if (!window.isSecureContext) return;

			if (window.location.hostname === "localhost") return;

			if (!("wakeLock" in navigator)) return;

			navigator.wakeLock.request("screen").then((wl) => {
				wakeLock.current = wl;
			});
		}

		return () => {
			if (wakeLock.current) {
				wakeLock.current.release();
			}
		};
	}, []);
};



---
File: /dash/src/lib/calculatePosition.ts
---

import type { TimingData } from "@/types/state.type";

import { sortPos } from "@/lib/sorting";

export const calculatePosition = (seconds: number, driverNr: string, timingData: TimingData): number | null => {
	const driverTiming = timingData.lines[driverNr];

	if (!driverTiming) {
		return null;
	}

	const currentPos = parseInt(driverTiming.position);

	// get all drivers that are behind the current driver
	// sort them by their position
	const drivers = Object.values(timingData.lines)
		.filter((driver) => parseInt(driver.position) > currentPos)
		.sort(sortPos);

	// accumulate the time they are behind each other
	// until the accumulated time is greater than the given time
	let accGap = 0;
	let pos = currentPos;

	for (const driver of drivers) {
		const gap = parseFloat(driver.gapToLeader);
		accGap += gap;

		if (accGap > seconds) {
			break;
		}

		pos++;
	}

	return pos;
};



---
File: /dash/src/lib/circle.ts
---

export function polarToCartesian(centerX: number, centerY: number, radius: number, angleInDegrees: number) {
	const angleInRadians = ((angleInDegrees - 90) * Math.PI) / 180.0;
	return {
		x: centerX + radius * Math.cos(angleInRadians),
		y: centerY + radius * Math.sin(angleInRadians),
	};
}

export function describeArc(x: number, y: number, radius: number, startAngle: number, endAngle: number) {
	const start = polarToCartesian(x, y, radius, endAngle);
	const end = polarToCartesian(x, y, radius, startAngle);

	const largeArcFlag = endAngle - startAngle <= 180 ? "0" : "1";

	return ["M", start.x, start.y, "A", radius, radius, 0, largeArcFlag, 0, end.x, end.y].join(" ");
}

export function clamping(value: number, minOut: number, maxOut: number, maxIn: number): number {
	const percTemp = value / maxIn;
	return minOut * (1 - percTemp) + maxOut * percTemp;
}



---
File: /dash/src/lib/dateFormatter.ts
---

import { utc } from "moment";

export const formatMonth = (start: string, end: string): string => {
	const startM = utc(start).local();
	const endM = utc(end).local();

	const sameMonth = startM.format("MMMM") === endM.format("MMMM");
	return sameMonth ? startM.format("MMMM") : `${startM.format("MMM")} - ${endM.format("MMM")}`;
};

export const formatDayRange = (start: string, end: string): string => {
	return `${utc(start).local().format("D")}-${utc(end).local().format("D")}`;
};



---
File: /dash/src/lib/fetchMap.ts
---

import type { Map } from "@/types/map.type";

export const fetchMap = async (circuitKey: number): Promise<Map | null> => {
	try {
		const year = new Date().getFullYear();

		const mapRequest = await fetch(`https://api.multiviewer.app/api/v1/circuits/${circuitKey}/${year}`, {
			next: { revalidate: 60 * 60 * 2 },
		});

		if (!mapRequest.ok) {
			console.error("Failed to fetch map", mapRequest);
			return null;
		}

		return mapRequest.json();
	} catch (error) {
		console.error("Failed to fetch map", error);
		return null;
	}
};



---
File: /dash/src/lib/geocode.ts
---

import { buildParams } from "@/lib/params";

import type { Coords, Place } from "@/types/geocode.type";

export const fetchCoords = async (query: string): Promise<Coords | null> => {
	const params = buildParams({
		q: query,
		format: "jsonv2",
	});

	const url = `https://nominatim.openstreetmap.org/search${params}`;

	const response = await fetch(url);
	const data: Place[] = await response.json();

	if (response.ok && data.length > 0) {
		const sorted = data.sort((a, b) => b.importance - a.importance);

		const { lon, lat } = sorted[0];
		return { lon: parseFloat(lon), lat: parseFloat(lat) };
	}

	return null;
};



---
File: /dash/src/lib/getTrackStatusMessage.ts
---

type StatusMessage = {
	message: string;
	color: string;
	trackColor: string;
	bySector?: boolean;
	pulse?: number;
	hex: string;
};

type MessageMap = {
	[key: string]: StatusMessage;
};

export const getTrackStatusMessage = (statusCode: number | undefined): StatusMessage | null => {
	const messageMap: MessageMap = {
		1: { message: "Track Clear", color: "bg-emerald-500", trackColor: "stroke-white", hex: "#34b981" },
		2: {
			message: "Yellow Flag",
			color: "bg-amber-400",
			trackColor: "stroke-amber-400",
			bySector: true,
			hex: "#fbbf24",
		},
		3: { message: "Flag", color: "bg-amber-400", trackColor: "stroke-amber-400", bySector: true, hex: "#fbbf24" },
		4: { message: "Safety Car", color: "bg-amber-400", trackColor: "stroke-amber-400", hex: "#fbbf24" },
		5: { message: "Red Flag", color: "bg-red-500", trackColor: "stroke-red-500", hex: "#ef4444" },
		6: { message: "VSC Deployed", color: "bg-amber-400", trackColor: "stroke-amber-400", hex: "#fbbf24" },
		7: { message: "VSC Ending", color: "bg-amber-400", trackColor: "stroke-amber-400", hex: "#fbbf24" },
	};

	return statusCode ? (messageMap[statusCode] ?? messageMap[0]) : null;
};



---
File: /dash/src/lib/getWindDirection.ts
---

export const getWindDirection = (deg: number) => {
	const directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];
	return directions[Math.floor(deg / 45) % 8];
};



---
File: /dash/src/lib/groupSessionByDay.ts
---

import { utc } from "moment";

import type { Session } from "@/types/schedule.type";

type SessionDayGroup = { date: string; sessions: Session[] };

export const groupSessionByDay = (sessions: Session[]): SessionDayGroup[] => {
	return sessions.reduce((groups: SessionDayGroup[], next) => {
		const nextDate = utc(next.start).format("ddddd");
		const groupIndex = groups.findIndex((group) => utc(group.date).format("ddddd") === nextDate);

		if (groupIndex < 0) {
			// not found
			groups = [...groups, { date: next.start, sessions: [next] }];
		} else {
			// found
			groups[groupIndex] = { ...groups[groupIndex], sessions: [...groups[groupIndex].sessions, next] };
		}

		return groups;
	}, []);
};



---
File: /dash/src/lib/inflate.ts
---

import { inflateRaw } from "pako";

export const inflate = <T>(data: string): T => {
	const binaryString = atob(data);

	const len = binaryString.length;

	const bytes = new Uint8Array(len);

	for (let i = 0; i < len; i++) {
		bytes[i] = binaryString.charCodeAt(i);
	}

	const inflatedData = inflateRaw(bytes, { to: "string" });

	return JSON.parse(inflatedData);
};



---
File: /dash/src/lib/map.ts
---

import type { Map, TrackPosition } from "@/types/map.type";
import type { Message } from "@/types/state.type";

import { sortUtc } from "@/lib/sorting";

export const rad = (deg: number) => deg * (Math.PI / 180);

export const rotate = (x: number, y: number, a: number, px: number, py: number) => {
	const c = Math.cos(rad(a));
	const s = Math.sin(rad(a));

	x -= px;
	y -= py;

	const newX = x * c - y * s;
	const newY = y * c + x * s;

	return { y: newX + px, x: newY + py };
};

export const calculateDistance = (x1: number, y1: number, x2: number, y2: number) => {
	return Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
};

export const findMinDistance = (point: TrackPosition, points: TrackPosition[]) => {
	let min = Infinity;
	let minIndex = -1;
	for (let i = 0; i < points.length; i++) {
		const distance = calculateDistance(point.x, point.y, points[i].x, points[i].y);
		if (distance < min) {
			min = distance;
			minIndex = i;
		}
	}
	return minIndex;
};

export type MapSector = {
	number: number;
	start: TrackPosition;
	end: TrackPosition;
	points: TrackPosition[];
};

export const createSectors = (map: Map): MapSector[] => {
	const sectors: MapSector[] = [];
	const points: TrackPosition[] = map.x.map((x, index) => ({ x, y: map.y[index] }));

	for (let i = 0; i < map.marshalSectors.length; i++) {
		sectors.push({
			number: i + 1,
			start: map.marshalSectors[i].trackPosition,
			end: map.marshalSectors[i + 1] ? map.marshalSectors[i + 1].trackPosition : map.marshalSectors[0].trackPosition,
			points: [],
		});
	}

	const dividers: number[] = sectors.map((s) => findMinDistance(s.start, points));
	for (let i = 0; i < dividers.length; i++) {
		const start = dividers[i];
		const end = dividers[i + 1] ? dividers[i + 1] : dividers[0];
		if (start < end) {
			sectors[i].points = points.slice(start, end + 1);
		} else {
			sectors[i].points = points.slice(start).concat(points.slice(0, end + 1));
		}
	}

	return sectors;
};

export const findYellowSectors = (messages: Message[] | undefined): Set<number> => {
	const msgs = messages?.sort(sortUtc).filter((msg) => {
		return msg.flag === "YELLOW" || msg.flag === "DOUBLE YELLOW" || msg.flag === "CLEAR";
	});

	if (!msgs) {
		return new Set();
	}

	const done: Set<number> = new Set();
	const sectors: Set<number> = new Set();
	for (let i = 0; i < msgs.length; i++) {
		const msg = msgs[i];
		if (msg.scope === "Track" && msg.flag !== "CLEAR") {
			// Spam with sectors so all sectors are yellow no matter what
			// number of sectors there really are
			for (let j = 0; j < 100; j++) {
				sectors.add(j);
			}
			return sectors;
		}
		if (msg.scope === "Sector") {
			if (!msg.sector || done.has(msg.sector)) {
				continue;
			}
			if (msg.flag === "CLEAR") {
				done.add(msg.sector);
			} else {
				sectors.add(msg.sector);
			}
		}
	}
	return sectors;
};

type RenderedSector = {
	number: number;
	d: string;
	color: string;
	strokeWidth: number;
	pulse?: number;
};

export const prioritizeColoredSectors = (a: RenderedSector, b: RenderedSector) => {
	if (a.color === "stroke-white" && b.color !== "stroke-white") {
		return -1;
	}
	if (a.color !== "stroke-white" && b.color === "stroke-white") {
		return 1;
	}
	return a.number - b.number;
};

export const getSectorColor = (
	sector: MapSector,
	bySector: boolean | undefined,
	trackColor: string | undefined = "stroke-white",
	yellowSectors: Set<number>,
) => (bySector ? (yellowSectors.has(sector.number) ? trackColor : "stroke-white") : trackColor);



---
File: /dash/src/lib/merge.ts
---

const isObject = (obj: unknown): obj is Record<string, unknown> => {
	return obj !== null && typeof obj === "object" && !Array.isArray(obj);
};

export const merge = (base: unknown, update: unknown): unknown => {
	if (isObject(base) && isObject(update)) {
		const result = { ...base };

		for (const [key, value] of Object.entries(update)) {
			result[key] = merge(base[key] ?? null, value);
		}

		return result;
	}

	if (Array.isArray(base) && Array.isArray(update)) {
		return base.concat(update);
	}

	if (Array.isArray(base) && isObject(update)) {
		const result = [...base];

		for (const [key, value] of Object.entries(update)) {
			const index = parseInt(key);
			result.splice(index, 1, merge(result[index], value));
		}

		return [...result];
	}

	return update;
};



---
File: /dash/src/lib/params.ts
---

type Params = Record<string, string[] | string | number | boolean | undefined | null>;

export const buildParams = (params?: Params): string => {
	if (params) {
		Object.keys(params).forEach((key) => (params[key] === undefined ? delete params[key] : {}));
		return `?${new URLSearchParams(params as Record<string, string>)}`;
	}
	return "";
};



---
File: /dash/src/lib/rainviewer.ts
---

import type { Rainviewer } from "@/types/rainviewer.type";

const rainviewerUrl = "https://api.rainviewer.com/public/weather-maps.json";

export const getRainviewer = async (): Promise<Rainviewer | null> => {
	try {
		const response = await fetch(rainviewerUrl);

		if (!response.ok) {
			return null;
		}

		return response.json();
	} catch {
		return null;
	}
};



---
File: /dash/src/lib/sorting.ts
---

import { utc } from "moment";

type PosObject = { position: string };
export const sortPos = (a: PosObject, b: PosObject) => {
	return parseInt(a.position) - parseInt(b.position);
};

type PosObjectQuali = {
	sectors: {
		segments: { status: number }[];
	}[];
};
export const sortQuali = (a: PosObjectQuali, b: PosObjectQuali) => {
	const aPassed = a.sectors.flatMap((sector) => sector.segments).filter((s) => s.status > 0);
	const bPassed = b.sectors.flatMap((sector) => sector.segments).filter((s) => s.status > 0);

	return bPassed.length - aPassed.length;
};

type UtcObject = { utc: string };
export const sortUtc = (a: UtcObject, b: UtcObject) => {
	return utc(b.utc).diff(utc(a.utc));
};



---
File: /dash/src/lib/toTrackTime.ts
---

/**
 * Welcome to the most scuffed time/date conversion.
 *
 * We assume the offset has this patter: HH:mm:ss
 *
 * We also assume that the utc date provided does not have a Z to indicate utc, because why not F1
 *
 * We extract the h m s from our string and parse to ints/numbers
 * We individually update our original date with hours, minutes and seconds.
 * *
 * @param utc
 * @param offset
 * @returns ISO-8601 string
 */
export const toTrackTime = (utc: string, offset: string): string => {
	const date = new Date(utc);

	const [hours, minutes, seconds]: (number | undefined)[] = offset.split(":").map((unit) => parseInt(unit));

	if (!hours || !minutes || !seconds) return date.toISOString();

	date.setUTCHours(date.getUTCHours() + hours);
	date.setUTCMinutes(date.getUTCMinutes() + minutes);
	date.setUTCSeconds(date.getUTCSeconds() + seconds);

	return date.toISOString();
};



---
File: /dash/src/lib/utcToLocalMs.ts
---

import { utc } from "moment";

export const utcToLocalMs = (utcDateString: string): number => {
	return utc(utcDateString).local().valueOf();
};



---
File: /dash/src/stores/useDataStore.ts
---

import { create } from "zustand";

import type {
	CarsData,
	ChampionshipPrediction,
	DriverList,
	ExtrapolatedClock,
	Heartbeat,
	LapCount,
	Positions,
	RaceControlMessages,
	SessionData,
	SessionInfo,
	SessionStatus,
	State,
	TeamRadio,
	TimingAppData,
	TimingData,
	TimingStats,
	TopThree,
	TrackStatus,
	WeatherData,
} from "@/types/state.type";

// main store

type DataStore = {
	heartbeat: Heartbeat | null;
	extrapolatedClock: ExtrapolatedClock | null;
	topThree: TopThree | null;
	timingStats: TimingStats | null;
	timingAppData: TimingAppData | null;
	weatherData: WeatherData | null;
	trackStatus: TrackStatus | null;
	sessionStatus: SessionStatus | null;
	driverList: DriverList | null;
	raceControlMessages: RaceControlMessages | null;
	sessionInfo: SessionInfo | null;
	sessionData: SessionData | null;
	lapCount: LapCount | null;
	timingData: TimingData | null;
	teamRadio: TeamRadio | null;
	championshipPrediction: ChampionshipPrediction | null;

	set: (state: State) => void;
	update: (state: Partial<State>) => void;
};

export const useDataStore = create<DataStore>((set) => ({
	heartbeat: null,
	extrapolatedClock: null,
	topThree: null,
	timingStats: null,
	timingAppData: null,
	weatherData: null,
	trackStatus: null,
	sessionStatus: null,
	driverList: null,
	raceControlMessages: null,
	sessionInfo: null,
	sessionData: null,
	lapCount: null,
	timingData: null,
	teamRadio: null,
	championshipPrediction: null,

	set: (state: State) => {
		set(state);
	},
	update: (state: Partial<State>) => {
		set(state);
	},
}));

// car store

type CarDataStore = {
	carsData: CarsData | null;
	set: (carsData: CarsData) => void;
};

export const useCarDataStore = create<CarDataStore>((set) => ({
	carsData: null,
	set: (carsData: CarsData) => set({ carsData }),
}));

// position store

type PositionStore = {
	positions: Positions | null;
	set: (positions: Positions) => void;
};

export const usePositionStore = create<PositionStore>((set) => ({
	positions: null,
	set: (positions: Positions) => set({ positions }),
}));



---
File: /dash/src/stores/useSettingsStore.ts
---

import { persist, createJSONStorage, subscribeWithSelector } from "zustand/middleware";
import { create } from "zustand";

type SpeedUnit = "metric" | "imperial";

type SettingsStore = {
	delay: number;
	setDelay: (delay: number) => void;

	speedUnit: SpeedUnit;
	setSpeedUnit: (speedUnit: SpeedUnit) => void;

	showCornerNumbers: boolean;
	setShowCornerNumbers: (showCornerNumbers: boolean) => void;

	carMetrics: boolean;
	setCarMetrics: (carMetrics: boolean) => void;

	tableHeaders: boolean;
	setTableHeaders: (tableHeaders: boolean) => void;

	showBestSectors: boolean;
	setShowBestSectors: (showBestSectors: boolean) => void;

	showMiniSectors: boolean;
	setShowMiniSectors: (showMiniSectors: boolean) => void;

	oledMode: boolean;
	setOledMode: (oledMode: boolean) => void;

	useSafetyCarColors: boolean;
	setUseSafetyCarColors: (useSafetyCarColors: boolean) => void;

	favoriteDrivers: string[];
	setFavoriteDrivers: (favoriteDrivers: string[]) => void;
	removeFavoriteDriver: (driver: string) => void;

	raceControlChime: boolean;
	setRaceControlChime: (raceControlChime: boolean) => void;

	raceControlChimeVolume: number;
	setRaceControlChimeVolume: (raceControlChimeVolume: number) => void;

	delayIsPaused: boolean;
	setDelayIsPaused: (delayIsPaused: boolean) => void;
};

export const useSettingsStore = create<SettingsStore>()(
	subscribeWithSelector(
		persist(
			(set) => ({
				delay: 0,
				setDelay: (delay: number) => set({ delay }),

				speedUnit: "metric",
				setSpeedUnit: (speedUnit: SpeedUnit) => set({ speedUnit }),

				showCornerNumbers: false,
				setShowCornerNumbers: (showCornerNumbers: boolean) => set({ showCornerNumbers }),

				carMetrics: false,
				setCarMetrics: (carMetrics: boolean) => set({ carMetrics }),

				tableHeaders: false,
				setTableHeaders: (tableHeaders: boolean) => set({ tableHeaders }),

				showBestSectors: true,
				setShowBestSectors: (showBestSectors: boolean) => set({ showBestSectors }),

				showMiniSectors: true,
				setShowMiniSectors: (showMiniSectors: boolean) => set({ showMiniSectors }),

				oledMode: false,
				setOledMode: (oledMode: boolean) => set({ oledMode }),

				useSafetyCarColors: true,
				setUseSafetyCarColors: (useSafetyCarColors: boolean) => set({ useSafetyCarColors }),

				favoriteDrivers: [],
				setFavoriteDrivers: (favoriteDrivers: string[]) => set({ favoriteDrivers }),
				removeFavoriteDriver: (driver: string) =>
					set((state) => ({ favoriteDrivers: state.favoriteDrivers.filter((d) => d !== driver) })),

				raceControlChime: false,
				setRaceControlChime: (raceControlChime: boolean) => set({ raceControlChime }),

				raceControlChimeVolume: 50,
				setRaceControlChimeVolume: (raceControlChimeVolume: number) => set({ raceControlChimeVolume }),

				delayIsPaused: true,
				setDelayIsPaused: (delayIsPaused: boolean) => set({ delayIsPaused }),
			}),
			{
				name: "settings-storage",
				storage: createJSONStorage(() => localStorage),
				onRehydrateStorage: (state) => {
					return () => state.setDelayIsPaused(false);
				},
			},
		),
	),
);



---
File: /dash/src/stores/useSidebarStore.ts
---

import { create } from "zustand";

type SidebarStore = {
	pinned: boolean;
	opened: boolean;

	close: () => void;
	open: () => void;

	pin: () => void;
	unpin: () => void;
};

export const useSidebarStore = create<SidebarStore>()((set) => ({
	pinned: true,
	opened: false,

	close: () => {
		set({ opened: false });
	},
	open: () => {
		set({ opened: true });
	},

	pin: () => {
		set({ pinned: true, opened: false });
	},
	unpin: () => {
		set({ pinned: false, opened: false });
	},
}));



---
File: /dash/src/styles/globals.css
---

@import "tailwindcss";

@theme inline {
	--font-sans: var(--font-geist-sans);
	--font-mono: var(--font-geist-mono);
}

@theme {
	--breakpoint-3xl: 1800px;

	--color-popover: rgba(37, 37, 37, 0.9);
	--color-pane: oklch(18% 0.005 285.82);
}

@layer utilities {
	.no-scrollbar::-webkit-scrollbar {
		display: none;
	}

	.no-scrollbar {
		-ms-overflow-style: none;
		scrollbar-width: none;
	}
}

.pulse-loading-spinner {
	animation: pulse-loading 1.2s cubic-bezier(0.52, 0.6, 0.25, 0.99) infinite;
}

@keyframes pulse-loading {
	0% {
		r: 0;
		opacity: 1;
	}
	100% {
		r: 11px;
		opacity: 0;
	}
}



---
File: /dash/src/types/geocode.type.ts
---

export type Coords = {
	lon: number;
	lat: number;
};

export type Place = {
	place_id: number;
	licence: string;
	osm_type: string;
	osm_id: number;
	lat: string;
	lon: string;
	category: string;
	type: string;
	place_rank: number;
	importance: number;
	addresstype: string;
	name: string;
	display_name: string;
	boundingbox: string[];
};



---
File: /dash/src/types/map.type.ts
---

export type Map = {
	corners: Corner[];
	marshalLights: Corner[];
	marshalSectors: Corner[];
	candidateLap: CandidateLap;
	circuitKey: number;
	circuitName: string;
	countryIocCode: string;
	countryKey: number;
	countryName: string;
	location: string;
	meetingKey: string;
	meetingName: string;
	meetingOfficialName: string;
	raceDate: string;
	rotation: number;
	round: number;
	trackPositionTime: number[];
	x: number[];
	y: number[];
	year: number;
};

export type CandidateLap = {
	driverNumber: string;
	lapNumber: number;
	lapStartDate: string;
	lapStartSessionTime: number;
	lapTime: number;
	session: string;
	sessionStartTime: number;
};

export type Corner = {
	angle: number;
	length: number;
	number: number;
	trackPosition: TrackPosition;
};

export type TrackPosition = {
	x: number;
	y: number;
};



---
File: /dash/src/types/message.type.ts
---

import type { State } from "./state.type";

export type RecursivePartial<T> = {
	[P in keyof T]?: T[P] extends (infer U)[]
		? RecursivePartial<U>[]
		: T[P] extends object | undefined
			? RecursivePartial<T[P]>
			: T[P];
};

type FullState = State & {
	carDataZ?: string;
	positionZ?: string;
};

export type MessageUpdate = RecursivePartial<FullState>;

export type MessageInitial = FullState;



---
File: /dash/src/types/rainviewer.type.ts
---

export type Rainviewer = {
	version: string;
	generated: number;
	host: string;
	radar: Radar;
	satellite: Satellite;
};

export type Radar = {
	past: MapItem[];
	nowcast: MapItem[];
};

export type MapItem = {
	time: number;
	path: string;
};

export type Satellite = {
	infrared: MapItem[];
};



---
File: /dash/src/types/schedule.type.ts
---

export type Round = {
	name: string;
	countryName: string;
	countryKey: null;
	start: string;
	end: string;
	sessions: Session[];
	over: boolean;
};

export type Session = {
	kind: string;
	start: string;
	end: string;
};



---
File: /dash/src/types/state.type.ts
---

export type State = {
	heartbeat?: Heartbeat;
	extrapolatedClock?: ExtrapolatedClock;
	topThree?: TopThree;
	timingStats?: TimingStats;
	timingAppData?: TimingAppData;
	weatherData?: WeatherData;
	trackStatus?: TrackStatus;
	sessionStatus?: SessionStatus;
	driverList?: DriverList;
	raceControlMessages?: RaceControlMessages;
	sessionInfo?: SessionInfo;
	sessionData?: SessionData;
	lapCount?: LapCount;
	timingData?: TimingData;
	teamRadio?: TeamRadio;
	championshipPrediction?: ChampionshipPrediction;
};

export type Heartbeat = {
	utc: string;
};

export type ExtrapolatedClock = {
	utc: string;
	remaining: string;
	extrapolating: boolean;
};

export type TopThree = {
	withheld: boolean;
	lines: TopThreeDriver[];
};

export type TimingStats = {
	withheld: boolean;
	lines: {
		[key: string]: TimingStatsDriver;
	};
	sessionType: string;
	_kf: boolean;
};

export type TimingAppData = {
	lines: {
		[key: string]: TimingAppDataDriver;
	};
};

export type TimingAppDataDriver = {
	racingNumber: string;
	stints: Stint[];
	line: number;
	gridPos: string;
};

export type Stint = {
	totalLaps?: number;
	compound?: "SOFT" | "MEDIUM" | "HARD" | "INTERMEDIATE" | "WET";
	new?: string; // TRUE | FALSE
};

export type WeatherData = {
	airTemp: string;
	humidity: string;
	pressure: string;
	rainfall: string;
	trackTemp: string;
	windDirection: string;
	windSpeed: string;
};

export type TrackStatus = {
	status: string;
	message: string;
};

export type SessionStatus = {
	status: "Started" | "Finished" | "Finalised" | "Ends";
};

export type DriverList = {
	[key: string]: Driver;
};

export type Driver = {
	racingNumber: string;
	broadcastName: string;
	fullName: string;
	tla: string;
	line: number;
	teamName: string;
	teamColour: string;
	firstName: string;
	lastName: string;
	reference: string;
	headshotUrl: string;
	countryCode: string;
};

export type RaceControlMessages = {
	messages: Message[];
};

export type Message = {
	utc: string;
	lap: number;
	message: string;
	category: "Other" | "Sector" | "Flag" | "Drs" | "SafetyCar" | string;
	flag?: "BLACK AND WHITE" | "BLUE" | "CLEAR" | "YELLOW" | "GREEN" | "DOUBLE YELLOW" | "RED" | "CHEQUERED";
	scope?: "Driver" | "Track" | "Sector";
	sector?: number;
	status?: "ENABLED" | "DISABLED";
};

export type SessionInfo = {
	meeting: Meeting;
	archiveStatus: ArchiveStatus;
	key: number;
	type: string;
	name: string;
	startDate: string;
	endDate: string;
	gmtOffset: string;
	path: string;
	number?: number;
};

export type ArchiveStatus = {
	status: string;
};

export type Meeting = {
	key: number;
	name: string;
	officialName: string;
	location: string;
	country: Country;
	circuit: Circuit;
};

export type Circuit = {
	key: number;
	shortName: string;
};

export type Country = {
	key: number;
	code: string;
	name: string;
};

export type SessionData = {
	series: Series[];
	statusSeries: StatusSeries[];
};

export type StatusSeries = {
	utc: string;
	trackStatus?: string;
	sesionStatus?: "Started" | "Finished" | "Finalised" | "Ends";
};

export type Series = {
	utc: string;
	lap: number;
};

export type LapCount = {
	currentLap: number;
	totalLaps: number;
};

export type TimingData = {
	noEntries?: number[];
	sessionPart?: number;
	cutOffTime?: string;
	cutOffPercentage?: string;

	lines: {
		[key: string]: TimingDataDriver;
	};
	withheld: boolean;
};

export type TimingDataDriver = {
	stats?: { timeDiffToFastest: string; timeDifftoPositionAhead: string }[];
	timeDiffToFastest?: string;
	timeDiffToPositionAhead?: string;
	gapToLeader: string;
	intervalToPositionAhead?: {
		value: string;
		catching: boolean;
	};
	line: number;
	position: string;
	showPosition: boolean;
	racingNumber: string;
	retired: boolean;
	inPit: boolean;
	pitOut: boolean;
	stopped: boolean;
	status: number;
	sectors: Sector[];
	speeds: Speeds;
	bestLapTime: PersonalBestLapTime;
	lastLapTime: I1;
	numberOfLaps: number; // TODO check
	knockedOut?: boolean;
	cutoff?: boolean;
};

export type Sector = {
	stopped: boolean;
	value: string;
	previousValue?: string;
	status: number;
	overallFastest: boolean;
	personalFastest: boolean;
	segments: {
		status: number;
	}[];
};

export type Speeds = {
	i1: I1;
	i2: I1;
	fl: I1;
	st: I1;
};

export type I1 = {
	value: string;
	status: number;
	overallFastest: boolean;
	personalFastest: boolean;
};

export type TimingStatsDriver = {
	line: number;
	racingNumber: string;
	personalBestLapTime: PersonalBestLapTime;
	bestSectors: PersonalBestLapTime[];
	bestSpeeds: {
		i1: PersonalBestLapTime;
		i2: PersonalBestLapTime;
		fl: PersonalBestLapTime;
		st: PersonalBestLapTime;
	};
};

export type PersonalBestLapTime = {
	value: string;
	position: number;
};

export type TopThreeDriver = {
	position: string;
	showPosition: boolean;
	racingNumber: string;
	tla: string;
	broadcastName: string;
	fullName: string;
	team: string;
	teamColour: string;
	lapTime: string;
	lapState: number;
	diffToAhead: string;
	diffToLeader: string;
	overallFastest: boolean;
	personalFastest: boolean;
};

export type TeamRadio = {
	captures: RadioCapture[];
};

export type RadioCapture = {
	utc: string;
	racingNumber: string;
	path: string;
};

export type ChampionshipPrediction = {
	drivers: {
		[key: string]: ChampionshipDriver;
	};
	teams: {
		[key: string]: ChampionshipTeam;
	};
};

export type ChampionshipDriver = {
	racingNumber: string;
	currentPosition: number;
	predictedPosition: number;
	currentPoints: number;
	predictedPoints: number;
};

export type ChampionshipTeam = {
	teamName: string;
	currentPosition: number;
	predictedPosition: number;
	currentPoints: number;
	predictedPoints: number;
};

export type Position = {
	Position: PositionItem[];
};

export type PositionItem = {
	Timestamp: string;
	Entries: Positions;
};

export type Positions = {
	// this is what we have at state
	[key: string]: PositionCar;
};

export type PositionCar = {
	Status: string;
	X: number;
	Y: number;
	Z: number;
};

export type CarData = {
	Entries: Entry[];
};

export type Entry = {
	Utc: string;
	Cars: CarsData;
};

export type CarsData = {
	// this is what we have at state
	[key: string]: {
		Channels: CarDataChannels;
	};
};

export type CarDataChannels = {
	/** 0 - RPM */
	"0": number;
	/** 2 - Speed number km/h */
	"2": number;
	/** 3 - gear number */
	"3": number;
	/** 4 - Throttle int 0-100 */
	"4": number;
	/** 5 - Brake number boolean */
	"5": number;
	/** 45 - DRS */
	"45": number;
};



---
File: /dash/src/env-script.tsx
---

import { connection } from "next/server";
import Script from "next/script";

import { PUBLIC_ENV_KEY } from "@/env";

// only list env vars that can be exposed to the client

export const getPublicEnv = () => ({
	NEXT_PUBLIC_LIVE_URL: process.env.NEXT_PUBLIC_LIVE_URL,
	NEXT_PUBLIC_MAP_KEY: process.env.NEXT_PUBLIC_MAP_KEY,
});

export default async function EnvScript() {
	await connection();

	const env = getPublicEnv();

	const innerHTML = {
		__html: `window['${PUBLIC_ENV_KEY}'] = ${JSON.stringify(env)}`,
	};

	return <Script id="public-env" strategy={"beforeInteractive"} dangerouslySetInnerHTML={innerHTML} />;
}



---
File: /dash/src/env.ts
---

import { z } from "zod";

const server = z.object({
	NODE_ENV: z.enum(["development", "test", "production"]),

	API_URL: z.string().min(1).includes("http"),

	TRACKING_ID: z.string().optional(),
	TRACKING_URL: z.string().includes("http").optional(),

	DISABLE_IFRAME: z.string().optional(),
});

const client = z.object({
	NEXT_PUBLIC_LIVE_URL: z.string().min(1).includes("http"),
});

const processEnv = {
	NODE_ENV: process.env.NODE_ENV,

	API_URL: process.env.API_URL,

	TRACKING_ID: process.env.TRACKING_ID,
	TRACKING_URL: process.env.TRACKING_URL,

	DISABLE_IFRAME: process.env.DISABLE_IFRAME,

	NEXT_PUBLIC_LIVE_URL: process.env.NEXT_PUBLIC_LIVE_URL,
};

// Don't touch the part below
// This is used to validate envs and dynamically set the environment variables client-side
// --------------------------

export const PUBLIC_ENV_KEY = "__ENV";

const fullSchema = server.merge(client);
type Env = z.input<typeof fullSchema>;

type SPR = z.SafeParseReturnType<Env, Env>;

declare global {
	interface Window {
		[PUBLIC_ENV_KEY]: Env;
	}
}

let env = process.env as unknown as Env;

if (process.env.SKIP_ENV_VALIDATION !== "1") {
	const isServer = typeof window === "undefined";

	const hasEnv = !isServer && window[PUBLIC_ENV_KEY] !== undefined;

	const syntheticEnv = !hasEnv ? processEnv : window[PUBLIC_ENV_KEY];

	const parsedEnv = isServer ? (fullSchema.safeParse(syntheticEnv) as SPR) : (client.safeParse(syntheticEnv) as SPR);

	if (!parsedEnv.success) {
		const error = parsedEnv.error.flatten().fieldErrors;
		console.error("❌ Invalid environment variables:", error);
		throw new Error("Invalid environment variables");
	}

	env = new Proxy(parsedEnv.data, {
		get(target, prop) {
			if (typeof prop !== "string") return undefined;

			const isPublic = prop.startsWith("NEXT_PUBLIC_");

			if (!isServer && !isPublic)
				throw new Error(
					process.env.NODE_ENV === "production"
						? "❌ Attempted to access a server-side environment variable on the client"
						: `❌ Attempted to access server-side environment variable '${prop}' on the client`,
				);

			return target[prop as keyof typeof target];
		},
	});
}

export { env };



---
File: /dash/src/metadata.ts
---

import type { Metadata } from "next";

const title = "f1-dash | Formula 1 live timing";
const description =
	"Experience live telemetry and timing data from Formula 1 races. Get insights into leaderboards, tire choices, gaps, lap times, sector times, team radios, and more.";

const url = "https://f1-dash.com";

export const metadata: Metadata = {
	generator: "Next.js",

	applicationName: title,

	title,
	description,

	openGraph: {
		title,
		description,
		url,
		type: "website",
		siteName: "F1 Realtime Dashboard",
		images: [
			{
				alt: "Realtime Formula 1 Dashboard",
				url: `${url}/og-image.png`,
				width: 1200,
				height: 630,
			},
		],
	},

	twitter: {
		site: "@Slowlydev",
		title,
		description,
		creator: "@Slowlydev",
		card: "summary_large_image",
		images: [
			{
				url: `${url}/twitter-image.png`,
				alt: "Realtime Formula 1 Dashboard",
				width: 1200,
				height: 630,
			},
		],
	},

	category: "Sports & Recreation",

	referrer: "strict-origin-when-cross-origin",

	keywords: ["Formula 1", "f1 dashboard", "realtime telemetry", "f1 timing", "live updates"],

	creator: "Slowlydev",
	publisher: "Slowlydev",
	authors: [{ name: "Slowlydev", url: "https://slowly.dev" }],

	appleWebApp: {
		capable: true,
		title: "f1-dash",
		statusBarStyle: "black-translucent",
	},

	formatDetection: {
		email: false,
		address: false,
		telephone: false,
	},

	metadataBase: new URL(url),

	alternates: {
		canonical: url,
	},

	verification: {
		google: "hKv0h7XtWgQ-pVNVKpwwb2wcCC2f0tBQ1X1IcDX50hg",
	},

	manifest: "/manifest.json",
};



---
File: /dash/src/viewport.ts
---

import type { Viewport } from "next";

export const viewport: Viewport = {
	colorScheme: "dark",
	themeColor: "#09090b",
	initialScale: 1,
	maximumScale: 10,
	minimumScale: 0.1,
	userScalable: true,
};



---
File: /dash/next.config.ts
---

import type { NextConfig } from "next";

import pack from "./package.json" with { type: "json" };

import "@/env";

const output = process.env.NEXT_STANDALONE === "1" ? "standalone" : undefined;
const compress = process.env.NEXT_NO_COMPRESS === "1";

// const frameDisableHeaders = [
// 	{
// 		source: "/(.*)",
// 		headers: [
// 			{
// 				type: "header",
// 				key: "X-Frame-Options",
// 				value: "SAMEORIGIN",
// 			},
// 			{
// 				type: "header",
// 				key: "Content-Security-Policy",
// 				value: "frame-ancestors 'self';",
// 			},
// 		],
// 	},
// ];

const config: NextConfig = {
	output,
	compress,
	env: {
		version: pack.version,
	},
	// headers: async () => frameDisableHeaders,
};

export default config;

