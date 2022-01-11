import SteamID from "steamid"
import jsonwebtoken from "jsonwebtoken"

export function IsValidSteamID(input) {
	if (!input) {return false}
	try {
		let id = new SteamID(input)
		return id.isValid() && id.isValidIndividual()
	} catch (e) {
		return false
	}
}

export async function AuthJWT(jwt) {

	if (!jwt) {return {success: false}}

	let verified = await new Promise(resolve => {
		jsonwebtoken.verify(jwt, process.env.JWT_SECRET, (err, decoded) => {
			if (err) {
				resolve({success: false})
			} else {
				resolve({success: true, decoded: decoded})
			}
		})
	})

	return verified

}

export async function SignJWT(payload, options = {}) {

	if (!payload) {return {success: false}}

	let jwt = await new Promise(resolve => {
		jsonwebtoken.sign(payload, process.env.JWT_SECRET, options, (err, jwt) => {
			if (err) {
				resolve({success: false})
			} else {
				resolve({success: true, jwt: jwt})
			}
		})
	})

	return jwt

}