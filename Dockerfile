### Setup Tools
FROM node:22-alpine AS base

RUN npm install -g pnpm@9.x

USER node:node
WORKDIR /home/node/app


