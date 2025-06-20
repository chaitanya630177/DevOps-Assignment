'''javascript
const express = require('express');
const winston = require('winston');

const app = express();

// Configure Winston logger for JSON-structured logs
// const logger = winston.createLogger({
//   level: 'info',
//     format: winston.format.combine(
//         winston.format.timestamp(),
//             winston.format.json()
//               ),
//                 transports: [
//                     new winston.transports.Console()
//                       ]
//                       });
//
//                       // Middleware to log requests
//                       app.use((req, res, next) => {
//                         logger.info({
//                             message: 'HTTP request',
//                                 method: req.method,
//                                     url: req.url,
//                                         ip: req.ip,
//                                             timestamp: new Date().toISOString()
//                                               });
//                                                 next();
//                                                 });
//
//                                                 app.get('/', (req, res) => {
//                                                   logger.info({ message: 'Serving root endpoint' });
//                                                     res.send('Hello from Node.js on AWS!');
//                                                     });
//
//                                                     app.listen(3000, () => {
//                                                       logger.info({ message: 'Server started on port 3000' });
//                                                       });
//                                                       ```
