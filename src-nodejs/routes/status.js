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

		done()

	},
	handler: async (req, res) => {

		return {
			ok: true,
			info: {
				jwt_expiration: process.env.JWT_EXPIRATION,
			}
		}

	}
}