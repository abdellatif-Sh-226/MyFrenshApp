FROM node:22-alpine

RUN apk add --no-cache openssl libc6-compat

WORKDIR /app

COPY backend/package*.json ./
RUN npm install

COPY backend/prisma ./prisma
RUN npx prisma generate

COPY backend/src ./src
COPY assets ./assets

EXPOSE 3000

CMD ["sh", "-c", "npx prisma db push && node src/seed.js && node src/index.js"]
