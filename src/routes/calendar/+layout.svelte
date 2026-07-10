<script lang="ts">
	import '../layout.css';

	let { children } = $props();
</script>

<div class="mesh-bg min-h-screen p-8">
	<div class="glass-panel flex items-center justify-between rounded-2xl px-6 py-4 shadow-lg">
		<h1 class="brand-gradient-text text-2xl font-bold tracking-tight">Calendar</h1>
		<p
			class="rounded-full border border-border/50 bg-background/60 px-3 py-1 text-sm font-medium text-muted-foreground"
		>
			@jpgtzg
		</p>
	</div>
	<div class="h-8"></div>
	{@render children()}
</div>
