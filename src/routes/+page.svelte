<script lang="ts">
	import { onMount } from 'svelte';
	import { browser } from '$app/environment';
	import { goto } from '$app/navigation';

	let unsplashPhoto = $state<string | null>(null);
	let now = $state(new Date());

	// Fetch the unsplash photo from the api
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
					reloadInterval = setInterval(
						() => goto('/', { invalidateAll: true }),
						1000 * imageReloadTimeSeconds
					);
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

<div class="relative flex h-screen items-center justify-center overflow-hidden bg-black">
	<button
		type="button"
		onclick={handleImageClick}
		onkeydown={handleImageKeydown}
		class="relative block h-full w-full cursor-pointer border-none bg-transparent p-0"
		aria-label="Click to view calendar"
	>
		{#if unsplashPhoto}
			<img
				src={unsplashPhoto}
				alt="Written by @jpgtzg"
				class="h-full w-full object-cover"
			/>
		{/if}

		<div
			class="absolute inset-0"
			style="background-image: radial-gradient(at 15% 85%, oklch(0.62 0.22 291 / 45%) 0px, transparent 55%), radial-gradient(at 85% 15%, oklch(0.75 0.17 340 / 40%) 0px, transparent 55%), linear-gradient(to top, oklch(0.1 0.02 280 / 65%), transparent 45%);"
		></div>

		<div class="absolute inset-0 flex flex-col items-center justify-center gap-4 px-6">
			<div
				class="glass-panel flex flex-col items-center gap-2 rounded-[2.5rem] px-16 py-10 text-white shadow-2xl"
			>
				<p class="text-7xl font-semibold tracking-tight drop-shadow-lg sm:text-8xl">
					{now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
				</p>
				<p class="text-lg font-medium text-white/80 sm:text-xl">
					{now.toLocaleDateString([], {
						weekday: 'long',
						month: 'long',
						day: 'numeric'
					})}
				</p>
			</div>
			<p class="text-sm font-medium tracking-wide text-white/60">Tap to open calendar</p>
		</div>
	</button>
</div>
