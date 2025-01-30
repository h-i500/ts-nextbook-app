# Stage 1: Build Next.js app
FROM node:18 AS builder

WORKDIR /app

# APIのエンドポイントを環境変数として設定
ARG NEXT_PUBLIC_API_URL="https://your-api.com"
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}

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

# 環境変数を再設定（ランタイムでも API URL を使えるように）
ARG NEXT_PUBLIC_API_URL="https://your-api.com"
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}

# 必要なファイルのみコピー
COPY --from=builder /app/.next .next
COPY --from=builder /app/node_modules node_modules
COPY --from=builder /app/package.json .

EXPOSE 3000

# Next.js のサーバーを起動
CMD ["npm", "run", "start"]
