import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types.js';
import { ICALENDAR_URL } from '$env/static/private';


export const GET: RequestHandler = async ({ url }) => {
	const icalendarUrl = ICALENDAR_URL || url.searchParams.get('url');
	
	if (!icalendarUrl) {
		return json({ error: 'Missing url parameter' }, { status: 400 });
	}

	try {
		const response = await fetch(icalendarUrl);
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

