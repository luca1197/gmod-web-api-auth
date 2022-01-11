import { AuthJWT } from "../library/utility.js"
import app from '../fastify-app.js'

export const get = {
	preValidation: (req, res, done) => {

		/*
			key query parameter
		*/
		if (!req?.query?.key) {
			return res.status(400).send({ok: false, message: 'Missig "key" query paramter'})
		}

		const key = req?.query?.key
		if (key.length < 16 || key.length > 128) {
			return res.status(400).send({ok: false, message: 'Invalid "key" query parameter'})
		}

		if (!app.config?.api_keys || !app.config?.api_keys?.includes(key)) {
			return res.status(403).send({ok: false, message: 'Not allowed'})
		}

		/*
			jwt query parameter
		*/
		if (!req?.query?.jwt) {
			return res.status(400).send({ok: false, message: 'Missig "jwt" query paramter'})
		}

		done()

	},
	handler: async (req, res) => {
		
		const authedJWT = await AuthJWT(req.query.jwt)
		if (!authedJWT) return {ok: false}

		return {
			ok: true,
			valid: authedJWT.success,
			decoded: authedJWT.jwt
		}

	}
}