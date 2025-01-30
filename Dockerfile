# Stage 1: Build Next.js app
FROM node:18 AS builder

WORKDIR /app

# まず package.json と package-lock.json をコピー
COPY package.json package-lock.json ./

# npm install の競合を回避
RUN npm install --legacy-peer-deps

# 残りのファイルをコピー
COPY . .

# Next.js のビルド
RUN npm run build

# Stage 2: 軽量なランタイム環境
FROM node:18-alpine

WORKDIR /app

# 必要なファイルのみコピー
COPY --from=builder /app/.next .next
COPY --from=builder /app/node_modules node_modules
COPY --from=builder /app/package.json .

EXPOSE 3000

# Next.js のサーバーを起動
CMD ["npm", "run", "start"]
