import express from "express";
import cors from "cors";
import dotenv from "dotenv";

dotenv.config();

const app = express();

// ✅ Configuración CORS segura y funcional (incluye preflight)
const allowedOrigins = [
  "https://frontend.ingeniebrios.work.gd",
  "http://localhost:5173" // opcional para desarrollo local
];

app.use(cors({
  origin: function (origin, callback) {
    // Permitir solicitudes sin origen (como Postman) o de dominios permitidos
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      console.log(`❌ CORS bloqueado para origen: ${origin}`);
      callback(new Error("No permitido por CORS"));
    }
  },
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"],
  credentials: true,
}));

// ✅ Middleware para manejar OPTIONS (preflight)
app.options("*", cors());

// ✅ Body parser
app.use(express.json());

// ✅ Ejemplo de ruta de login
app.post("/auth/login", (req, res) => {
  const { email, password } = req.body;
  if (email === "admin@demo.com" && password === "1234") {
    res.json({ message: "Login exitoso", token: "fake-jwt-token" });
  } else {
    res.status(401).json({ message: "Credenciales incorrectas" });
  }
});

// ✅ Ruta base de prueba
app.get("/", (req, res) => {
  res.send("Servidor backend operativo 🚀");
});

// ✅ Arrancar servidor
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ Servidor corriendo en puerto ${PORT}`);
});
