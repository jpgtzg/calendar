<script lang="ts">
	import { onMount } from 'svelte';
	import { browser } from '$app/environment';
	import { ScheduleXCalendar } from '@schedule-x/svelte';
	import { createCalendar, createViewDay, createViewWeek } from '@schedule-x/calendar';
	import { getLocalTimeZone, today, CalendarDate } from '@internationalized/date';
	import { Calendar } from '$lib/components/ui/calendar/index.js';
	import { createCalendarControlsPlugin } from '@schedule-x/calendar-controls';
	import { createIcalendarPlugin } from '@schedule-x/ical';
	import '@schedule-x/theme-default/dist/index.css';
	import 'temporal-polyfill/global';

	let selectedDate = $state(today(getLocalTimeZone()));

	const calendarControls = createCalendarControlsPlugin();

	let calendarApp = $state<ReturnType<typeof createCalendar> | null>(null);

	onMount(async () => {
		if (browser) {
			// Fetch iCalendar data from server API route (bypasses CORS)
			let icalendarData = '';
			try {
				const response = await fetch(`/api/ical`);
				if (response.ok) {
					const result = await response.json();
					icalendarData = result.data || '';
				} else {
					console.error('Failed to fetch iCalendar:', response.statusText);
				}
			} catch (error) {
				console.error('Failed to fetch iCalendar:', error);
			}

			// Only create iCalendar plugin if we have data
			const plugins = icalendarData
				? [calendarControls, createIcalendarPlugin({ data: icalendarData })]
				: [calendarControls];

			calendarApp = createCalendar(
				{
					dayBoundaries: {
						start: '06:00',
						end: '24:00'
					},
					views: [createViewDay(), createViewWeek()],
					events: [
						{
							id: '1',
							title: 'Event 1',
							start: Temporal.PlainDate.from('2025-12-08'),
							end: Temporal.PlainDate.from('2025-12-09')
						},
						{
							id: '2',
							title: 'Event 2',
							start: Temporal.ZonedDateTime.from('2024-07-06T02:00:00+09:00[Asia/Tokyo]'),
							end: Temporal.ZonedDateTime.from('2024-07-06T04:00:00+09:00[Asia/Tokyo]')
						}
					]
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
</script>

<div class="flex">
	<div class="flex self-start shadow-md">
		<Calendar type="single" bind:value={selectedDate} class="rounded-md border" />
	</div>
	<div class="w-8"></div>
	<div class="flex-1 shadow-md">
		{#if calendarApp}
			<ScheduleXCalendar {calendarApp} />
		{/if}
	</div>
</div>
