declare module '@event-calendar/core' {
	import type { Component } from 'svelte';

	export const Calendar: Component<{
		plugins?: any[];
		options?: {
			view?: string;
			events?: any[];
			[key: string]: any;
		};
		[key: string]: any;
	}>;

	export const TimeGrid: any;
	export const DayGrid: any;
	export const Interaction: any;
	export const List: any;
	export const ResourceTimeGrid: any;
	export const ResourceTimeline: any;
	export function createCalendar(target: HTMLElement, plugins: any[], options: any): any;
	export function destroyCalendar(calendar: any): void;
}

