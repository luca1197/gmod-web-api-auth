import app from './fastify-app.js'

const start = async () => {
	const { fastify } = await app.init()

	try {
		await fastify.listen(3020, '127.0.0.1')
	} catch (err) {
		fastify.log.error(err)
		process.exit(1)
	}
}

start()