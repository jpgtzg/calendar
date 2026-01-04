<script lang="ts">
	import { onMount } from 'svelte';
	import { browser } from '$app/environment';
	import { goto } from '$app/navigation';

	let unsplashPhoto = $state<string | null>(null);

	let now = $state(new Date());

	// This part fetches the unsplash photo from the api
	onMount(async () => {
		if (browser) {
			const response = await fetch(`/api/img`);
			const result = await response.json();
			unsplashPhoto = result.url;
		}
	});

	onMount(() => {
		if (browser) {
			// Update time every second
			const timeInterval = setInterval(() => {
				now = new Date();
			}, 1000);

			let reloadInterval: ReturnType<typeof setInterval> | null = null;

			// Fetch the image reload time from the server and set up reload interval
			fetch(`/api/config`)
				.then((configResponse) => configResponse.json())
				.then((config) => {
					const imageReloadTimeSeconds = config.imageReloadTimeSeconds;
					reloadInterval = setInterval(() => location.reload(), 1000 * imageReloadTimeSeconds);
				});

			return () => {
				clearInterval(timeInterval);
				if (reloadInterval) {
					clearInterval(reloadInterval);
				}
			};
		}
	});
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

<div class="flex justify-center items-center h-screen relative">
	<button
		type="button"
		onclick={handleImageClick}
		onkeydown={handleImageKeydown}
		class="cursor-pointer border-none bg-transparent p-0 relative"
		aria-label="Click to view calendar"
	>
		<img src={unsplashPhoto} alt="Written by @jpgtzg" class="block" />
		<p
			class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 text-white text-6xl font-semibold drop-shadow-lg tracking-wide"
		>
			{now.toLocaleTimeString()}
		</p>
	</button>
</div>
