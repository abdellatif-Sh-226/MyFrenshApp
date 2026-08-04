FROM node:22-alpine

RUN apk add --no-cache openssl libc6-compat

WORKDIR /app

COPY backend/package*.json ./backend/
RUN cd backend && npm install

COPY backend/prisma ./backend/prisma
RUN cd backend && npx prisma generate

COPY backend/src ./backend/src
COPY assets ./assets

WORKDIR /app/backend

EXPOSE 3000

CMD ["sh", "-c", "npx prisma db push && node src/seed.js && node src/index.js"]
