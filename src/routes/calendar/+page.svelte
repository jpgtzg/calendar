<script lang="ts">
	import { onMount } from 'svelte';
	import { browser } from '$app/environment';
	import { goto } from '$app/navigation';
	import { ScheduleXCalendar } from '@schedule-x/svelte';
	import { createCalendar, createViewDay, createViewWeek } from '@schedule-x/calendar';
	import { getLocalTimeZone, today } from '@internationalized/date';
	import { Calendar } from '$lib/components/ui/calendar/index.js';
	import { createCalendarControlsPlugin } from '@schedule-x/calendar-controls';
	import { createIcalendarPlugin } from '@schedule-x/ical';
	import '@schedule-x/theme-default/dist/index.css';
	import 'temporal-polyfill/global';

	let selectedDate = $state(today(getLocalTimeZone()));
	const calendarControls = createCalendarControlsPlugin();
	let calendarApp = $state<ReturnType<typeof createCalendar> | null>(null);
	let icalendarPlugin = $state<ReturnType<typeof createIcalendarPlugin> | null>(null);
	let inactivityTimer: ReturnType<typeof setTimeout> | null = null;

	const INACTIVITY_TIMEOUT = 30000; // 30 seconds of inactivity

	onMount(async () => {
		if (browser) {
			// Fetch iCalendar data from server API route (bypasses CORS)
			let icalendarData = '';
			try {
				const response = await fetch(`/api/ical`);
				const result = await response.json();
				if (response.ok) {
					icalendarData = result.data || '';
					console.log('Successfully fetched iCalendar data, length:', icalendarData.length);
				} else {
					console.error('Failed to fetch iCalendar:', result.error || response.statusText);
					console.error('Response status:', response.status);
				}
			} catch (error) {
				console.error('Failed to fetch iCalendar:', error);
			}

			// Create iCalendar plugin if we have data
			if (icalendarData) {
				icalendarPlugin = createIcalendarPlugin({ data: icalendarData });
			}

			// Build plugins array
			const plugins = icalendarPlugin ? [calendarControls, icalendarPlugin] : [calendarControls];

			calendarApp = createCalendar(
				{
					timezone: 'America/Mexico_City',
					dayBoundaries: {
						start: '06:00',
						end: '24:00'
					},
					firstDayOfWeek: 7,
					views: [createViewDay(), createViewWeek()],
					weekOptions: {
						gridHeight: 700,
						eventWidth: 100,
						timeAxisFormatOptions: { hour: '2-digit', minute: '2-digit' },
						eventOverlap: true,
						gridStep: 60
					},
					callbacks: {
						onRangeUpdate(range) {
							console.log('rendering events for new range', range);
							if (icalendarPlugin) {
								icalendarPlugin.between(range.start, range.end);
							}
						}
					}
				},
				plugins as any
			);
		}
	});

	// Update ScheduleXCalendar when Calendar date changes
	$effect(() => {
		if (calendarApp && selectedDate) {
			const plainDate = Temporal.PlainDate.from({
				year: selectedDate.year,
				month: selectedDate.month,
				day: selectedDate.day
			});
			calendarControls.setDate(plainDate);
		}
	});

	// Set up inactivity timer and activity listeners
	onMount(() => {
		if (browser) {
			let lastReset = 0;

			function resetInactivityTimer() {
				const now = Date.now();
				if (now - lastReset < 1000) return; // throttle to once per second
				lastReset = now;
				if (inactivityTimer) clearTimeout(inactivityTimer);
				inactivityTimer = setTimeout(() => {
					goto('/');
				}, INACTIVITY_TIMEOUT);
			}

			// Removed 'mousemove' — fires hundreds of times per second and causes
			// "too many History API calls" error in Chromium
			const events = ['mousedown', 'keypress', 'scroll', 'touchstart', 'click'];
			events.forEach((event) => window.addEventListener(event, resetInactivityTimer));

			// Start the initial timer
			resetInactivityTimer();

			return () => {
				events.forEach((event) => window.removeEventListener(event, resetInactivityTimer));
				if (inactivityTimer) clearTimeout(inactivityTimer);
			};
		}
	});

	onMount(() => {
		if (browser) {
			// Auto-reload every 15 minutes to refresh calendar data
			const interval = setInterval(() => location.reload(), 1000 * 60 * 15);
			return () => {
				clearInterval(interval);
			};
		}
	});
</script>

<div class="flex gap-8">
	<div class="glass-panel flex self-start rounded-2xl shadow-lg">
		<Calendar
			type="single"
			bind:value={selectedDate}
			class="rounded-2xl border-0 bg-transparent"
		/>
	</div>
	<div class="glass-panel sx-glass flex-1 overflow-hidden rounded-2xl shadow-lg">
		{#if calendarApp}
			<ScheduleXCalendar {calendarApp} />
		{/if}
	</div>
</div>

<style>
	:global(.sx-glass) {
		--sx-color-background: transparent;
		--sx-color-surface: var(--card);
		--sx-color-surface-bright: var(--card);
		--sx-color-surface-container: color-mix(in oklch, var(--primary) 6%, var(--card));
		--sx-color-surface-container-high: color-mix(in oklch, var(--primary) 12%, var(--card));
		--sx-color-surface-container-low: var(--card);
		--sx-color-surface-dim: var(--muted);
		--sx-color-on-background: var(--foreground);
		--sx-color-on-surface: var(--foreground);
		--sx-color-primary: var(--primary);
		--sx-color-on-primary: var(--primary-foreground);
		--sx-color-primary-container: color-mix(in oklch, var(--primary) 25%, var(--card));
		--sx-color-on-primary-container: var(--foreground);
		--sx-color-secondary: var(--secondary);
		--sx-color-on-secondary: var(--secondary-foreground);
		--sx-color-secondary-container: color-mix(in oklch, var(--secondary) 40%, var(--card));
		--sx-color-on-secondary-container: var(--foreground);
		--sx-color-tertiary: var(--accent);
		--sx-color-on-tertiary: var(--accent-foreground);
		--sx-color-tertiary-container: color-mix(in oklch, var(--accent) 30%, var(--card));
		--sx-color-on-tertiary-container: var(--foreground);
		--sx-color-outline: var(--border);
		--sx-color-outline-variant: var(--border);
		--sx-border: var(--border);
		--sx-rounding-small: 0.5rem;
		--sx-rounding-extra-small: 0.375rem;
		--sx-rounding-extra-large: 1.25rem;
	}

	:global(.sx-glass .sx__calendar-wrapper) {
		background: transparent;
	}

	/* The default theme never sets a background on this popup — it floats
	   over whatever is behind it, which was our blurred glass panel. */
	:global(.sx-glass .sx__date-picker-popup) {
		background: var(--card);
		border-radius: var(--radius-lg);
	}

	/* Same issue as the date-picker popup: it also relies on
	   --sx-color-background, which we set to transparent above, so the
	   Day/Week dropdown items would otherwise blend into the glass panel. */
	:global(.sx-glass .sx__view-selection-items) {
		background: var(--card);
		border-radius: var(--radius-lg);
	}
</style>
