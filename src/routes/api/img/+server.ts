import type { RequestHandler } from './$types.js';
import { UNSPLASH_ACCESS_KEY } from '$env/static/private';
import { json } from '@sveltejs/kit';

export const GET: RequestHandler = async () => {
    const response = await fetch(`https://api.unsplash.com/photos/random?client_id=${UNSPLASH_ACCESS_KEY}&query=travel`);
    const result = await response.json();
    const image = result.urls.raw + '&w=1600&h=1200&fit=crop&auto=format&q=80';
    return json({ url: image });
};