const app = require('./app');
const env = require('./config/env');
const prisma = require('./database/prisma');

const server = app.listen(env.PORT, () => {
  console.log(`🚀 Cafe Backend Server running on port ${env.PORT} in [${env.NODE_ENV}] mode`);
});

const gracefulShutdown = async () => {
  console.log(' Shutting down server gracefully...');
  server.close(async () => {
    await prisma.$disconnect();
    console.log(' Database disconnected. Exit.');
    process.exit(0);
  });
};

process.on('SIGTERM', gracefulShutdown);
process.on('SIGINT', gracefulShutdown);
