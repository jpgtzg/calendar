import type { RequestHandler } from './$types.js';
import { UNSPLASH_ACCESS_KEY } from '$env/static/private';
import { json } from '@sveltejs/kit';

export const GET: RequestHandler = async () => {
    try {
        const response = await fetch(
            `https://api.unsplash.com/photos/random?client_id=${UNSPLASH_ACCESS_KEY}&query=travel`
        );

        const contentType = response.headers.get('content-type') || '';

        // If the response is JSON, parse it
        let data: any;
        if (contentType.includes('application/json')) {
            data = await response.json();
        } else {
            // Non-JSON response (e.g., "Rate Limit Exceeded")
            const text = await response.text();
            return json({ error: true, message: text }, { status: 500 });
        }

        // Build the image URL
        const image = data.urls.raw + '&w=1900&h=1200&fit=crop&auto=format&q=80';
        return json({ url: image });
    } catch (err) {
        // Catch network errors
        return json({ error: true, message: (err as Error).message }, { status: 500 });
    }
};
