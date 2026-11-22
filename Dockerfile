FROM node:19.9@sha256:92f06fc13bcc09f1ddc51f6ebf1aa3d21a6532b74f076f224f188bc6b9317570 as deps
WORKDIR /app

RUN curl -fsSL "https://github.com/pnpm/pnpm/releases/latest/download/pnpm-linuxstatic-x64" -o /bin/pnpm; chmod +x /bin/pnpm

RUN node -v && pnpm -v

COPY pnpm-lock.yaml ./
RUN pnpm fetch

FROM deps as builder

ADD . ./
RUN pnpm install --offline

RUN pnpm run build
RUN pnpm prune --prod

FROM node:19.9@sha256:92f06fc13bcc09f1ddc51f6ebf1aa3d21a6532b74f076f224f188bc6b9317570
WORKDIR /app
EXPOSE 3000
ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=3000

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/build ./build
COPY --from=builder /app/package.json ./

CMD ["node", "build"]
