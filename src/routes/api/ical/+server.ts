import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types.js';
import { ICALENDAR_URL } from '$env/static/private';

export const GET: RequestHandler = async () => {
	try {
		if (!ICALENDAR_URL) {
			return json({ error: 'ICALENDAR_URL environment variable is not set' }, { status: 500 });
		}

		const response = await fetch(ICALENDAR_URL);
		if (!response.ok) {
			return json({ error: 'Failed to fetch iCalendar' }, { status: response.status });
		}
		
		const data = await response.text();
		return json({ data });
	} catch (error) {
		console.error('Error fetching iCalendar:', error);
		return json({ error: 'Failed to fetch iCalendar' }, { status: 500 });
	}
};

