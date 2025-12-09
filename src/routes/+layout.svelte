<script lang="ts">
	import './layout.css';

	let { children } = $props();
</script>

<div class="p-8 bg-gray-100">
	<div class="flex items-center justify-between shadow-md rounded-md p-4 bg-white">
		<h1 class="text-2xl font-bold">Calendar</h1>
		<button
			class="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded-full flex items-center gap-2"
		>
			<svg
				xmlns="http://www.w3.org/2000/svg"
				class="h-5 w-5"
				fill="none"
				viewBox="0 0 24 24"
				stroke="currentColor"
			>
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
			</svg>
			Add Event
		</button>
	</div>
	<div class="h-8"></div>
	{@render children()}
</div>
