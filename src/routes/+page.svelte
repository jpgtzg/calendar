<script lang="ts">
	import { onMount } from 'svelte';
	import { browser } from '$app/environment';
	import { goto } from '$app/navigation';

	let unsplashPhoto = $state<string | null>(null);

	onMount(async () => {
		if (browser) {
			const response = await fetch(`/api/img`);
			const result = await response.json();
			unsplashPhoto = result.url;
		}
	});

	onMount(() => {
		if (browser) {
			// Set up auto-reload every 3 minutes
			const interval = setInterval(() => location.reload(), 1000 * 60 * 3);

			return () => {
				clearInterval(interval);
			};
		}
	});

	// Handle image click/keypress to navigate to calendar
	function handleImageClick() {
		goto('/calendar');
	}

	function handleImageKeydown(event: KeyboardEvent) {
		if (event.key === 'Enter' || event.key === ' ') {
			event.preventDefault();
			handleImageClick();
		}
	}
</script>

<div class="flex justify-center items-center h-screen">
	<button
		type="button"
		onclick={handleImageClick}
		onkeydown={handleImageKeydown}
		class="cursor-pointer border-none bg-transparent p-0"
		aria-label="Click to view calendar"
	>
		<img src={unsplashPhoto} alt="Written by @jpgtzg" class="block" />
	</button>
</div>
