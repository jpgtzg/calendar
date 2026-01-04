import type { RequestHandler } from './$types.js';
import { IMAGE_RELOAD_TIME_SECONDS } from '$env/static/private';
import { json } from '@sveltejs/kit';

export const GET: RequestHandler = async () => {
	return json({ imageReloadTimeSeconds: IMAGE_RELOAD_TIME_SECONDS });
};

