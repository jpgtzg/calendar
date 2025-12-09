import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types.js';
import { readFileSync } from 'fs';
import { join } from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

export const GET: RequestHandler = async () => {
	try {
		// Read URLs from urls.json (relative to project root)
		const projectRoot = join(__dirname, '../../../../');
		const urlsPath = join(projectRoot, 'urls.json');
		
		console.log('Reading URLs from:', urlsPath);
		
		let urls: string[] = [];
		try {
			const urlsContent = readFileSync(urlsPath, 'utf-8');
			urls = JSON.parse(urlsContent);
		} catch (fileError) {
			console.error('Error reading urls.json:', fileError);
			// Try alternative path
			const altPath = join(process.cwd(), 'urls.json');
			console.log('Trying alternative path:', altPath);
			try {
				const urlsContent = readFileSync(altPath, 'utf-8');
				urls = JSON.parse(urlsContent);
			} catch (altError) {
				console.error('Error reading from alternative path:', altError);
				return json({ error: `Failed to read urls.json: ${altError}` }, { status: 500 });
			}
		}

		if (!Array.isArray(urls) || urls.length === 0) {
			return json({ error: 'No URLs found in urls.json' }, { status: 400 });
		}

		console.log(`Found ${urls.length} URLs to fetch`);

		// Fetch iCalendar data from all URLs
		const fetchPromises = urls.map(async (url) => {
			try {
				const response = await fetch(url);
				if (!response.ok) {
					console.error(`Failed to fetch from ${url}: ${response.statusText}`);
					return null;
				}
				return await response.text();
			} catch (error) {
				console.error(`Error fetching from ${url}:`, error);
				return null;
			}
		});

		const results = await Promise.all(fetchPromises);
		const validResults = results.filter((data): data is string => data !== null);

		if (validResults.length === 0) {
			return json({ error: 'Failed to fetch from all URLs' }, { status: 500 });
		}

		// Combine iCalendar data
		// Extract VEVENT blocks from each calendar and combine them
		const combinedEvents: string[] = [];
		let calendarHeader = '';
		let calendarFooter = '';

		validResults.forEach((icalData, index) => {
			// Split by lines to handle properly
			const lines = icalData.split(/\r?\n/);
			
			// Find BEGIN:VCALENDAR and everything until first BEGIN:VEVENT
			let headerEnd = -1;
			for (let i = 0; i < lines.length; i++) {
				if (lines[i].trim() === 'BEGIN:VEVENT') {
					headerEnd = i;
					break;
				}
			}

			// Extract header from first calendar only
			if (index === 0 && headerEnd > 0) {
				calendarHeader = lines.slice(0, headerEnd).join('\r\n') + '\r\n';
			}

			// Extract all VEVENT blocks (from BEGIN:VEVENT to END:VEVENT)
			let inEvent = false;
			let currentEvent: string[] = [];
			
			for (let i = 0; i < lines.length; i++) {
				const line = lines[i];
				if (line.trim() === 'BEGIN:VEVENT') {
					inEvent = true;
					currentEvent = [line];
				} else if (line.trim() === 'END:VEVENT') {
					if (inEvent) {
						currentEvent.push(line);
						combinedEvents.push(currentEvent.join('\r\n'));
						currentEvent = [];
						inEvent = false;
					}
				} else if (inEvent) {
					currentEvent.push(line);
				}
			}

			// Extract footer from last calendar
			if (index === validResults.length - 1) {
				// Find last END:VEVENT
				let lastEventEnd = -1;
				for (let i = lines.length - 1; i >= 0; i--) {
					if (lines[i].trim() === 'END:VEVENT') {
						lastEventEnd = i;
						break;
					}
				}
				if (lastEventEnd >= 0 && lastEventEnd < lines.length - 1) {
					calendarFooter = '\r\n' + lines.slice(lastEventEnd + 1).join('\r\n');
				}
			}
		});

		// Combine into single iCalendar
		const combinedData = calendarHeader + combinedEvents.join('\r\n') + calendarFooter;

		console.log(`Combined ${combinedEvents.length} events from ${validResults.length} calendars`);
		
		return json({ data: combinedData });
	} catch (error) {
		console.error('Error processing iCalendar URLs:', error);
		return json({ error: 'Failed to process iCalendar URLs' }, { status: 500 });
	}
};

