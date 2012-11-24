winston = require "winston"


logger = new (winston.Logger)
    exitOnError: false
    transports: [new (winston.transports.Console)()]

module.exports = logger