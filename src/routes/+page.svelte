<script lang="ts">
	import { getLocalTimeZone, today } from '@internationalized/date';
	import { Calendar } from '$lib/components/ui/calendar/index.js';
	import { Calendar as EventCalendar, TimeGrid } from '@event-calendar/core';

    let selectedDate = $state(today(getLocalTimeZone()));
	let options = $derived({
		view: 'timeGridWeek',
		events: [
			// { id, title, start, end, ... }
		],
        date: selectedDate.toDate(getLocalTimeZone()),
	});

</script>

<div class="flex flex-row gap-4">
	<Calendar type="single" bind:value={selectedDate} class="rounded-md border" />
	<div class="w-1"></div>
	<div class="flex-1">
		<EventCalendar plugins={[TimeGrid]} {options} />
	</div>
</div>
