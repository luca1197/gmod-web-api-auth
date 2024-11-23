import app from './fastify-app.js'

const start = async () => {

	const { fastify } = await app.init()

	try {

		await new Promise((resolve, reject) => {
			fastify.listen({
				host: process.env.BIND_HOST || '0.0.0.0',
				port: process.env.BIND_PORT || 3020,
			}, (err) => {
				if (err) {
					reject(err)
				} else {
					resolve()
				}
			})
		})

	} catch (err) {
		fastify.log.error(err)
		process.exit(1)
	}

}

start()