import fastify from 'fastify'
import fastify_helmet from '@fastify/helmet'
import { promises as fs } from 'fs'
import dotenv from 'dotenv'

class App {

	constructor() {
		this.RoutesCount = 0
	}

	async init() {
		await this.start()
		return this
	}

	async registerRouteDirectory(dir) {

		let routes = await fs.readdir(dir)

		for (let route of routes) {
			let routePath = `${dir}/${route}`
			let stats = await fs.stat(routePath)

			if (stats.isDirectory()) {
				await this.registerRouteDirectory(routePath)
			} else if (stats.isFile()) {
				let routeURL = routePath.replace('./routes', '').replace('.js', '').replace(/(\[\w+\])/g, ':$1').replace(/[[\]]/g, '')
				try {
					let routeFile = await import(routePath)

					for (let httpMethod in routeFile) {
						if (['get', 'post', 'put', 'delete'].includes(httpMethod)) {
							let handler = routeFile[httpMethod]
							this.fastify.route({
								method: httpMethod.toUpperCase(),
								url: routeURL,
								handler: handler.handler,
								preValidation: handler.preValidation,
							})

							this.RoutesCount++
						}
					}
				} catch (err) {
					this.fastify.log.error(`Failed to register route ${routeURL}:\n${err.stack}`)
				}

			}
		}

	}

	async start() {

		if (this.Started) {return this}

		// Load dotenv
		dotenv.config()

		// Load config
		this.config = {}
		const cfg = await fs.readFile('./config.json', 'utf8')
		if (cfg) {
			this.config = JSON.parse(cfg)
		}

		// Init Fastify
		try {
			this.fastify = fastify({
				logger: {
					level: 'info',
					transport: {
						target: 'pino-pretty',
						options: {
							translateTime: 'HH:MM:ss Z',
							ignore: 'pid,hostname',
						},
					}
				},
				disableRequestLogging: true,
			})

			this.fastify.setErrorHandler((err, req, res) => {
				this.fastify.log.error(`Error from route ${req.url}: ${err.stack}`)
				res.status(500).send({ok: false, message: 'Internal server error'})
			})

			// Helmet
			this.fastify.register(fastify_helmet)
		} catch (err) {
			console.error(`Error while initializing Fastify: ${err.stack}`)
			process.exit(1)
		}

		// Validate .env and config
		if (process.env.JWT_SECRET === undefined || process.env.JWT_SECRET === "example-secret") {
			this.fastify.log.error('.env has not been set up properly. Please set JWT_SECRET to a secret string.')
			process.exit(1)
		}

		if (this.config?.api_keys.includes('example-key')) {
			this.fastify.log.error('Config has "example-key" in api_keys. Please replace it.')
			process.exit(1)
		}

		// Load and register routes
		try {
			await this.registerRouteDirectory(`./routes`)
			this.fastify.log.info(`Registered ${this.RoutesCount} route(s)`)
		} catch(err) {
			this.fastify.log.error(`Failed to register routes:\n${err.stack}`)
		}

		this.Started = true

	}

}

export default new App()