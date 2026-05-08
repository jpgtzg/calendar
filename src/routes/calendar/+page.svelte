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
	<div class="flex self-start shadow-lg">
		<Calendar type="single" bind:value={selectedDate} class="rounded-md border" />
	</div>
	<div class="flex-1 rounded-md shadow-md">
		{#if calendarApp}
			<ScheduleXCalendar {calendarApp} />
		{/if}
	</div>
</div>
