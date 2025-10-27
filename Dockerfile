# ============================================
# Stage 1: Dependencies
# ============================================
FROM node:16-alpine AS dependencies

WORKDIR /usr/src/app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar solo dependencias de producción
RUN npm ci --only=production

# ============================================
# Stage 2: Builder (opcional, para compilación)
# ============================================
FROM node:16-alpine AS builder

WORKDIR /usr/src/app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar todas las dependencias (incluyendo dev)
RUN npm ci

# Copiar código fuente
COPY . .

# Si tuvieras proceso de build (TypeScript, etc.), aquí iría
# RUN npm run build

# ============================================
# Stage 3: Production
# ============================================
FROM node:16-alpine

# Instalar dumb-init para manejo correcto de señales
RUN apk add --no-cache dumb-init

# Crear usuario no-root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /usr/src/app

# Copiar dependencias desde stage dependencies
COPY --from=dependencies --chown=nodejs:nodejs /usr/src/app/node_modules ./node_modules

# Copiar código fuente
COPY --chown=nodejs:nodejs . .

# Cambiar a usuario no-root
USER nodejs

# Exponer puerto
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Usar dumb-init para correcto manejo de señales
ENTRYPOINT ["dumb-init", "--"]

# Comando de inicio
CMD ["node", "src/index.js"]