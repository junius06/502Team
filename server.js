import express from "express";

const app = express();

// 환경변수 PORT가 있으면 사용하고, 없으면 3000
const PORT = process.env.PORT || 3000;

// 정적 파일 제공 (public 폴더)
app.use(express.static("public"));

// 간단한 헬스체크 엔드포인트
app.get("/healthz", (req, res) => {
  res.status(200).json({ status: "ok" });
});

// 404 처리 (정적 파일/라우트가 없을 때)
app.use((req, res) => {
  res.status(404).send("Not Found");
});

app.listen(PORT, () => {
  console.log(`✅ Server listening on http://0.0.0.0:${PORT}`);
});