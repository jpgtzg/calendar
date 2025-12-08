<script lang="ts">
	import { onMount } from 'svelte';
	import { browser } from '$app/environment';
	import { ScheduleXCalendar } from '@schedule-x/svelte';
	import { createCalendar, createViewDay, createViewWeek } from '@schedule-x/calendar';
	import { getLocalTimeZone, today, CalendarDate } from '@internationalized/date';
	import { Calendar } from '$lib/components/ui/calendar/index.js';
	import { createCalendarControlsPlugin } from '@schedule-x/calendar-controls';
	import '@schedule-x/theme-default/dist/index.css';
	import 'temporal-polyfill/global';

	let selectedDate = $state(today(getLocalTimeZone()));

	const calendarControls = createCalendarControlsPlugin();

	let calendarApp = $state<ReturnType<typeof createCalendar<[typeof calendarControls]>> | null>(
		null
	);

	onMount(() => {
		if (browser) {
			calendarApp = createCalendar(
				{
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
				[calendarControls]
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
	<div class="flex self-start">
		<Calendar type="single" bind:value={selectedDate} class="rounded-md border" />
	</div>
	<div class="w-4"></div>
	<div class="flex-1">
		{#if calendarApp}
			<ScheduleXCalendar {calendarApp} />
		{/if}
	</div>
</div>
