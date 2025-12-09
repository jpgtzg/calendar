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

	setInterval(() => location.reload(), 1000 * 60 * 15); // every 15 min
</script>

<div class="flex justify-center items-center h-screen">
	<button
		type="button"
		onclick={handleImageClick}
		onkeydown={handleImageKeydown}
		class="cursor-pointer border-none bg-transparent p-0"
		aria-label="Click to view calendar"
	>
		<img src={unsplashPhoto} alt="Random from Unsplash" class="block" />
	</button>
</div>
