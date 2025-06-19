```dockerfile
# Use a minimal Alpine-based Node.js image
FROM node:20-alpine

# Create a non-root user
RUN addgroup -S chaitu && adduser -S chaitu -G chaitu

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY app/package.json .
RUN npm install --production

# Copy application code
COPY app/app.js .

# Change ownership to non-root user
RUN chown -R chaitu:chaitu /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 3000

# Run the application
CMD ["npm", "start"]
```


