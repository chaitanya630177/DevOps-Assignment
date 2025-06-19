'''javascript
const request = require('supertest');
const express = require('express');
const app = require('./app');

describe('Node.js Application', () => {
	  let server;

	  beforeEach(() => {
		      server = express();
		      server.use(app);
		    });

	  it('should respond with "Hello from Node.js on AWS!" on GET /', async () => {
		      const response = await request(server).get('/');
		      expect(response.status).toBe(200);
		      expect(response.text).toBe('Hello from Node.js on AWS!');
		    });
});
```
