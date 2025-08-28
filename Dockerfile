# ---- Base stage ----
FROM node:20-alpine AS base
WORKDIR /app

# 패키지 정보만 먼저 복사하여 의존성 캐시 최적화
COPY package.json package-lock.json* ./

# 프로덕션 의존성만 설치
RUN npm ci --omit=dev

# 앱 소스 복사
COPY server.js ./server.js
COPY public ./public
COPY testfile.html ./testfile.html

# ---- Runtime stage (더 가벼운 이미지) ----
FROM node:20-alpine AS runtime
WORKDIR /app

# 비루트 사용자 생성 (보안)
RUN addgroup -S nodegrp && adduser -S nodeuser -G nodegrp
USER nodeuser

# base에서 설치된 node_modules와 앱 복사
COPY --from=base /app /app

ENV NODE_ENV=production \
    PORT=3000

EXPOSE 3000

# 간단한 헬스체크 (10초 간격, 3회 실패 시 비정상)
HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD wget -qO- http://127.0.0.1:3000/healthz || exit 1

CMD ["node", "server.js"]