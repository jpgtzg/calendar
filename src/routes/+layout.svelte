<script lang="ts">
	import './layout.css';

	let { children } = $props();
</script>

<div class="p-8 bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-50 min-h-screen">
	<div class="flex items-center justify-between shadow-md rounded-md p-4 bg-white">
		<h1 class="text-2xl font-bold">Calendar</h1>
		<p class="text-sm text-gray-500">@jpgtzg</p>
	</div>
	<div class="h-8"></div>
	{@render children()}
</div>
