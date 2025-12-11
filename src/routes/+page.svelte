<script lang="ts">
	import { onMount } from 'svelte';
	import { browser } from '$app/environment';
	import { goto } from '$app/navigation';

	let unsplashPhoto = $state<string | null>(null);
	let isBlackScreen = $state(false);
	let inactivityTimer: ReturnType<typeof setTimeout> | null = null;
	const INACTIVITY_TIMEOUT = 1000 * 60 * 10; // 10 minutes

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

	// Reset inactivity timer
	function resetInactivityTimer() {
		if (inactivityTimer) {
			clearTimeout(inactivityTimer);
		}
		inactivityTimer = setTimeout(() => {
			isBlackScreen = true;
		}, INACTIVITY_TIMEOUT);
	}

	// Wake up screen on user interaction
	function wakeUpScreen() {
		if (isBlackScreen) {
			isBlackScreen = false;
		}
		resetInactivityTimer();
	}

	// Set up activity listeners
	onMount(() => {
		if (browser) {
			const events = ['mousedown', 'mousemove', 'keypress', 'scroll', 'touchstart', 'click'];
			const handleActivity = () => {
				wakeUpScreen();
			};

			events.forEach((event) => {
				window.addEventListener(event, handleActivity);
			});

			// Start the timer
			resetInactivityTimer();

			return () => {
				events.forEach((event) => {
					window.removeEventListener(event, handleActivity);
				});
				if (inactivityTimer) {
					clearTimeout(inactivityTimer);
				}
			};
		}
	});

	// Handle image click/keypress to navigate to calendar
	function handleImageClick() {
		wakeUpScreen();
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
		class="cursor-pointer border-none bg-transparent p-0"
		aria-label="Click to view calendar"
	>
		<img src={unsplashPhoto} alt="Written by @jpgtzg" class="block" />
	</button>
	{#if isBlackScreen}
		<div
			class="absolute inset-0 bg-black z-50"
			onclick={wakeUpScreen}
			onkeydown={(e) => {
				if (e.key === 'Enter' || e.key === ' ') {
					e.preventDefault();
					wakeUpScreen();
				}
			}}
			role="button"
			tabindex="0"
			aria-label="Screen is black due to inactivity. Click or press Enter to wake up."
		></div>
	{/if}
</div>
