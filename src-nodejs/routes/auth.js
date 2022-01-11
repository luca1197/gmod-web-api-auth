import { IsValidSteamID, SignJWT } from "../library/utility.js"
import app from '../fastify-app.js'
import SteamID from "steamid"

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
			steamid query parameter
		*/
		if (!req?.query?.steamid) {
			return res.status(400).send({ok: false, message: 'Missig "steamid" query paramter'})
		}

		if (!IsValidSteamID(req.query.steamid)) {
			return res.status(400).send({ok: false, message: 'Invalid "steamid" query parameter'})
		}

		done()

	},
	handler: async (req, res) => {

		app.fastify.log.info(`Requested JWT for ${req.query.steamid}`)

		const steamIDObj = new SteamID(req.query.steamid)

		const userInfo = {
			steamid64: req.query.steamid,
			steamid: steamIDObj.getSteam2RenderedID(),
		}

		const jwt = await SignJWT(userInfo, {expiresIn: `${process.env.JWT_EXPIRATION}s`})

		return {
			ok: true,
			jwt: jwt.jwt,
		}

	}
}